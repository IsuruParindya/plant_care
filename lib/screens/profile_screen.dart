import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final UserData userData;

  const ProfileScreen({super.key, required this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController professionController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late String gender;

  final List<String> genderList = ['Male', 'Female', 'Other'];

  ImageProvider<Object> _buildProfileImage() {
    final b64 = widget.userData.userImageBase64;
    if (b64 != null && b64.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(b64));
      } catch (_) {
        // fall through to default
      }
    }
    return const AssetImage('assets/images/default_avatar.png');
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userData.username);
    professionController = TextEditingController(text: widget.userData.profession);
    emailController = TextEditingController(text: widget.userData.email);
    passwordController = TextEditingController(text: widget.userData.password);

    gender = genderList.contains(widget.userData.gender)
        ? widget.userData.gender
        : genderList.first;
  }

  @override
  void dispose() {
    nameController.dispose();
    professionController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _changeProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked == null) return;

    // ✅ Works on Web + Mobile (no dart:io File usage)
    final bytes = await picked.readAsBytes();
    final base64Image = base64Encode(bytes);

    // ✅ Update + persist (update() should be Future<void> in main.dart)
    await widget.userData.update(
      username: nameController.text,
      profession: professionController.text,
      password: passwordController.text,
      gender: gender,
      userImageBase64: base64Image,
    );

    if (!mounted) return;
    setState(() {}); // rebuild this screen immediately

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile image updated!')),
    );
  }

  Future<void> _saveProfile() async {
    await widget.userData.update(
      username: nameController.text,
      profession: professionController.text,
      password: passwordController.text,
      gender: gender,
      userImageBase64: widget.userData.userImageBase64,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile Saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = _buildProfileImage();

    InputDecoration buildInputDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minHeight: 40, minWidth: 40),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black87,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _changeProfileImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImage,
                  backgroundColor: Colors.green.shade100,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tap to change photo',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: buildInputDecoration("Full Name", Icons.person),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: gender,
                items: genderList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => gender = value);
                },
                decoration: buildInputDecoration("Gender", Icons.person_outline),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: professionController,
                decoration: buildInputDecoration("Profession", Icons.work_outline),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                readOnly: true,
                decoration: buildInputDecoration("Email", Icons.email),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: buildInputDecoration("Password", Icons.lock),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}