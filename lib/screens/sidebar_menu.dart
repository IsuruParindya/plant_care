import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'home_screen.dart';
import 'sign_in_screen.dart';

class SidebarMenu extends StatelessWidget {
  final VoidCallback onProfileTap;

  const SidebarMenu({
    super.key,
    required this.onProfileTap,
    required String username, required Null Function() onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserData>(
      builder: (context, userData, _) {
        final userImage = userData.avatarImage;

        return Drawer(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30),
                CircleAvatar(
                  radius: 45,
                  backgroundImage: userImage,
                  backgroundColor: Colors.grey[200],
                  child: userImage == null
                      ? const Icon(Icons.person, size: 45, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  userData.username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),

                // Home
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                ),

                // Profile
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Profile'),
                  onTap: onProfileTap,
                ),

                const Spacer(),
                const Divider(),

                // Logout
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}