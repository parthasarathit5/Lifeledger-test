import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AlertsScreen extends StatefulWidget {
  final int userId;

  const AlertsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  bool loading = true;
  List alerts = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);

    try {
      final res = await ApiService.getAlerts(widget.userId);

      setState(() {
        alerts = res["alerts"] ?? [];
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Color getColor(String type) {
    switch (type) {
      case "danger":
        return const Color(0xFFf87171);
      case "success":
        return const Color(0xFF4ade80);
      case "warning":
        return const Color(0xFFfbbf24);
      default:
        return const Color(0xFF6c8fff);
    }
  }

  IconData getIcon(String type) {
    switch (type) {
      case "danger":
        return Icons.error_outline_rounded;
      case "success":
        return Icons.check_circle_outline_rounded;
      case "warning":
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0a0f1e), Color(0xFF101828), Color(0xFF0d1533)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: load,
            child: Column(
              children: [
                // Custom header, consistent with Mood/Summary screens
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text("AI Alerts",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),

                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF6c8fff)))
                      : alerts.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 100),
                                const Center(child: Text("🔔", style: TextStyle(fontSize: 48))),
                                const SizedBox(height: 14),
                                Center(
                                  child: Text("No alerts available",
                                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
                                ),
                                const SizedBox(height: 6),
                                Center(
                                  child: Text("Pull down to refresh",
                                      style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 12)),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                              itemCount: alerts.length,
                              itemBuilder: (context, index) {
                                final a = alerts[index];
                                final color = getColor(a["type"] ?? "info");

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.05),
                                        Colors.white.withOpacity(0.02),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: color.withOpacity(0.25)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withOpacity(0.15),
                                        blurRadius: 20,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Icon(
                                          getIcon(a["type"] ?? "info"),
                                          color: color,
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              a["title"] ?? "",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              a["message"] ?? "",
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.65),
                                                fontSize: 13.5,
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
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