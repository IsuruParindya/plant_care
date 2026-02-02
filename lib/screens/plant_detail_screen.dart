import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:plant_care/db/db_helper.dart';

class PlantDetailScreen extends StatefulWidget {
  final String id;
  final String name;
  final String image;
  final Map<String, String> careInfo;
  final String description;

  const PlantDetailScreen({
    super.key,
    required this.id,
    required this.name,
    required this.image,
    required this.careInfo,
    required this.description,
  });

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late Map<String, String> editableCareInfo;

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    descriptionController = TextEditingController(text: widget.description);
    editableCareInfo = Map.from(widget.careInfo);
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _editCareStep(String key) async {
    final controller = TextEditingController(text: editableCareInfo[key]);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit ${key[0].toUpperCase()}${key.substring(1)}"),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        editableCareInfo[key] = result;
      });
    }
  }

  Future<void> _saveAll() async {
    final updatedPlant = {
      'id': widget.id,
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'careInfo': editableCareInfo,
      'image': widget.image,
    };

    bool success = await DBHelper().updatePlant(updatedPlant);

    if (success) {
      setState(() => isEditing = false);

      // Notify user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Plant details saved")),
      );

      // Pop back to Plant Grid and notify it to refresh
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save changes")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F2E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Diagnosis result",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Plant Info ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImage(widget.image),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isEditing
                            ? TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                ),
                              )
                            : Text(
                                nameController.text,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                        const SizedBox(height: 6),
                        isEditing
                            ? TextField(
                                controller: descriptionController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                ),
                              )
                            : Text(
                                descriptionController.text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // --- Steps Care Header + Edit Icon ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Steps care",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isEditing ? Icons.close : Icons.edit,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      setState(() {
                        isEditing = !isEditing;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --- Care Steps ---
              ...editableCareInfo.entries.map((entry) {
                final RegExp percentReg = RegExp(r'(\d{1,3})%');
                final match = percentReg.firstMatch(entry.value);
                final percent =
                    match != null ? int.parse(match.group(1)!) : 70;

                return GestureDetector(
                  onTap: isEditing ? () => _editCareStep(entry.key) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _careStep(entry.key, entry.value, percent),
                  ),
                );
              }),

              if (isEditing) ...[
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- Image builder ---
  Widget _buildImage(String imageStr) {
    try {
      final base64Str =
          imageStr.contains(',') ? imageStr.split(',')[1] : imageStr;
      final bytes = base64Decode(base64Str);
      return Image.memory(bytes, height: 80, width: 80, fit: BoxFit.cover);
    } catch (_) {
      return Image.asset(imageStr,
          height: 80, width: 80, fit: BoxFit.cover);
    }
  }

  // --- Care Step UI ---
  Widget _careStep(String title, String value, int percentage) {
    IconData icon;
    switch (title.toLowerCase()) {
      case "watering":
        icon = Icons.water_drop;
        break;
      case "light":
        icon = Icons.light_mode;
        break;
      case "fertilizing":
        icon = Icons.grass;
        break;
      case "repotting":
        icon = Icons.local_florist;
        break;
      case "humidity":
        icon = Icons.cloud;
        break;
      default:
        icon = Icons.eco;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFC8E6C9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title[0].toUpperCase() + title.substring(1),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Container(
                      height: 8,
                      width: (percentage / 100) * 220,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text("$percentage%"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}