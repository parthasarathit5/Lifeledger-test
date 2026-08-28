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
      title: 'LifeLedger AI',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF059669), // Rich Emerald Green
          secondary: Color(0xFF10B981), // Vivid Mint Green
          tertiary: Color(0xFFF59E0B), // Sunset Orange
          surface: Colors.white,
          onPrimary: Colors.white,
          onSurface: Color(0xFF0F172A), // Deep Slate
        ),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF0F172A)),
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF0F172A)),
          bodyMedium: TextStyle(color: Color(0xFF334155)),
          titleLarge: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
      ),
      home: LoginScreen(),
    );
  }
}