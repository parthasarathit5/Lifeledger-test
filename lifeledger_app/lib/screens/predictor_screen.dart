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
  bool loading = true;
  Map data = {};
  double _simulationReductionPercent = 0.0; // 0% to 30%

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final res = await ApiService.getPrediction(widget.userId);
      setState(() {
        data = res;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Widget _buildModelBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2640),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, color: Color(0xFF38BDF8), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Machine Learning Engine v2.0",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "RandomForest Regressor • Accuracy R²: ${((data["confidence_r2"] ?? 0.995) * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "ACTIVE",
              style: TextStyle(
                color: Color(0xFF10B981),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroForecastCard() {
    final double currentExp = (data["expense"] ?? 0).toDouble();
    final double predictedExp = (data["predicted_expense"] ?? (data["expense"] ?? 0) * 1.05).toDouble();
    final double simulatedExp = predictedExp * (1.0 - (_simulationReductionPercent / 100.0));
    final double predictedSav = (data["predicted_savings"] ?? 0).toDouble();
    final double simulatedSav = predictedSav + (predictedExp - simulatedExp);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.35),
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
                "30-Day ML Expense Forecast",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  data["risk"] ?? "Stable",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "₹${simulatedExp.toStringAsFixed(0)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          if (_simulationReductionPercent > 0)
            Text(
              "Simulated with ${_simulationReductionPercent.toStringAsFixed(0)}% spending reduction (Original: ₹${predictedExp.toStringAsFixed(0)})",
              style: const TextStyle(
                color: Color(0xFFFDE047),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("Predicted Savings", "₹${simulatedSav.toStringAsFixed(0)}", Icons.savings),
                Container(width: 1, height: 32, color: Colors.white24),
                _buildStatItem("LifeScore", "${data["lifescore"] ?? 85}/100", Icons.speed),
                Container(width: 1, height: 32, color: Colors.white24),
                _buildStatItem("Monthly Income", "₹${(data["income"] ?? 0).toStringAsFixed(0)}", Icons.account_balance_wallet),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13.5,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown() {
    final Map<String, dynamic> cats = Map<String, dynamic>.from(data["predicted_categories"] ?? {});
    if (cats.isEmpty) {
      return const SizedBox.shrink();
    }

    final double totalPred = cats.values.fold(0.0, (sum, item) => sum + (item as num).toDouble());

    final Map<String, Color> catColors = {
      'food': const Color(0xFFEF4444),
      'rent': const Color(0xFFF59E0B),
      'transport': const Color(0xFF3B82F6),
      'shopping': const Color(0xFFEC4899),
      'health': const Color(0xFF10B981),
      'entertainment': const Color(0xFF8B5CF6),
      'education': const Color(0xFF06B6D4),
      'other': const Color(0xFF64748B),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF121826),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_outline, color: Color(0xFF38BDF8), size: 20),
              SizedBox(width: 8),
              Text(
                "Predicted Category Allocation",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...cats.entries.map((e) {
            final double amt = (e.value as num).toDouble();
            final double pct = totalPred > 0 ? (amt / totalPred) : 0.0;
            final color = catColors[e.key.toLowerCase()] ?? Colors.grey;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "₹${amt.toStringAsFixed(0)} (${(pct * 100).toStringAsFixed(0)}%)",
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: const Color(0xFF1E293B),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSimulationSlider() {
    final double predictedExp = (data["predicted_expense"] ?? (data["expense"] ?? 0) * 1.05).toDouble();
    final double savedPerMonth = predictedExp * (_simulationReductionPercent / 100.0);
    final double savedAnnual = savedPerMonth * 12;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF172554)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.tune, color: Color(0xFFA78BFA), size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Interactive Savings Simulator",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFA78BFA).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "-${_simulationReductionPercent.toStringAsFixed(0)}%",
                  style: const TextStyle(
                    color: Color(0xFFA78BFA),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Slide to simulate spending cuts and view projected wealth accumulation:",
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF818CF8),
              inactiveTrackColor: const Color(0xFF334155),
              thumbColor: Colors.white,
              overlayColor: const Color(0xFF818CF8).withOpacity(0.2),
            ),
            child: Slider(
              value: _simulationReductionPercent,
              min: 0,
              max: 30,
              divisions: 6,
              onChanged: (val) {
                setState(() {
                  _simulationReductionPercent = val;
                });
              },
            ),
          ),
          if (_simulationReductionPercent > 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "+₹${savedPerMonth.toStringAsFixed(0)}/month",
                    style: const TextStyle(
                      color: Color(0xFF34D399),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    "+₹${savedAnnual.toStringAsFixed(0)} Extra Annual Wealth",
                    style: const TextStyle(
                      color: Color(0xFFFDE047),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAIAdvisorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ask LifeLedger AI Coach",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Instant answers for affordability, budget leaks & goals",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data["advice"] ?? "Improving habit consistency reduces monthly expenses by an estimated ₹3,500.",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4F46E5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text(
                "Chat with AI Advisor",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AIAdvisorScreen(
                      userId: widget.userId,
                      userName: widget.userName,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      appBar: AppBar(
        title: const Text(
          "AI Predictive Intelligence",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () {
              setState(() => loading = true);
              load();
            },
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModelBadge(),
                  _buildHeroForecastCard(),
                  _buildSimulationSlider(),
                  _buildCategoryBreakdown(),
                  _buildAIAdvisorBanner(),
                ],
              ),
            ),
    );
  }
}