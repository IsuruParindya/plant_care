import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final professionController = TextEditingController();

  String? selectedGender;
  File? userImage;
  String? base64Image;
  final ImagePicker _picker = ImagePicker();

  InputDecoration buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Future<void> pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        base64Image = base64Encode(bytes);
      } else {
        userImage = File(pickedFile.path);
        final bytes = await userImage!.readAsBytes();
        base64Image = base64Encode(bytes);
      }
      setState(() {});
    }
  }

  Future<void> handleSubmit() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final gender = selectedGender ?? '';
    final profession = professionController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        gender.isEmpty ||
        profession.isEmpty ||
        base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields and upload an image')),
      );
      return;
    }

    final userData = Provider.of<UserData>(context, listen: false);
    userData.update(
      username: name,
      email: email,
      password: password,
      gender: gender,
      profession: profession,
      userImageBase64: base64Image,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User registered successfully!')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Create Your Account 🌿",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green.shade100,
                  backgroundImage: base64Image != null
                      ? MemoryImage(base64Decode(base64Image!))
                      : null,
                  child: base64Image == null
                      ? const Icon(Icons.camera_alt,
                          size: 40, color: Colors.green)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration:
                    buildInputDecoration("Full Name", Icons.person),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration:
                    buildInputDecoration("Email", Icons.email),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration:
                    buildInputDecoration("Password", Icons.lock),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedGender,
                items: ['Male', 'Female', 'Other']
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) =>
                    setState(() => selectedGender = val),
                decoration:
                    buildInputDecoration("Gender", Icons.person_outline),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: professionController,
                decoration: buildInputDecoration(
                    "Profession", Icons.work_outline),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400),
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