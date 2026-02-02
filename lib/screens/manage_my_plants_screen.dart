import 'package:flutter/material.dart';

class ManageMyPlantsScreen extends StatefulWidget {
  const ManageMyPlantsScreen({super.key});

  @override
  State<ManageMyPlantsScreen> createState() => _ManageMyPlantsScreenState();
}

class _ManageMyPlantsScreenState extends State<ManageMyPlantsScreen> {
  // Temporary plant list – replace later with data from provider or DB
  final List<Map<String, String>> _myPlants = [
    {"name": "Aloe Vera", "image": "assets/images/plant1.jpg"},
    {"name": "Snake Plant", "image": "assets/images/plant3.jpg"},
    {"name": "Peace Lily", "image": "assets/images/plant4.jpg"},
  ];

  void _deletePlant(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C4734),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Delete plant?",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        ),
        content: Text(
          "Are you sure you want to remove '${_myPlants[index]['name']}'?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _myPlants.removeAt(index);
              });
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E2E23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Manage My Plants",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: _myPlants.length,
          itemBuilder: (context, index) {
            final plant = _myPlants[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1C4734),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    plant['image']!,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  plant['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _deletePlant(index),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}