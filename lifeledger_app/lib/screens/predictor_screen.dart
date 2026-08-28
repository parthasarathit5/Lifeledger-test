import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'ai_advisor_screen.dart';

class PredictorScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const PredictorScreen({
    super.key,
    required this.userId,
    this.userName = "User",
  });

  @override
  State<PredictorScreen> createState() => _PredictorScreenState();
}

class _PredictorScreenState extends State<PredictorScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _predictionData;
  double _spendingCutPercent = 10.0; // Interactive What-If simulation slider

  @override
  void initState() {
    super.initState();
    _fetchPredictions();
  }

  Future<void> _fetchPredictions() async {
    try {
      final res = await ApiService.getPrediction(widget.userId);
      if (res["status"] == "success") {
        setState(() {
          _predictionData = Map<String, dynamic>.from(res);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF059669)),
        ),
      );
    }

    final double income = (_predictionData?["current_income"] ?? 0).toDouble();
    final double curExpense = (_predictionData?["current_expense"] ?? 0).toDouble();
    final double predExpense = (_predictionData?["predicted_next_month_expense"] ?? 0).toDouble();
    final double predSavings = (_predictionData?["predicted_savings"] ?? 0).toDouble();
    final double confidence = (_predictionData?["confidence_r2"] ?? 0.995).toDouble();
    final int lifescore = _predictionData?["lifescore"] ?? 75;
    final String riskClass = _predictionData?["risk_class"] ?? "Low";
    final Map<String, dynamic> catForecasts = _predictionData?["predicted_categories"] ?? {};
    final List insights = _predictionData?["insights"] ?? [];

    final double simulatedCutExpense = predExpense * (1 - (_spendingCutPercent / 100.0));
    final double simulatedSavings = (income - simulatedCutExpense).clamp(0.0, income);
    final double annualSimulatedGain = (simulatedSavings - predSavings) * 12;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.auto_graph, color: Color(0xFF059669), size: 22),
            SizedBox(width: 8),
            Text(
              "AI Expense Predictor",
              style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero ML Forecast Card
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
                        "Next 30-Day ML Forecast",
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "R² ${(confidence * 100).toStringAsFixed(1)}% Accuracy",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "₹${predExpense.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metricCol("Predicted Savings", "₹${predSavings.toStringAsFixed(0)}", const Color(0xFFFDE047)),
                        Container(width: 1, height: 28, color: Colors.white24),
                        _metricCol("LifeScore", "$lifescore / 100", Colors.white),
                        Container(width: 1, height: 28, color: Colors.white24),
                        _metricCol("Risk Profile", riskClass, const Color(0xFF6EE7B7)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Interactive "What-If" Simulation Slider Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.tune, color: Color(0xFFD97706), size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Interactive 'What-If' Simulation",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Simulate reducing non-essential spending by ${_spendingCutPercent.toInt()}%:",
                    style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFFF59E0B),
                      inactiveTrackColor: const Color(0xFFE2E8F0),
                      thumbColor: const Color(0xFFD97706),
                    ),
                    child: Slider(
                      value: _spendingCutPercent,
                      min: 0,
                      max: 40,
                      divisions: 8,
                      onChanged: (val) => setState(() => _spendingCutPercent = val),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _simBox("New Monthly Expense", "₹${simulatedCutExpense.toStringAsFixed(0)}", const Color(0xFF059669)),
                      _simBox("Annual Wealth Gain", "+₹${annualSimulatedGain.toStringAsFixed(0)}", const Color(0xFFD97706)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Predicted Category Distribution
            const Text(
              "Predicted Category Breakdown",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: catForecasts.entries.map((e) {
                  final cat = e.key;
                  final double amt = (e.value as num).toDouble();
                  final double pct = predExpense > 0 ? (amt / predExpense) : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cat.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF334155)),
                            ),
                            Text(
                              "₹${amt.toStringAsFixed(0)} (${(pct * 100).toStringAsFixed(1)}%)",
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct.clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor: AlwaysStoppedAnimation<Color>(_categoryColor(cat)),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // 4. AI Strategic Recommendations
            const Text(
              "AI Machine Learning Insights",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),
            ...insights.map((ins) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Color(0xFF059669), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ins.toString(),
                          style: const TextStyle(color: Color(0xFF334155), fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _metricCol(String label, String val, Color valColor) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: valColor, fontWeight: FontWeight.bold, fontSize: 13.5)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
      ],
    );
  }

  Widget _simBox(String label, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
        const SizedBox(height: 2),
        Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Color _categoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'food':
        return const Color(0xFFEF4444);
      case 'rent':
        return const Color(0xFF3B82F6);
      case 'transport':
        return const Color(0xFFF59E0B);
      case 'shopping':
        return const Color(0xFFEC4899);
      case 'health':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF8B5CF6);
    }
  }
}