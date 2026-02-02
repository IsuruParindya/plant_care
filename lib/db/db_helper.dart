import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  final String _usersKey = "users";
  final String _plantsKey = "plants";

  // =====================================================
  // ✅ USER FUNCTIONS
  // =====================================================

  /// Insert a new user
  Future<bool> insertUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    final usersList = prefs.getStringList(_usersKey) ?? [];

    // prevent duplicate email registration
    final emailExists = usersList.any((u) {
      final existingUser = json.decode(u);
      return existingUser['email'] == user['email'];
    });

    if (emailExists) return false;

    usersList.add(json.encode(user));
    await prefs.setStringList(_usersKey, usersList);
    return true;
  }

  /// Get user by email & password
  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersList = prefs.getStringList(_usersKey) ?? [];

    for (var u in usersList) {
      final user = json.decode(u);
      if (user['email'] == email && user['password'] == password) {
        return user;
      }
    }
    return null;
  }

  /// Get user by email only
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final usersList = prefs.getStringList(_usersKey) ?? [];

    for (var u in usersList) {
      final user = json.decode(u);
      if (user['email'] == email) return user;
    }
    return null;
  }

  /// Update user
  Future<bool> updateUser(Map<String, dynamic> updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    final usersList = prefs.getStringList(_usersKey) ?? [];
    bool updated = false;

    for (int i = 0; i < usersList.length; i++) {
      final user = json.decode(usersList[i]);
      if (user['email'] == updatedUser['email']) {
        usersList[i] = json.encode(updatedUser);
        updated = true;
        break;
      }
    }

    if (updated) {
      await prefs.setStringList(_usersKey, usersList);
    }

    return updated;
  }

  /// Update only the user's profile image
  Future<bool> updateUserImage(String email, String imageBase64) async {
    final user = await getUserByEmail(email);
    if (user == null) return false;

    user['imageBase64'] = imageBase64;
    return await updateUser(user);
  }

  /// Clear all users
  Future<void> clearUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
  }

  // =====================================================
  // ✅ PLANT FUNCTIONS
  // =====================================================

  /// Insert a new plant
  /// Only inserts if no duplicate plant with same name & createdAt exists
  Future<void> insertPlant(Map<String, dynamic> plant) async {
    final prefs = await SharedPreferences.getInstance();
    final plantList = prefs.getStringList(_plantsKey) ?? [];

    // Assign a unique ID if not already assigned
    if (plant['id'] == null) {
      plant['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    }

    // Prevent accidental duplicate by checking name + description + createdAt
    final duplicate = plantList.any((p) {
      final existing = json.decode(p);
      return existing['name'] == plant['name'] &&
          existing['description'] == plant['description'] &&
          existing['createdAt'] == plant['createdAt'];
    });

    if (duplicate) return; // skip insertion if duplicate

    plantList.add(json.encode(plant));
    await prefs.setStringList(_plantsKey, plantList);
  }

  /// Get all plants
  Future<List<Map<String, dynamic>>> getAllPlants() async {
    final prefs = await SharedPreferences.getInstance();
    final plantList = prefs.getStringList(_plantsKey) ?? [];

    return plantList
        .map((p) => json.decode(p) as Map<String, dynamic>)
        .toList();
  }

  /// Delete plant by ID
  Future<bool> deletePlant(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final plantList = prefs.getStringList(_plantsKey) ?? [];

    final updatedList = plantList.where((p) {
      final plant = json.decode(p);
      return plant['id'] != id;
    }).toList();

    await prefs.setStringList(_plantsKey, updatedList);
    return updatedList.length != plantList.length;
  }

  /// Update existing plant
  Future<bool> updatePlant(Map<String, dynamic> updatedPlant) async {
    final prefs = await SharedPreferences.getInstance();
    final plantList = prefs.getStringList(_plantsKey) ?? [];
    bool updated = false;

    for (int i = 0; i < plantList.length; i++) {
      final plant = json.decode(plantList[i]);
      if (plant['id'] == updatedPlant['id']) {
        plantList[i] = json.encode(updatedPlant);
        updated = true;
        break;
      }
    }

    if (updated) {
      await prefs.setStringList(_plantsKey, plantList);
    }

    return updated;
  }

  /// Clear all plants
  Future<void> clearPlants() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_plantsKey);
  }
}