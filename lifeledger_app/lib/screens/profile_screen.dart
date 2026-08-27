import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final int userId;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Profile")),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            // 👤 USER INFO
            CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),

            SizedBox(height: 10),

            Text(
              userName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Text("User ID: $userId"),

            SizedBox(height: 30),

            // ⚙ SETTINGS
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsScreen()),
                );
              },
            ),

            // 🔐 LOGOUT
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}