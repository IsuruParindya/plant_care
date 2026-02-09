import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/sign_in_screen.dart';

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

/// Reactive user data class
class UserData extends ChangeNotifier {
  String username;
  String email;
  String password;
  String dob;
  String gender;
  String profession;

  /// Store profile image as Base64 (works across mobile + web)
  String? userImageBase64;

  /// Optional local File (only useful on mobile/desktop; not persisted)
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

  /// Load user data from SharedPreferences
  static Future<UserData> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return UserData(
      username: prefs.getString('loggedInUsername') ?? '',
      email: prefs.getString('loggedInEmail') ?? '',
      password: prefs.getString('loggedInPassword') ?? '',
      dob: prefs.getString('loggedInDob') ?? '',
      gender: prefs.getString('loggedInGender') ?? '',
      profession: prefs.getString('loggedInProfession') ?? '',
      userImageBase64: prefs.getString('loggedInUserBase64') ?? '',
    );
  }

  /// Save current user data to SharedPreferences
  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loggedInUsername', username);
    await prefs.setString('loggedInEmail', email);
    await prefs.setString('loggedInPassword', password);
    await prefs.setString('loggedInDob', dob);
    await prefs.setString('loggedInGender', gender);
    await prefs.setString('loggedInProfession', profession);

    // ✅ Always store (even if empty string) so updates overwrite old value
    await prefs.setString('loggedInUserBase64', userImageBase64 ?? '');
  }

  /// ✅ Update user data, notify UI immediately, then persist (awaited)
  Future<void> update({
    String? username,
    String? email,
    String? password,
    String? dob,
    String? gender,
    String? profession,
    String? userImageBase64,
    File? userImage,
  }) async {
    if (username != null) this.username = username;
    if (email != null) this.email = email;
    if (password != null) this.password = password;
    if (dob != null) this.dob = dob;
    if (gender != null) this.gender = gender;
    if (profession != null) this.profession = profession;

    if (userImageBase64 != null) this.userImageBase64 = userImageBase64;
    if (userImage != null) this.userImage = userImage;

    // ✅ Refresh UI now
    notifyListeners();

    // ✅ Persist changes (and WAIT for it)
    await saveToPrefs();
  }

  /// Get profile image for UI
  ImageProvider<Object>? get avatarImage {
    try {
      final b64 = userImageBase64;
      if (b64 != null && b64.isNotEmpty) {
        return MemoryImage(base64Decode(b64));
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