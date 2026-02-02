import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sign_in_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userData = await UserData.loadFromPrefs();

  runApp(
    ChangeNotifierProvider<UserData>.value(
      value: userData,
      child: const PlantCareApp(),
    ),
  );
}

class UserData extends ChangeNotifier {
  String username;
  String email;
  String password;
  String dob;
  String gender;
  String profession;
  String? userImageBase64;
  File? userImage;

  UserData({
    required this.username,
    required this.email,
    required this.password,
    required this.dob,
    required this.gender,
    required this.profession,
    this.userImageBase64,
    this.userImage,
  });

  static Future<UserData> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return UserData(
      username: prefs.getString('loggedInUsername') ?? '',
      email: prefs.getString('loggedInEmail') ?? '',
      password: prefs.getString('loggedInPassword') ?? '',
      dob: prefs.getString('loggedInDob') ?? '',
      gender: prefs.getString('loggedInGender') ?? '',
      profession: prefs.getString('loggedInProfession') ?? '',
      userImageBase64: prefs.getString('loggedInUserBase64'),
    );
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loggedInUsername', username);
    await prefs.setString('loggedInEmail', email);
    await prefs.setString('loggedInPassword', password);
    await prefs.setString('loggedInDob', dob);
    await prefs.setString('loggedInGender', gender);
    await prefs.setString('loggedInProfession', profession);
    if (userImageBase64 != null) {
      await prefs.setString('loggedInUserBase64', userImageBase64!);
    }
    notifyListeners();
  }

  void update({
    String? username,
    String? email,
    String? password,
    String? dob,
    String? gender,
    String? profession,
    String? userImageBase64,
    File? userImage,
  }) {
    if (username != null) this.username = username;
    if (email != null) this.email = email;
    if (password != null) this.password = password;
    if (dob != null) this.dob = dob;
    if (gender != null) this.gender = gender;
    if (profession != null) this.profession = profession;
    if (userImageBase64 != null) this.userImageBase64 = userImageBase64;
    if (userImage != null) this.userImage = userImage;
    saveToPrefs();
  }

  ImageProvider<Object>? get avatarImage {
    try {
      if (userImageBase64 != null && userImageBase64!.isNotEmpty) {
        return MemoryImage(base64Decode(userImageBase64!));
      } else if (userImage != null && userImage!.existsSync()) {
        return FileImage(userImage!);
      }
    } catch (_) {}
    return null;
  }
}

class PlantCareApp extends StatelessWidget {
  const PlantCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plant Care Log',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const SignInScreen(),
    );
  }
}