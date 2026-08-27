import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const LifeLedgerApp());
}

class LifeLedgerApp extends StatelessWidget {
  const LifeLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0a0f1e),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6c8fff),
          secondary: Color(0xFFa78bfa),
        ),

        cardColor: const Color(0xFF121826),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),

        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),

      home: LoginScreen(),
    );
  }
}