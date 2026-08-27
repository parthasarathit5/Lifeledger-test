import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  final int userId;

  const ReportScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: const Center(
        child: Text("Reports coming soon 📊"),
      ),
    );
  }
}