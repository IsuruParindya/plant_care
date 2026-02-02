import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_care/db/db_helper.dart';

class AddNewPlantScreen extends StatefulWidget {
  const AddNewPlantScreen({super.key});

  @override
  State<AddNewPlantScreen> createState() => _AddNewPlantScreenState();
}

class _AddNewPlantScreenState extends State<AddNewPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _wateringController = TextEditingController();
  final TextEditingController _lightController = TextEditingController();
  final TextEditingController _fertilizingController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();

  File? _selectedImage;
  Uint8List? _webImageBytes;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() => _webImageBytes = bytes);
      } else {
        setState(() => _selectedImage = File(picked.path));
      }
    }
  }

  Future<void> _savePlant() async {
    if (_selectedImage == null && _webImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final imageBase64 = kIsWeb
        ? base64Encode(_webImageBytes!)
        : base64Encode(await _selectedImage!.readAsBytes());

    final newPlant = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'careInfo': {
        'watering': _wateringController.text.trim(),
        'light': _lightController.text.trim(),
        'fertilizing': _fertilizingController.text.trim(),
        'humidity': _humidityController.text.trim(),
      },
      'image': imageBase64,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Insert plant in DB
    await DBHelper().insertPlant(newPlant);

    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plant added successfully!')),
    );

    // ✅ Pop and return true so PlantGridScreen reloads
    Navigator.pop(context, true);
  }

  Widget _buildImagePreview() {
    if (kIsWeb && _webImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          _webImageBytes!,
          width: 140,
          height: 140,
          fit: BoxFit.cover,
        ),
      );
    } else if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          _selectedImage!,
          width: 140,
          height: 140,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black26),
      ),
      child: const Icon(Icons.add_a_photo, color: Colors.black45, size: 40),
    );
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
          "Add New Plant",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(onTap: _pickImage, child: _buildImagePreview()),
                const SizedBox(height: 20),
                _buildTextField(_nameController, "Plant Name"),
                const SizedBox(height: 14),
                _buildTextField(_descriptionController, "Description", maxLines: 2),
                const SizedBox(height: 14),
                _buildTextField(_wateringController, "Watering instructions"),
                const SizedBox(height: 14),
                _buildTextField(_lightController, "Light requirement"),
                const SizedBox(height: 14),
                _buildTextField(_fertilizingController, "Fertilizing info"),
                const SizedBox(height: 14),
                _buildTextField(_humidityController, "Humidity level"),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _savePlant,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC8E6C9),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Save Plant",
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black87),
      validator: (value) => value!.isEmpty ? "Please enter $label" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
    );
  }
}