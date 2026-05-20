
import 'package:flutter/material.dart';

class FilterBox extends StatefulWidget {
  const FilterBox({super.key});

  @override
  _FilterBoxState createState() => _FilterBoxState();
}

class _FilterBoxState extends State<FilterBox> {
  String selectedType = 'Manual';
  String selectedFuel = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15,right: 5),
      child: Container(
        height: 321,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
                alignment: Alignment.centerLeft,
                child: Text("Type", style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Manual', 'Automatic'].map((type) {
                bool isSelected = selectedType == type;
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedType = type);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0000FE) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Text(type,
                        style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text("Fuel", style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Petrol', 'Diesel'].map((fuel) {
                bool isSelected = selectedFuel == fuel;
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedFuel = fuel);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0000FE) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Text(fuel,
                        style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 60),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.blue, Colors.indigo]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Apply", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}