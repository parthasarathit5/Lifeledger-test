import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
void loginUser() async {
  if (emailController.text.isEmpty ||
      passwordController.text.isEmpty) {
    _showSnack("Please fill in all fields");
    return;
  }

  setState(() => _isLoading = true);

  try {
    var url = Uri.parse("https://lifeledger-backend.onrender.com/login/");

    var response = await http
        .post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": emailController.text.trim(),
            "password": passwordController.text.trim(),
          }),
        )
         .timeout(Duration(seconds: 180));

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            userName: data["name"] ?? "",
            userId: data["user_id"],
          ),
        ),
      );
    } else {
      _showSnack(data["message"] ?? "Login failed");
    }
  }catch (e) {
  print("ERROR: $e");
  _showSnack("Server is starting, please wait and try again...");
}finally {
    setState(() => _isLoading = false);
  }
}
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Color(0xFF1e2a4a),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0a0f1e), Color(0xFF101828), Color(0xFF0d1533)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBrand(),
                  SizedBox(height: 40),
                  _buildCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6c8fff), Color(0xFFa78bfa)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF6c8fff).withOpacity(0.45),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(Icons.account_balance_wallet, color: Colors.white, size: 36),
        ),
        SizedBox(height: 16),
        Text(
          "LifeLedger",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Your personal life companion",
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
      padding: EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome back",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Sign in to manage your life",
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 13,
            ),
          ),
          SizedBox(height: 28),
          _buildInput(
            controller: emailController,
            label: "EMAIL ADDRESS",
            hint: "you@example.com",
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 16),
          _buildInput(
            controller: passwordController,
            label: "PASSWORD",
            hint: "Enter your password",
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            isVisible: _passwordVisible,
            onToggle: () => setState(() => _passwordVisible = !_passwordVisible),
          ),
          SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Forgot password?",
              style: TextStyle(
                color: Color(0xFF6c8fff),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 28),
          _buildPrimaryButton("Sign In →", loginUser),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "or",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3), fontSize: 12),
                ),
              ),
              Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
            ],
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.45), fontSize: 13),
              ),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => SignupScreen()),
                ),
                child: Text(
                  "Create one",
                  style: TextStyle(
                    color: Color(0xFF6c8fff),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && !isVisible,
          keyboardType: keyboardType,
          style: TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
            prefixIcon:
                Icon(icon, color: Colors.white.withOpacity(0.4), size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isVisible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white.withOpacity(0.4),
                      size: 20,
                    ),
                    onPressed: onToggle,
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF6c8fff), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6c8fff), Color(0xFFa78bfa)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF6c8fff).withOpacity(0.35),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}