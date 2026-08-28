import 'package:flutter/material.dart';

class AITaxSaverScreen extends StatefulWidget {
  final int userId;

  const AITaxSaverScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AITaxSaverScreen> createState() => _AITaxSaverScreenState();
}

class _AITaxSaverScreenState extends State<AITaxSaverScreen> {
  double _salary = 850000; // Annual CTC
  double _invested80C = 75000;
  double _health80D = 15000;
  double _nps80CCD = 25000;
  double _rentPaidMonthly = 18000;

  @override
  Widget build(BuildContext context) {
    double max80C = 150000;
    double max80D = 25000;
    double maxNPS = 50000;

    double unused80C = (max80C - _invested80C).clamp(0, max80C);
    double unused80D = (max80D - _health80D).clamp(0, max80D);
    double unusedNPS = (maxNPS - _nps80CCD).clamp(0, maxNPS);

    double totalPotentialSavings = (unused80C + unused80D + unusedNPS) * 0.208; // ~20% bracket with cess

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "AI Tax Saver Radar",
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Savings Potential Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEA580C).withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Unclaimed Tax Savings Potential",
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "₹${totalPotentialSavings.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "By maximizing your 80C, 80D & NPS deductions before financial year-end.",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Deduction Buckets
            const Text(
              "Deduction Breakdown & Radar",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 14),

            _taxBucketCard("Section 80C (ELSS, PPF, EPF)", _invested80C, max80C, "Save up to ₹${unused80C.toStringAsFixed(0)} more", const Color(0xFF10B981), (v) => setState(() => _invested80C = v)),
            _taxBucketCard("Section 80D (Health Insurance)", _health80D, max80D, "Save up to ₹${unused80D.toStringAsFixed(0)} more", const Color(0xFF3B82F6), (v) => setState(() => _health80D = v)),
            _taxBucketCard("Section 80CCD(1B) (NPS Extra)", _nps80CCD, maxNPS, "Save up to ₹${unusedNPS.toStringAsFixed(0)} more", const Color(0xFF8B5CF6), (v) => setState(() => _nps80CCD = v)),

            const SizedBox(height: 14),

            // AI Tax Tip
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Color(0xFFF59E0B), size: 20),
                      SizedBox(width: 8),
                      Text("AI Tax Recommendation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Investing ₹5,000/month in 80C ELSS Mutual Funds not only eliminates your tax leak but historically delivers 14-16% annualized compounding returns over 5-year periods.",
                    style: TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taxBucketCard(String title, double current, double max, String sub, Color color, ValueChanged<double> onChanged) {
    double pct = (current / max).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
              Text("₹${current.toStringAsFixed(0)} / ₹${max.toStringAsFixed(0)}", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12.5)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Text(sub, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
        ],
      ),
    );
  }
}
