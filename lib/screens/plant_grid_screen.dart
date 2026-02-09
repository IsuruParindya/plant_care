import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../db/db_helper.dart';
import 'profile_screen.dart';
import 'sidebar_menu.dart';
import 'plant_detail_screen.dart';
import 'add_new_plant_screen.dart';

class PlantGridScreen extends StatefulWidget {
  const PlantGridScreen({
    super.key,
    required this.username,
    this.userImage,
    this.userImageBase64,
  });

  final String username;
  final File? userImage;
  final String? userImageBase64;

  @override
  State<PlantGridScreen> createState() => _PlantGridScreenState();
}

class _PlantGridScreenState extends State<PlantGridScreen> {
  List<Map<String, dynamic>> plants = [];

  @override
  void initState() {
    super.initState();
    _loadPlantsFromDB();
  }

  // Load all plants from DB
  Future<void> _loadPlantsFromDB() async {
    final allPlants = await DBHelper().getAllPlants();
    setState(() => plants = allPlants);
  }

  // Delete a plant
  Future<void> _deletePlant(String plantId) async {
    await DBHelper().deletePlant(plantId);
    _loadPlantsFromDB(); // reload after deletion
  }

  void _openProfilePage(BuildContext context, UserData userData) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen(userData: userData)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserData>(
      builder: (context, userData, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFE6F2E9),
          endDrawer: SidebarMenu(
            username: userData.username,
            onProfileTap: () {
              Navigator.of(context).pop();
              _openProfilePage(context, userData);
            },
            onLogout: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
          floatingActionButton: FloatingActionButton(
  onPressed: () async {
    // Open AddNewPlantScreen and wait for the result
    final bool? added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddNewPlantScreen()),
    );

    // If a plant was successfully added, reload plants
    if (added == true) {
      await _loadPlantsFromDB();
    }
  },
  child: const Icon(Icons.add),
),

          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Row(
                        children: [
                          Text(
                            "Hello, ${userData.username}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Builder(
                            builder: (scaffoldContext) => InkWell(
                              onTap: () => Scaffold.of(scaffoldContext).openEndDrawer(),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage: userData.avatarImage,
                                backgroundColor: const Color(0xFFE6F2E9),
                                child: userData.avatarImage == null
                                    ? const Icon(Icons.person, color: Colors.green)
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      itemCount: plants.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      itemBuilder: (context, index) {
                        final plant = plants[index];
                        final imageData = plant['image'] as String;
                        Widget plantImage;

                        try {
                          final bytes = base64Decode(imageData);
                          plantImage = Image.memory(bytes, fit: BoxFit.cover, width: double.infinity);
                        } catch (_) {
                          if (imageData.startsWith('http')) {
                            plantImage = Image.network(imageData, fit: BoxFit.cover, width: double.infinity);
                          } else {
                            plantImage = Image.asset(imageData, fit: BoxFit.cover, width: double.infinity);
                          }
                        }

                        return Stack(
                          children: [
                            InkWell(
                              onTap: () async {
                                final updated = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlantDetailScreen(
                                      id: plant['id'] as String,
                                      name: plant['name'] as String,
                                      image: imageData,
                                      careInfo: Map<String, String>.from(plant['careInfo']),
                                      description: plant['description'] as String? ?? '',
                                    ),
                                  ),
                                );

                                if (updated == true) {
                                  _loadPlantsFromDB(); // refresh after edit
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: plantImage,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      plant['name'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Indoor Plant",
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _deletePlant(plant['id'] as String),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(Icons.delete, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}