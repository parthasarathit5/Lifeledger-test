import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(LifeLedgerApp());
}

class LifeLedgerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeLedger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF0a0f1e),
        fontFamily: 'sans-serif',
      ),
      home: LoginScreen(),
    );
  }
}