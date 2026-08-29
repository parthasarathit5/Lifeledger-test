import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AIWealthSimulatorScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const AIWealthSimulatorScreen({
    super.key,
    required this.userId,
    this.userName = "User",
  });

  @override
  State<AIWealthSimulatorScreen> createState() => _AIWealthSimulatorScreenState();
}

class _AIWealthSimulatorScreenState extends State<AIWealthSimulatorScreen> {
  double _monthlyInvestment = 15000;
  double _expectedReturn = 12.0; // 12% equity CAGR
  double _years = 15;
  double _currentCorpus = 50000;
  double _annualExpense = 240000;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserFinances();
  }

  Future<void> _loadUserFinances() async {
    try {
      final dash = await ApiService.getDashboard(widget.userId);
      if (dash["status"] == "success") {
        final double bal = (dash["balance"] ?? 0).toDouble();
        final double inc = (dash["total_income"] ?? 0).toDouble();
        final double exp = (dash["total_expense"] ?? 0).toDouble();
        final double surplus = inc - exp;

        setState(() {
          _currentCorpus = bal > 0 ? bal : 50000;
          _monthlyInvestment = (surplus > 2000 ? surplus : 15000.0).clamp(2000.0, 100000.0).toDouble();
          _annualExpense = exp > 0 ? (exp * 12) : 240000;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double _calculateFutureValue() {
    double r = (_expectedReturn / 100.0) / 12.0;
    int n = (_years * 12).toInt();
    if (r == 0) return _currentCorpus + (_monthlyInvestment * n);
    // FV of lump sum
    double fvLump = _currentCorpus * (1 + (_expectedReturn / 100.0) * _years);
    // FV of SIP
    double fvSIP = _monthlyInvestment * ((1 + r) * (List.generate(n, (i) => 1).fold(1.0, (acc, _) => acc * (1 + r)) - 1)) / r;
    return fvLump + fvSIP;
  }

  int _calculateYearsToHitTarget(double target) {
    double r = (_expectedReturn / 100.0) / 12.0;
    double corpus = _currentCorpus;
    for (int month = 1; month <= 480; month++) {
      corpus = (corpus + _monthlyInvestment) * (1 + r);
      if (corpus >= target) {
        return (month / 12).ceil();
      }
    }
    return 30;
  }

  @override
  Widget build(BuildContext context) {
    double totalInvested = _currentCorpus + (_monthlyInvestment * _years * 12);
    double futureValue = _calculateFutureValue();
    double wealthGained = (futureValue - totalInvested).clamp(0, double.infinity);

    // FIRE Number (25x Annual Expenses according to 4% Trinity Rule)
    double fireTargetNumber = _annualExpense * 25;
    int yearsTo1Cr = _calculateYearsToHitTarget(10000000); // 1 Crore
    int yearsToFIRE = _calculateYearsToHitTarget(fireTargetNumber);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "AI Wealth & FIRE Simulator",
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF059669)))
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HERO WEALTH CORPUS CARD
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
                              BoxShadow(
                                color: const Color(0xFF059669).withOpacity(0.25),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Projected Compounded Corpus",
                                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "${_years.toInt()} Years Horizon",
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "₹${futureValue.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: _statItem("Total Invested", "₹${totalInvested.toStringAsFixed(0)}", Colors.white70)),
                                    Container(width: 1, height: 28, color: Colors.white24),
                                    Expanded(child: _statItem("Compound Gains", "+₹${wealthGained.toStringAsFixed(0)}", const Color(0xFFFDE047))),
                                    Container(width: 1, height: 28, color: Colors.white24),
                                    Expanded(child: _statItem("CAGR %", "${_expectedReturn.toStringAsFixed(1)}%", Colors.white)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                  const SizedBox(height: 22),

                  // FIRE RETIREMENT MILESTONES
                  const Text(
                    "🔥 FIRE Milestones & Target Horizons",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _milestoneTile(
                          icon: Icons.flag,
                          color: const Color(0xFF059669),
                          title: "₹1 Crore Horizon",
                          target: "~$yearsTo1Cr Years",
                          subtitle: "Year ${DateTime.now().year + yearsTo1Cr}",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _milestoneTile(
                          icon: Icons.beach_access,
                          color: const Color(0xFF2563EB),
                          title: "Full FIRE Retirement",
                          target: "~$yearsToFIRE Years",
                          subtitle: "Target: ₹${(fireTargetNumber / 100000).toStringAsFixed(1)}L (25x Exp)",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // INTERACTIVE SLIDERS FOR SIP, RETURN %, YEARS
                  const Text(
                    "Customize SIP & Compounding Strategy",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 10),

                  // Monthly SIP Slider
                  _controlSlider(
                    title: "Monthly SIP Investment",
                    valueStr: "₹${_monthlyInvestment.toStringAsFixed(0)}/month",
                    val: _monthlyInvestment,
                    min: 2000,
                    max: 100000,
                    divisions: 49,
                    color: const Color(0xFF059669),
                    onChanged: (v) => setState(() => _monthlyInvestment = v),
                  ),
                  const SizedBox(height: 12),

                  // Expected CAGR % Slider
                  _controlSlider(
                    title: "Expected Equity Return (CAGR)",
                    valueStr: "${_expectedReturn.toStringAsFixed(1)}% p.a.",
                    val: _expectedReturn,
                    min: 8.0,
                    max: 18.0,
                    divisions: 20,
                    color: const Color(0xFF2563EB),
                    onChanged: (v) => setState(() => _expectedReturn = v),
                  ),
                  const SizedBox(height: 12),

                  // Investment Horizon Years Slider
                  _controlSlider(
                    title: "Investment Horizon",
                    valueStr: "${_years.toInt()} Years",
                    val: _years,
                    min: 3,
                    max: 30,
                    divisions: 27,
                    color: const Color(0xFF7C3AED),
                    onChanged: (v) => setState(() => _years = v),
                  ),

                  const SizedBox(height: 20),

                  // AI WEALTH STRATEGY BLUEPRINT
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
                            Icon(Icons.rocket_launch, color: Color(0xFF059669), size: 20),
                            SizedBox(width: 8),
                            Text(
                              "AI Wealth Compounding Rules",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF065F46)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "1. **Step-Up SIP Rule:** Increasing your monthly investment by 10% each year accelerates your ₹1 Crore milestone by **3.5 years**.\n"
                          "2. **The 4% Safe Withdrawal Rule:** When your corpus reaches ₹${(fireTargetNumber / 100000).toStringAsFixed(1)} Lakhs, you can withdraw ₹${(_annualExpense / 12).toStringAsFixed(0)}/month forever without running out of money.\n"
                          "3. **Broad Market Allocation:** Direct 70% into Nifty 50/S&P 500 index funds and 30% into flexi-cap growth assets.",
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

  Widget _statItem(String label, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13.5)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
      ],
    );
  }

  Widget _milestoneTile({
    required IconData icon,
    required Color color,
    required String title,
    required String target,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)))),
            ],
          ),
          const SizedBox(height: 10),
          Text(target, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _controlSlider({
    required String title,
    required String valueStr,
    required double val,
    required double min,
    required double max,
    required int divisions,
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
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
              Text(valueStr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: color)),
            ],
          ),
          Slider(
            value: val.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            activeColor: color,
            inactiveColor: const Color(0xFFF1F5F9),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
