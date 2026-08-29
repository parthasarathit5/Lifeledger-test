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
  double _annualCTC = 1200000; // Annual Salary CTC
  double _invested80C = 75000;  // Max 1,50,000
  double _health80D = 15000;   // Max 25,000 / 50,000
  double _nps80CCD = 25000;    // Max 50,000
  double _rentPaidMonthly = 18000;

  // Standard Indian Tax Calculation under Old vs New Regime
  double _calculateOldRegimeTax() {
    double standardDeduction = 50000;
    double hraExemption = (_rentPaidMonthly * 12 * 0.35).clamp(0, 120000);
    double totalDeductions = standardDeduction + hraExemption + _invested80C.clamp(0, 150000) + _health80D.clamp(0, 50000) + _nps80CCD.clamp(0, 50000);
    double taxableIncome = (_annualCTC - totalDeductions).clamp(0, double.infinity);

    if (taxableIncome <= 500000) return 0; // 87A rebate

    double tax = 0;
    if (taxableIncome > 1000000) {
      tax += (taxableIncome - 1000000) * 0.30;
      tax += 500000 * 0.20;
      tax += 250000 * 0.05;
    } else if (taxableIncome > 500000) {
      tax += (taxableIncome - 500000) * 0.20;
      tax += 250000 * 0.05;
    } else if (taxableIncome > 250000) {
      tax += (taxableIncome - 250000) * 0.05;
    }
    return tax * 1.04; // 4% Health & Education Cess
  }

  double _calculateNewRegimeTax() {
    double standardDeduction = 75000; // Updated budget standard deduction
    double taxableIncome = (_annualCTC - standardDeduction).clamp(0, double.infinity);

    if (taxableIncome <= 700000) return 0; // Section 87A rebate under new regime

    double tax = 0;
    if (taxableIncome > 1500000) {
      tax += (taxableIncome - 1500000) * 0.30;
      tax += 300000 * 0.20;
      tax += 300000 * 0.15;
      tax += 300000 * 0.10;
      tax += 300000 * 0.05;
    } else if (taxableIncome > 1200000) {
      tax += (taxableIncome - 1200000) * 0.20;
      tax += 300000 * 0.15;
      tax += 300000 * 0.10;
      tax += 300000 * 0.05;
    } else if (taxableIncome > 900000) {
      tax += (taxableIncome - 900000) * 0.15;
      tax += 300000 * 0.10;
      tax += 300000 * 0.05;
    } else if (taxableIncome > 600000) {
      tax += (taxableIncome - 600000) * 0.10;
      tax += 300000 * 0.05;
    } else if (taxableIncome > 300000) {
      tax += (taxableIncome - 300000) * 0.05;
    }
    return tax * 1.04;
  }

  @override
  Widget build(BuildContext context) {
    double max80C = 150000;
    double max80D = 25000;
    double maxNPS = 50000;

    double unused80C = (max80C - _invested80C).clamp(0, max80C);
    double unused80D = (max80D - _health80D).clamp(0, max80D);
    double unusedNPS = (maxNPS - _nps80CCD).clamp(0, maxNPS);

    double oldTax = _calculateOldRegimeTax();
    double newTax = _calculateNewRegimeTax();

    bool isOldBetter = oldTax < newTax;
    double regimeSavings = (oldTax - newTax).abs();

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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HERO OLD VS NEW REGIME VERDICT
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF0D9488)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF059669).withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "AI Tax Regime Verdict",
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isOldBetter ? "🏆 Old Regime Recommended" : "⚡ New Regime Recommended",
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isOldBetter
                        ? "Save ₹${regimeSavings.toStringAsFixed(0)} under Old Regime"
                        : "Save ₹${regimeSavings.toStringAsFixed(0)} under New Regime",
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Annual Salary: ₹${(_annualCTC / 100000).toStringAsFixed(1)} Lakhs • Total Claimed Deductions: ₹${(_invested80C + _health80D + _nps80CCD).toStringAsFixed(0)}",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // SIDE-BY-SIDE TAX BOX
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _taxCol("Old Regime Tax", "₹${oldTax.toStringAsFixed(0)}", isOldBetter),
                        Container(width: 1, height: 32, color: Colors.white24),
                        _taxCol("New Regime Tax", "₹${newTax.toStringAsFixed(0)}", !isOldBetter),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // SALARY CTC SLIDER
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Annual Gross Salary (CTC)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                      Text("₹${(_annualCTC / 100000).toStringAsFixed(1)} Lakhs (₹${_annualCTC.toStringAsFixed(0)})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF059669))),
                    ],
                  ),
                  Slider(
                    value: _annualCTC.clamp(400000.0, 3000000.0),
                    min: 400000,
                    max: 3000000,
                    divisions: 52,
                    activeColor: const Color(0xFF059669),
                    inactiveColor: const Color(0xFFE2E8F0),
                    onChanged: (v) => setState(() => _annualCTC = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SECTION DEDUCTIONS SLIDERS
            const Text(
              "Section-wise Tax Deductions Radar",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),

            _taxBucketSlider(
              title: "Section 80C (ELSS, PPF, EPF, Life Ins.)",
              current: _invested80C,
              max: max80C,
              unused: unused80C,
              color: const Color(0xFF059669),
              onChanged: (v) => setState(() => _invested80C = v),
            ),
            const SizedBox(height: 12),

            _taxBucketSlider(
              title: "Section 80D (Health Medical Insurance)",
              current: _health80D,
              max: max80D,
              unused: unused80D,
              color: const Color(0xFF2563EB),
              onChanged: (v) => setState(() => _health80D = v),
            ),
            const SizedBox(height: 12),

            _taxBucketSlider(
              title: "Section 80CCD(1B) (Exclusive NPS Tier-1)",
              current: _nps80CCD,
              max: maxNPS,
              unused: unusedNPS,
              color: const Color(0xFF7C3AED),
              onChanged: (v) => setState(() => _nps80CCD = v),
            ),

            const SizedBox(height: 20),

            // ACTIONABLE TAX OPTIMIZATION GUIDE
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb, color: Color(0xFF059669), size: 20),
                      SizedBox(width: 8),
                      Text("AI Tax Optimization Blueprint", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF065F46))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "• You still have ₹${(unused80C + unused80D + unusedNPS).toStringAsFixed(0)} in unused tax deduction room.\n"
                    "• Channeling ₹${(unused80C / 12).toStringAsFixed(0)}/month into an 80C ELSS Mutual Fund gives you both tax exemption and long-term 12-15% CAGR wealth compounding.\n"
                    "• Maintain health insurance premiums under 80D before March 31 to claim instant tax rebates.",
                    style: const TextStyle(color: Color(0xFF064E3B), fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),
);
}

  Widget _taxCol(String label, String val, bool isWinner) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(val, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            if (isWinner) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check_circle, color: Color(0xFF34D399), size: 14),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _taxBucketSlider({
    required String title,
    required double current,
    required double max,
    required double unused,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
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
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
              Text("₹${current.toStringAsFixed(0)} / ₹${max.toStringAsFixed(0)}", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          Slider(
            value: current.clamp(0.0, max),
            min: 0,
            max: max,
            divisions: (max / 5000).toInt(),
            activeColor: color,
            inactiveColor: const Color(0xFFF1F5F9),
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Unclaimed Room: ₹${unused.toStringAsFixed(0)}", style: TextStyle(color: unused > 0 ? const Color(0xFFD97706) : const Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.w600)),
              Text("${((current / max) * 100).toStringAsFixed(0)}% Utilized", style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
