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
  double _currentCorpus = 100000;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserFinances();
  }

  Future<void> _loadUserFinances() async {
    try {
      final res = await ApiService.getPrediction(widget.userId);
      if (res["status"] == "success") {
        final double predSav = (res["predicted_savings"] ?? 15000).toDouble();
        setState(() {
          _monthlyInvestment = predSav > 2000 ? predSav : 15000;
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
    // FV of lump sum
    double fvLump = _currentCorpus * (1 + (_expectedReturn / 100.0) * _years);
    // FV of SIP: P * [ (1+r)^n - 1 ] * (1+r) / r
    double fvSIP = _monthlyInvestment * ((1 + r) * (List.generate(n, (i) => 1).fold(1.0, (acc, _) => acc * (1 + r)) - 1)) / r;
    return fvLump + fvSIP;
  }

  @override
  Widget build(BuildContext context) {
    double totalInvested = _currentCorpus + (_monthlyInvestment * _years * 12);
    double futureValue = _calculateFutureValue();
    double wealthGained = futureValue - totalInvested;

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Wealth Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF059669), Color(0xFF10B981)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
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
                              "Projected Corpus at Horizon",
                              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${_years.toInt()} Years",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "₹${futureValue.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _statItem("Invested Capital", "₹${totalInvested.toStringAsFixed(0)}", Colors.white70),
                              Container(width: 1, height: 30, color: Colors.white24),
                              _statItem("Est. Returns", "₹${wealthGained.toStringAsFixed(0)}", const Color(0xFFFDE047)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sliders Control Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Investment Parameters",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 16),
                        _sliderRow(
                          "Monthly SIP Amount",
                          "₹${_monthlyInvestment.toStringAsFixed(0)}",
                          _monthlyInvestment,
                          1000,
                          (_monthlyInvestment * 2.0).clamp(100000.0, 5000000.0),
                          1000,
                          (v) => setState(() => _monthlyInvestment = v),
                        ),
                        _sliderRow("Time Horizon", "${_years.toInt()} Years", _years, 1, 40, 1, (v) => setState(() => _years = v)),
                        _sliderRow("Expected Annual Return (CAGR)", "${_expectedReturn.toStringAsFixed(1)}%", _expectedReturn, 4, 30, 0.5, (v) => setState(() => _expectedReturn = v)),
                        _sliderRow(
                          "Existing Initial Corpus",
                          "₹${_currentCorpus.toStringAsFixed(0)}",
                          _currentCorpus,
                          0,
                          (_currentCorpus * 2.0).clamp(1000000.0, 50000000.0),
                          10000,
                          (v) => setState(() => _currentCorpus = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // AI FIRE Milestone Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.rocket_launch, color: Color(0xFFD97706), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "AI FIRE Insight",
                                style: TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "At ₹${_monthlyInvestment.toStringAsFixed(0)}/mo, you will achieve ₹1 Crore net worth in ~${(10000000 / (futureValue > 0 ? (futureValue / _years) : 100000)).clamp(1.0, 35.0).toStringAsFixed(1)} years.",
                                style: const TextStyle(color: Color(0xFF78350F), fontSize: 12.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _sliderRow(String label, String valueStr, double val, double min, double max, double step, ValueChanged<double> onChanged) {
    final double safeMax = max > min ? max : min + 1000.0;
    final double safeVal = val.clamp(min, safeMax);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF475569), fontSize: 13)),
              Text(valueStr, style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF10B981),
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: const Color(0xFF059669),
            ),
            child: Slider(
              value: safeVal,
              min: min,
              max: safeMax,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String val, Color valColor) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: valColor, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
