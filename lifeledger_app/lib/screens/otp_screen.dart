import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/api_service.dart';
import 'reset_password_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with SingleTickerProviderStateMixin {
  final otpController = TextEditingController();
  bool loading = false;

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    otpController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> verifyOtp() async {
    setState(() {
      loading = true;
    });

    final res = await ApiService.verifyOtp(
      widget.email,
      otpController.text,
    );

    setState(() {
      loading = false;
    });

    if (res["status"] == "success") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            email: widget.email,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res["message"]?.toString() ?? "Invalid OTP"),
          backgroundColor: const Color(0xFF1e2a4a),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF061019), Color(0xFF0a1a2e), Color(0xFF0d1533)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, _) => CustomPaint(
                painter: _OceanWavePainter(_waveController.value),
                size: Size.infinite,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 60, spreadRadius: 10),
                    ],
                  ),
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF38bdf8), Color(0xFF6366f1)]),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF38bdf8).withOpacity(0.4), blurRadius: 20, spreadRadius: 1),
                          ],
                        ),
                        child: const Icon(Icons.security_rounded, color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 20),
                      const Text("Verify OTP",
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text("OTP sent to\n${widget.email}",
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                      const SizedBox(height: 26),
                      Text("OTP CODE",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 6),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: "• • • • • •",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), letterSpacing: 6),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.12))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.12))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF7dd3fc), width: 1.5)),
                        ),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF38bdf8), Color(0xFF6366f1)]),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF38bdf8).withOpacity(0.4), blurRadius: 20, spreadRadius: 1),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: loading ? null : verifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Verify OTP →",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OceanWavePainter extends CustomPainter {
  final double t;
  _OceanWavePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    _drawWaveLayer(canvas, size, baseHeight: size.height * 0.72, amplitude: 18, speed: 1.0, color: const Color(0xFF1e3a5f).withOpacity(0.55));
    _drawWaveLayer(canvas, size, baseHeight: size.height * 0.80, amplitude: 24, speed: 1.6, color: const Color(0xFF14304d).withOpacity(0.6));
    _drawWaveLayer(canvas, size, baseHeight: size.height * 0.90, amplitude: 14, speed: 0.7, color: const Color(0xFF0b2038).withOpacity(0.75));
  }

  void _drawWaveLayer(Canvas canvas, Size size,
      {required double baseHeight, required double amplitude, required double speed, required Color color}) {
    final path = Path();
    final phase = t * 2 * math.pi * speed;
    path.moveTo(0, baseHeight);
    for (double x = 0; x <= size.width; x += 4) {
      final y = baseHeight + amplitude * math.sin((x / size.width * 2 * math.pi) + phase);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _OceanWavePainter oldDelegate) => oldDelegate.t != t;
}