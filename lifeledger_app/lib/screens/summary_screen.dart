import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  final double income = 50000;
  final double expenses = 32000;
  final int habits = 24;
  final int productivity = 72;

  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savings = income - expenses;
    final expenseRatio = (expenses / income * 100);

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
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
                    const Text("Smart Summary",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 28),

                // Hero savings card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4ade80), Color(0xFF22c55e)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF4ade80).withOpacity(0.3), blurRadius: 24, spreadRadius: 2),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Monthly Savings",
                              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                          const SizedBox(height: 6),
                          Text("₹${savings.toStringAsFixed(0)}",
                              style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text("Income ₹${income.toStringAsFixed(0)} − Expenses ₹${expenses.toStringAsFixed(0)}",
                              style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11)),
                        ],
                      ),
                      const Icon(Icons.savings_rounded, color: Colors.white, size: 42),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Metric grid
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.pie_chart_rounded,
                        label: "Expense Ratio",
                        value: "${expenseRatio.toStringAsFixed(1)}%",
                        color: const Color(0xFFf87171),
                        progress: (expenseRatio / 100).clamp(0, 1),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.local_fire_department_rounded,
                        label: "Habits Done",
                        value: "$habits",
                        color: const Color(0xFFfbbf24),
                        progress: (habits / 30).clamp(0, 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _MetricCard(
                  icon: Icons.bolt_rounded,
                  label: "Productivity Score",
                  value: "$productivity%",
                  color: const Color(0xFF6c8fff),
                  progress: (productivity / 100).clamp(0, 1),
                  fullWidth: true,
                ),

                const SizedBox(height: 32),
                const Text("Insights",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),

                _InsightTile(text: "Savings improved this month", emoji: "🔥", color: const Color(0xFF4ade80)),
                _InsightTile(text: "Entertainment expenses increased", emoji: "🛍️", color: const Color(0xFFf87171)),
                _InsightTile(text: "Productivity consistency improving", emoji: "📈", color: const Color(0xFF6c8fff)),
                _InsightTile(text: "Goal completion rate strong", emoji: "🎯", color: const Color(0xFFfbbf24)),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final double progress;
  final bool fullWidth;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.progress,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label,
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.toDouble(),
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final String text;
  final String emoji;
  final Color color;

  const _InsightTile({required this.text, required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 17)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}