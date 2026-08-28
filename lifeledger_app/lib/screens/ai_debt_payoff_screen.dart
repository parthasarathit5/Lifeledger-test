import 'package:flutter/material.dart';

class AIDebtPayoffScreen extends StatefulWidget {
  final int userId;

  const AIDebtPayoffScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AIDebtPayoffScreen> createState() => _AIDebtPayoffScreenState();
}

class _AIDebtPayoffScreenState extends State<AIDebtPayoffScreen> {
  final List<Map<String, dynamic>> _debts = [
    {"name": "Credit Card Outstanding", "balance": 45000.0, "rate": 36.0, "min_pay": 2250.0},
    {"name": "Personal Loan EMI", "balance": 180000.0, "rate": 14.5, "min_pay": 5800.0},
    {"name": "Vehicle Two-Wheeler Loan", "balance": 65000.0, "rate": 11.0, "min_pay": 2100.0},
  ];

  double _extraMonthlyPayment = 5000.0;
  String _strategy = "avalanche"; // 'avalanche' (highest interest first) or 'snowball' (lowest balance first)

  @override
  Widget build(BuildContext context) {
    double totalDebt = _debts.fold(0.0, (acc, d) => acc + (d["balance"] as num).toDouble());
    double totalMinPay = _debts.fold(0.0, (acc, d) => acc + (d["min_pay"] as num).toDouble());

    // Estimated months with extra payoff
    int monthsWithExtra = (totalDebt / (totalMinPay + _extraMonthlyPayment)).ceil().clamp(3, 120);
    int monthsWithoutExtra = (totalDebt / totalMinPay).ceil().clamp(6, 240);
    double interestSaved = (monthsWithoutExtra - monthsWithExtra) * (totalDebt * 0.012);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "AI Debt Payoff Accelerator",
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
            // Hero Debt Freedom Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF0D9488)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF059669).withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Projected Debt-Free Horizon", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text(
                    "$monthsWithExtra Months",
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Accelerated by ${monthsWithoutExtra - monthsWithExtra} months with extra payments.",
                    style: const TextStyle(color: Color(0xFFFDE047), fontSize: 12.5, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statCol("Total Debt", "₹${totalDebt.toStringAsFixed(0)}"),
                        Container(width: 1, height: 28, color: Colors.white24),
                        _statCol("Interest Saved", "₹${interestSaved.toStringAsFixed(0)}"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Strategy Toggle
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text("Avalanche (Math Best)")),
                    selected: _strategy == "avalanche",
                    selectedColor: const Color(0xFF059669),
                    labelStyle: TextStyle(color: _strategy == "avalanche" ? Colors.white : const Color(0xFF334155), fontWeight: FontWeight.bold, fontSize: 12),
                    onSelected: (v) => setState(() => _strategy = "avalanche"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text("Snowball (Psych Best)")),
                    selected: _strategy == "snowball",
                    selectedColor: const Color(0xFF059669),
                    labelStyle: TextStyle(color: _strategy == "snowball" ? Colors.white : const Color(0xFF334155), fontWeight: FontWeight.bold, fontSize: 12),
                    onSelected: (v) => setState(() => _strategy = "snowball"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Active Debts List
            const Text("Your Outstanding Accounts", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            ..._debts.map((d) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1E293B))),
                          const SizedBox(height: 4),
                          Text("Interest Rate: ${d['rate']}% APR", style: TextStyle(color: (d['rate'] as num) > 20 ? const Color(0xFFEF4444) : const Color(0xFF64748B), fontSize: 11.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("₹${d['balance']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                          const SizedBox(height: 4),
                          Text("Min: ₹${d['min_pay']}/mo", style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _statCol(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
      ],
    );
  }
}
