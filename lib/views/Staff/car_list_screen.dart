import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Booking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CarStatusScreen(),
    );
  }
}

class CarStatusScreen extends StatefulWidget {
  const CarStatusScreen({super.key});

  @override
  State<CarStatusScreen> createState() => _CarStatusScreenState();
}

class _CarStatusScreenState extends State<CarStatusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Date and time selection
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay fromTime = TimeOfDay.now();
  TimeOfDay toTime = TimeOfDay.now();

  // Search and data
  String searchQuery = '';
  Map<String, dynamic>? availableData;
  Map<String, dynamic>? bookedData;
  bool isLoadingAvailable = false;
  bool isLoadingBooked = false;
  bool isRefreshing = false;

  final TextEditingController searchController = TextEditingController();

  // Store expanded state for booking history
  final Map<String, bool> expandedHistory = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _fetchAllData();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    await Future.wait([
      _fetchAvailableCars(),
      _fetchBookedCars(),
    ]);
  }

  Future<void> _fetchAvailableCars() async {
    setState(() {
      isLoadingAvailable = true;
    });

    try {
      final url = Uri.parse(
          'https://varahibackend.varahiselfdrivecars.com/api/car/carsbystatus?status=available&startDate=${_formatDate(startDate)}&endDate=${_formatDate(endDate)}&fromTime=${_formatTime(fromTime)}&toTime=${_formatTime(toTime)}');

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          availableData = json.decode(response.body);
          // Initialize expanded state for new cars
          if (availableData != null && availableData!['cars'] != null) {
            for (var car in availableData!['cars']) {
              if (car['bookedStatus'] != null &&
                  (car['bookedStatus'] as List).isNotEmpty) {
                expandedHistory[car['_id']] = false;
              }
            }
          }
        });
      } else {
        _showError('Failed to load available cars');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() {
        isLoadingAvailable = false;
      });
    }
  }

  Future<void> _fetchBookedCars() async {
    setState(() {
      isLoadingBooked = true;
    });

    try {
      final url = Uri.parse(
          'https://varahibackend.varahiselfdrivecars.com/api/car/carsbystatus?status=booked&startDate=${_formatDate(startDate)}&endDate=${_formatDate(endDate)}&fromTime=${_formatTime(fromTime)}&toTime=${_formatTime(toTime)}');

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          bookedData = json.decode(response.body);
          // Initialize expanded state for new cars
          if (bookedData != null && bookedData!['cars'] != null) {
            for (var car in bookedData!['cars']) {
              if (car['bookedStatus'] != null &&
                  (car['bookedStatus'] as List).isNotEmpty) {
                expandedHistory[car['_id']] = false;
              }
            }
          }
        });
      } else {
        _showError('Failed to load booked cars');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() {
        isLoadingBooked = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mma').format(dateTime).toUpperCase();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        startDate = picked;
        // Ensure end date is not before start date
        if (endDate.isBefore(startDate)) {
          endDate = startDate.add(const Duration(days: 1));
        }
      });
      _fetchAllData();
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        endDate = picked;
      });
      _fetchAllData();
    }
  }

  Future<void> _selectFromTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: fromTime,
    );

    if (picked != null) {
      setState(() {
        fromTime = picked;
      });
      _fetchAllData();
    }
  }

  Future<void> _selectToTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: toTime,
    );

    if (picked != null) {
      setState(() {
        toTime = picked;
      });
      _fetchAllData();
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isRefreshing = true;
    });
    await _fetchAllData();
    setState(() {
      isRefreshing = false;
    });
  }

  List<dynamic> _getFilteredCars(Map<String, dynamic>? data) {
    if (data == null || !data.containsKey('cars')) return [];

    final cars = data['cars'] as List;
    if (searchQuery.isEmpty) return cars;

    return cars.where((car) {
      final carName = (car['carName'] as String? ?? '').toLowerCase();
      final carId = (car['_id'] as String? ?? '').toLowerCase();
      final query = searchQuery.toLowerCase();
      return carName.contains(query) || carId.contains(query);
    }).toList();
  }

  void _toggleHistory(String carId) {
    setState(() {
      expandedHistory[carId] = !(expandedHistory[carId] ?? false);
    });
  }

  void _showFullHistory(List<dynamic> history, String carName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Booking History - $carName',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final entry = history[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Text('${index + 1}'),
                          ),
                          title: Text(
                            entry.toString(),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Availability'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Available', icon: Icon(Icons.check_circle)),
            Tab(text: 'Booked', icon: Icon(Icons.book_online)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isRefreshing ? null : _refreshData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Date and Time Selection Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDateButton(
                        'Start: ${DateFormat('dd MMM yyyy').format(startDate)}',
                        Icons.event,
                        _selectStartDate,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDateButton(
                        'End: ${DateFormat('dd MMM yyyy').format(endDate)}',
                        Icons.event_note,
                        _selectEndDate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeButton(
                        'From: ${fromTime.format(context)}',
                        Icons.access_time,
                        _selectFromTime,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTimeButton(
                        'To: ${toTime.format(context)}',
                        Icons.access_time,
                        _selectToTime,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by car name or ID...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                            searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAvailableTab(),
                _buildBookedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(icon, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Icon(icon, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableTab() {
    if (isLoadingAvailable) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredCars = _getFilteredCars(availableData);
    final total = availableData?['total'] ?? 0;

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Cars',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Total: $total',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredCars.isEmpty
                ? const Center(child: Text('No cars available'))
                : ListView.separated(
                    itemCount: filteredCars.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16), // Increased gap
                    itemBuilder: (context, index) {
                      return _buildCarCard(filteredCars[index],
                          isAvailable: true);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookedTab() {
    if (isLoadingBooked) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredCars = _getFilteredCars(bookedData);
    final total = bookedData?['total'] ?? 0;

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booked Cars',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Total: $total',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredCars.isEmpty
                ? const Center(child: Text('No booked cars'))
                : ListView.separated(
                    itemCount: filteredCars.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 32), // Increased gap
                    itemBuilder: (context, index) {
                      return _buildCarCard(filteredCars[index],
                          isAvailable: false);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarCard(dynamic car, {required bool isAvailable}) {
    final branchName = car['branch']?['name'] ?? 'Unknown';
    final location = car['location'] ?? 'Unknown';
    final coordinates = car['branch']?['location']?['coordinates'] ?? [];
    final carId = car['_id'] ?? '';
    final hasHistory =
        car['bookedStatus'] != null && (car['bookedStatus'] as List).isNotEmpty;
    final isExpanded = expandedHistory[carId] ?? false;
    final bookingHistory = car['bookedStatus'] as List? ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color.fromARGB(255, 209, 209, 209),
      child: Column(
        children: [
          // Car Images
          if (car['carImage'] != null && (car['carImage'] as List).isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (car['carImage'] as List).length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        car['carImage'][index],
                        width: 160,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 160,
                            height: 120,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

          ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    '${car['carName'] ?? 'Unknown'}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                if (car['isPremium'] == true)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PREMIUM',
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAvailable ? 'Available' : 'Booked',
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('ID: ${car['_id'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 12)),
                Text('Model: ${car['model'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 12)),
                Text('Number: ${car['vehicleNumber'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        '$branchName - $location',
                        style: TextStyle(
                            fontSize: 12,
                            color: const Color.fromARGB(255, 0, 0, 0)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (coordinates.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '📍 ${coordinates[1]?.toStringAsFixed(4) ?? ''}, ${coordinates[0]?.toStringAsFixed(4) ?? ''}',
                      style: TextStyle(
                          fontSize: 10,
                          color: const Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ),
              ],
            ),
          ),

          // Car Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailChip(
                    Icons.calendar_today, '${car['year'] ?? 'N/A'}'),
                _buildDetailChip(Icons.local_gas_station, car['fuel'] ?? 'N/A'),
                _buildDetailChip(
                    Icons.event_seat, '${car['seats'] ?? 'N/A'} Seats'),
                _buildDetailChip(Icons.settings, car['type'] ?? 'N/A'),
              ],
            ),
          ),

          // Price Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // color: isAvailable ? const Color.fromARGB(255, 236, 236, 236) : Colors.red[50],
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${car['pricePerHour'] ?? 'N/A'}/hour',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isAvailable
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : Colors.red[800],
                      ),
                    ),
                    Text(
                      '₹${car['pricePerDay'] ?? 'N/A'}/day',
                      style: TextStyle(
                        fontSize: 12,
                        color: isAvailable
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : Colors.red[600],
                      ),
                    ),
                  ],
                ),
                if (car['depositOptions'] != null &&
                    (car['depositOptions'] as List).isNotEmpty)
                  Row(
                    children:
                        (car['depositOptions'] as List).take(2).map((option) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          option.toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),

          // Booking History Section
          if (hasHistory)
            Column(
              children: [
                const Divider(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Booking History (${bookingHistory.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () => _showFullHistory(
                                bookingHistory, car['carName'] ?? 'Car'),
                            icon: const Icon(Icons.open_in_full, size: 16),
                            label: const Text('View All'),
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          // IconButton(
                          //   icon: Icon(
                          //     isExpanded ? Icons.expand_less : Icons.expand_more,
                          //     size: 20,
                          //   ),
                          //   onPressed: () => _toggleHistory(carId),
                          //   padding: EdgeInsets.zero,
                          //   constraints: const BoxConstraints(),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isExpanded)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: bookingHistory.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '• ${bookingHistory[index]}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[800],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 2),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
