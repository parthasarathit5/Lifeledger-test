import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  final int userId;

  const NotificationsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: const Center(
        child: Text("No notifications yet 🔔"),
      ),
    );
  }
}