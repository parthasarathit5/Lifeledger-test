import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;
  bool otpSent = false;
  bool passwordResetSuccess = false;
  String generatedOtp = "";
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> sendOtp() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your registered email address"),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final res = await ApiService.forgotPassword(email);

      if (!mounted) return;
      setState(() => loading = false);

      if (res["status"] == "success") {
        final otp = (res["otp"] ?? res["otp_preview"] ?? "").toString();
        setState(() {
          otpSent = true;
          generatedOtp = otp;
          if (otp.isNotEmpty) {
            otpController.text = otp; // Pre-fill for instant seamless verification
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(otp.isNotEmpty ? "✅ OTP Generated: $otp" : "✅ OTP sent to $email"),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 8),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res["message"] ?? "Account not found with this email"),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> verifyOtpAndReset() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (otp.isEmpty || otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the 6-digit OTP code"), backgroundColor: Color(0xFFEF4444)),
      );
      return;
    }

    if (newPass.isEmpty || newPass.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 4 characters"), backgroundColor: Color(0xFFEF4444)),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match"), backgroundColor: Color(0xFFEF4444)),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // 1. Verify OTP
      final verifyRes = await ApiService.verifyOtp(email, otp);

      if (verifyRes["status"] == "success") {
        // 2. Reset Password
        final resetRes = await ApiService.resetPassword(email, newPass);

        if (!mounted) return;
        setState(() => loading = false);

        if (resetRes["status"] == "success") {
          setState(() => passwordResetSuccess = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("🎉 Password updated successfully! Please login."),
              backgroundColor: Color(0xFF059669),
              duration: Duration(seconds: 4),
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resetRes["message"] ?? "Failed to reset password"), backgroundColor: const Color(0xFFEF4444)),
          );
        }
      } else {
        if (!mounted) return;
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(verifyRes["message"] ?? "Invalid OTP code"), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: const Color(0xFFEF4444)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Pure white background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Password Recovery",
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              children: [
                // Top Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4), width: 1.5),
                  ),
                  child: const Icon(Icons.lock_reset, color: Color(0xFF059669), size: 32),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Reset Your Password",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                ),
                const SizedBox(height: 4),
                Text(
                  otpSent
                      ? "Enter the 6-digit OTP and choose your new password."
                      : "Enter your registered email address to receive your 6-digit OTP code.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                ),
                const SizedBox(height: 20),

                // OTP Display Card if generated
                if (otpSent && generatedOtp.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF10B981), width: 1.3),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.vpn_key, color: Color(0xFF059669), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Your 6-Digit OTP Code", style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 12)),
                              Text(generatedOtp, style: const TextStyle(color: Color(0xFF047857), fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 4)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text("AUTO-FILLED", style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                // Step 1 / Step 2 Light Green Form Box
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5), // Light Green Box
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF10B981), width: 1.3),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF10B981).withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email Field
                      const Text("Registered Email Address", style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: emailController,
                        enabled: !otpSent,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "e.g. yourname@gmail.com",
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF059669), size: 18),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFA7F3D0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFA7F3D0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5)),
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (!otpSent) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: loading ? null : sendOtp,
                            child: loading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Send 6-Digit OTP", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ] else ...[
                        // Step 2 Fields: OTP, New Password, Confirm Password
                        const Text("6-Digit OTP Code", style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF047857), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 4),
                          decoration: InputDecoration(
                            hintText: "Enter 6-digit OTP",
                            prefixIcon: const Icon(Icons.pin, color: Color(0xFF059669), size: 18),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFA7F3D0))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFA7F3D0))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5)),
                          ),
                        ),
                        const SizedBox(height: 14),

                        const Text("New Password", style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: newPasswordController,
                          obscureText: obscurePassword,
                          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Enter new password",
                            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF059669), size: 18),
                            suffixIcon: IconButton(
                              icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF64748B), size: 18),
                              onPressed: () => setState(() => obscurePassword = !obscurePassword),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFA7F3D0))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFA7F3D0))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5)),
                          ),
                        ),
                        const SizedBox(height: 14),

                        const Text("Confirm New Password", style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: obscurePassword,
                          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Re-enter new password",
                            prefixIcon: const Icon(Icons.lock_clock_outlined, color: Color(0xFF059669), size: 18),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFA7F3D0))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFA7F3D0))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5)),
                          ),
                        ),
                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: loading ? null : verifyOtpAndReset,
                            child: loading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Verify OTP & Reset Password", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: TextButton(
                            onPressed: () => setState(() => otpSent = false),
                            child: const Text("Change Email Address", style: TextStyle(color: Color(0xFF059669), fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Back to Login Link
                TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen())),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, color: Color(0xFF059669), size: 16),
                      SizedBox(width: 6),
                      Text("Back to Login", style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}