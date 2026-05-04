import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:varahiowner/helpers/toast_helper.dart';
import 'package:varahiowner/model/Mycar/car_model.dart';
import 'package:varahiowner/providers/car_provider.dart';

import 'package:varahiowner/views/add_car_screen.dart';
import 'package:varahiowner/views/edit_car_screen.dart';

class MyCarsScreen extends StatefulWidget {
  const MyCarsScreen({super.key});

  @override
  State<MyCarsScreen> createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to call after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCars();
    });
  }

  Future<void> _loadCars() async {
    final provider = Provider.of<CarProvider>(context, listen: false);
    final success = await provider.fetchMyCars();
    if (!success && mounted) {
      ToastHelper.showError(context, provider.errorMessage);
    }
  }

  Future<void> _onRefresh() async {
    await _loadCars();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CarProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111110) : const Color(0xFFF7F7F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF111110) : const Color(0xFFF7F7F5),
        elevation: 0,
        title: const Text(
          'My Vehicles',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          // Add car button in app bar
          IconButton(
            icon: Icon(Icons.add_circle_outline, 
              color: isDark ? Colors.white : const Color(0xFF1D9E75)),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddCarScreen()),
              );
              if (result == true) {
                _loadCars();
              }
            },
            tooltip: 'Add New Car',
          ),
        ],
      ),
      body: provider.isLoading && _isFirstLoad
          ? const Center(child: CircularProgressIndicator())
          : provider.myCars.isEmpty
              ? _buildEmptyState(isDark, context)
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.myCars.length,
                    itemBuilder: (context, index) {
                      final car = provider.myCars[index];
                      return _CarCard(
                        car: car,
                        isDark: isDark,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditCarScreen(carId: car.id!),
                            ),
                          );
                          if (result == true) {
                            _loadCars();
                          }
                        },
                      );
                    },
                  ),
                ),
      // Floating action button for add car
      floatingActionButton: provider.myCars.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCarScreen()),
                );
                if (result == true) {
                  _loadCars();
                }
              },
              backgroundColor: const Color(0xFF1D9E75),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add New Car',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState(bool isDark, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions,
            size: 80,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No vehicles added yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first vehicle to get started',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddCarScreen()),
              );
              if (result == true) {
                _loadCars();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Car'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D9E75),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarCard extends StatelessWidget {
  final CarModel car;
  final bool isDark;
  final VoidCallback onTap;

  const _CarCard({
    required this.car,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1C1C1A) : Colors.white;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: car.carImage.isNotEmpty
                  ? Image.network(
                      car.carImage.first,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 160,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, size: 50),
                      ),
                    )
                  : Container(
                      height: 160,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.directions_car, size: 50),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${car.carName} ${car.model}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(car.runningStatus).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          car.runningStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(car.runningStatus),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.local_gas_station_outlined,
                          size: 14, color: isDark ? Colors.white54 : Colors.black54),
                      const SizedBox(width: 4),
                      Text(car.fuel, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
                      const SizedBox(width: 16),
                      Icon(Icons.event_seat_outlined,
                          size: 14, color: isDark ? Colors.white54 : Colors.black54),
                      const SizedBox(width: 4),
                      Text('${car.seats} seats', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
                      const SizedBox(width: 16),
                      Icon(Icons.speed_outlined,
                          size: 14, color: isDark ? Colors.white54 : Colors.black54),
                      const SizedBox(width: 4),
                      Text(car.carType, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.tag_outlined,
                          size: 14, color: isDark ? Colors.white54 : Colors.black54),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          car.vehicleNumber,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price per day',
                              style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38)),
                          Text('₹${car.pricePerDay}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1D9E75))),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price per hour',
                              style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38)),
                          Text('₹${car.pricePerHour}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1D9E75))),
                        ],
                      ),
                      if (car.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D9E75).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.star, size: 12, color: Color(0xFF1D9E75)),
                              SizedBox(width: 4),
                              Text('Premium', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF1D9E75))),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return const Color(0xFF4CAF50);
      case 'booked':
        return const Color(0xFFFF9800);
      case 'maintenance':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}