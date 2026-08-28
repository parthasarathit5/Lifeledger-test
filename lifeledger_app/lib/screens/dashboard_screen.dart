import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'expense_screen.dart';
import 'income_screen.dart';
import 'habit_screen.dart';
import 'task_screen.dart';
import 'history_screen.dart';
import 'mood_screen.dart';
import 'analytics_screen.dart';
import 'lifescore_screen.dart';
import 'budget_screen.dart';
import 'predictor_screen.dart';
import 'compare_screen.dart';
import 'behavior_screen.dart';
import 'profile_screen.dart';
import 'goals_screen.dart';
import 'goal_screen.dart';
import 'achievements_screen.dart';
import 'streak_screen.dart';
import 'networth_screen.dart';
import 'alerts_screen.dart';
import 'yearly_heatmap_screen.dart';
import 'heatmap_screen.dart';
import 'summary_screen.dart';
import 'daily_summary_screen.dart';
import 'report_screen.dart';

// Advanced AI Modules
import 'ai_advisor_screen.dart';
import 'ai_wealth_simulator_screen.dart';
import 'ai_tax_saver_screen.dart';
import 'ai_smart_receipt_screen.dart';
import 'ai_debt_payoff_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  final int userId;

  const DashboardScreen({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  double balance = 0;
  double totalIncome = 0;
  double totalExpense = 0;
  int pendingTasks = 0;
  int completedTasks = 0;
  int completedHabits = 0;
  int totalHabits = 0;
  List transactions = [];

  @override
  void initState() {
    super.initState();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      var url = Uri.parse("https://lifeledger-backend.onrender.com/dashboard/${widget.userId}/");
      var res = await http.get(url);
      var data = jsonDecode(res.body);

      if (data["status"] == "success") {
        setState(() {
          balance = (data["balance"] ?? 0).toDouble();
          totalIncome = (data["total_income"] ?? 0).toDouble();
          totalExpense = (data["total_expense"] ?? 0).toDouble();
          pendingTasks = data["pending_tasks"] ?? 0;
          completedTasks = data["completed_tasks"] ?? 0;
          completedHabits = data["completed_habits"] ?? 0;
          totalHabits = data["total_habits"] ?? 0;
          transactions = data["transactions"] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String greet() {
    int h = DateTime.now().hour;
    if (h < 12) return "Good Morning";
    if (h < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              child: const Icon(Icons.account_balance_wallet, color: Color(0xFF059669), size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${greet()}, ${widget.userName}",
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "LifeLedger AI Intelligence",
                  style: TextStyle(color: Color(0xFF059669), fontSize: 10.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF334155), size: 22),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AlertsScreen(userId: widget.userId))),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF334155), size: 22),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userName: widget.userName, userId: widget.userId))),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF059669)))
          : RefreshIndicator(
              onRefresh: fetchDashboard,
              color: const Color(0xFF059669),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Crisp Pure White Hero Balance Card
                    _buildWhiteHeroCard(),
                    const SizedBox(height: 14),

                    // 2. Step 1: Add Income Quick Banner
                    _buildStep1IncomeCard(),
                    const SizedBox(height: 14),

                    // 3. AI Coach Banner
                    _buildAICoachCard(),
                    const SizedBox(height: 20),

                    // 4. Compact 30+ AI & Finance Suite
                    _buildCompactSuite(),
                    const SizedBox(height: 20),

                    // 5. Recent Activity
                    _buildRecentTransactions(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWhiteHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
                "Current Net Balance",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Color(0xFF059669), size: 11),
                    SizedBox(width: 4),
                    Text(
                      "AI ML Synced",
                      style: TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "₹${balance.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Color(0xFF059669),
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _balanceCol("Total Income", "₹${totalIncome.toStringAsFixed(0)}", const Color(0xFF059669), Icons.arrow_downward),
                Container(width: 1, height: 26, color: const Color(0xFFCBD5E1)),
                _balanceCol("Total Expense", "₹${totalExpense.toStringAsFixed(0)}", const Color(0xFFEF4444), Icons.arrow_upward),
                Container(width: 1, height: 26, color: const Color(0xFFCBD5E1)),
                _balanceCol("Savings Rate", "${totalIncome > 0 ? (((totalIncome - totalExpense) / totalIncome) * 100).clamp(0, 100).toStringAsFixed(0) : 0}%", const Color(0xFFD97706), Icons.pie_chart),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceCol(String label, String val, Color valColor, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: valColor, size: 11),
            const SizedBox(width: 3),
            Text(val, style: TextStyle(color: valColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
      ],
    );
  }

  Widget _buildStep1IncomeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFF10B981).withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add_card, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Step 1: Set Monthly Income",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                SizedBox(height: 2),
                Text(
                  "AI models automatically calculate budget, savings & forecast.",
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF059669),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => IncomeScreen(userId: widget.userId))).then((_) => fetchDashboard());
            },
            child: const Text("+ Add Income", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAICoachCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.psychology, color: Color(0xFFD97706), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "LifeLedger Precision AI Advisor",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 2),
                Text(
                  "Ask anything: Affordability, tax saver, spending cuts & FIRE.",
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AIAdvisorScreen(userId: widget.userId, userName: widget.userName),
                ),
              );
            },
            child: const Text("Ask AI", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSuite() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. AI & Machine Learning Suite
        _sectionTitle("🤖 AI & Machine Learning Suite", const Color(0xFF059669)),
        const SizedBox(height: 10),
        _gridSuite([
          _compactTile("AI Predictor", Icons.auto_graph, const Color(0xFF059669), PredictorScreen(userId: widget.userId, userName: widget.userName)),
          _compactTile("AI Coach Q&A", Icons.psychology, const Color(0xFFD97706), AIAdvisorScreen(userId: widget.userId, userName: widget.userName)),
          _compactTile("AI Wealth FIRE", Icons.rocket_launch, const Color(0xFF0284C7), AIWealthSimulatorScreen(userId: widget.userId, userName: widget.userName)),
          _compactTile("AI Tax Saver", Icons.receipt_long, const Color(0xFF7C3AED), AITaxSaverScreen(userId: widget.userId)),
          _compactTile("AI Receipt OCR", Icons.document_scanner, const Color(0xFF0D9488), AISmartReceiptScreen(userId: widget.userId)),
          _compactTile("AI Debt Payoff", Icons.speed, const Color(0xFFEA580C), AIDebtPayoffScreen(userId: widget.userId)),
          _compactTile("AI Behavior", Icons.insights, const Color(0xFFDB2777), BehaviorScreen(userId: widget.userId)),
          _compactTile("Smart Alerts", Icons.notifications_active, const Color(0xFFDC2626), AlertsScreen(userId: widget.userId)),
        ]),
        const SizedBox(height: 18),

        // 2. Cashflow & Goals Hub
        _sectionTitle("💰 Cashflow & Goals Hub", const Color(0xFFD97706)),
        const SizedBox(height: 10),
        _gridSuite([
          _compactTile("Add Expense", Icons.remove_circle_outline, const Color(0xFFDC2626), ExpenseScreen(userId: widget.userId)),
          _compactTile("Add Income", Icons.add_circle_outline, const Color(0xFF059669), IncomeScreen(userId: widget.userId)),
          _compactTile("Budget Matrix", Icons.wallet, const Color(0xFF4F46E5), BudgetScreen(userId: widget.userId)),
          _compactTile("Goal Tracker", Icons.flag_outlined, const Color(0xFFD97706), GoalsScreen(userId: widget.userId)),
          _compactTile("Net Worth", Icons.account_balance, const Color(0xFF059669), NetWorthScreen(userId: widget.userId)),
          _compactTile("Compare Months", Icons.compare_arrows, const Color(0xFF0891B2), CompareScreen(userId: widget.userId)),
          _compactTile("Ledger History", Icons.history, const Color(0xFF475569), HistoryScreen(userId: widget.userId)),
          _compactTile("Savings Goals", Icons.savings_outlined, const Color(0xFF65A30D), GoalScreen(userId: widget.userId)),
        ]),
        const SizedBox(height: 18),

        // 3. Habits & LifeScore Hub
        _sectionTitle("🌱 Habits & LifeScore Engine", const Color(0xFF2563EB)),
        const SizedBox(height: 10),
        _gridSuite([
          _compactTile("Habits Log", Icons.track_changes, const Color(0xFF059669), HabitScreen(userId: widget.userId)),
          _compactTile("Daily Tasks", Icons.checklist, const Color(0xFF2563EB), TaskScreen(userId: widget.userId)),
          _compactTile("Mood Journal", Icons.mood, const Color(0xFFD97706), MoodScreen(userId: widget.userId)),
          _compactTile("LifeScore 360", Icons.star_outline, const Color(0xFF7C3AED), LifeScoreScreen(userId: widget.userId)),
          _compactTile("Daily Streaks", Icons.local_fire_department, const Color(0xFFEA580C), StreakScreen(userId: widget.userId)),
          _compactTile("Achievements", Icons.emoji_events_outlined, const Color(0xFFCA8A04), AchievementsScreen(userId: widget.userId)),
          _compactTile("Daily Summary", Icons.today, const Color(0xFF0D9488), DailySummaryScreen(userId: widget.userId)),
          _compactTile("Day Summary", Icons.summarize_outlined, const Color(0xFF64748B), const SummaryScreen()),
        ]),
        const SizedBox(height: 18),

        // 4. Analytics & Deep Reports
        _sectionTitle("📊 Analytics & Deep Reports", const Color(0xFF7C3AED)),
        const SizedBox(height: 10),
        _gridSuite([
          _compactTile("Visual Charts", Icons.pie_chart, const Color(0xFF7C3AED), AnalyticsScreen(userId: widget.userId)),
          _compactTile("Monthly Map", Icons.calendar_view_month, const Color(0xFF0891B2), HeatmapScreen(userId: widget.userId)),
          _compactTile("Yearly Map", Icons.grid_on, const Color(0xFF059669), const YearlyHeatmapScreen()),
          _compactTile("Full Report", Icons.analytics, const Color(0xFFD97706), ReportScreen(userId: widget.userId)),
        ]),
      ],
    );
  }

  Widget _sectionTitle(String title, Color accent) {
    return Row(
      children: [
        Container(width: 3.5, height: 14, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
      ],
    );
  }

  Widget _gridSuite(List<Widget> items) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.95,
      children: items,
    );
  }

  Widget _compactTile(String label, IconData icon, Color color, Widget destination) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination)).then((_) => fetchDashboard()),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 17),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Ledger Activity",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(userId: widget.userId))),
              child: const Text("See All", style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 11.5)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (transactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text("No transactions recorded yet. Tap + Add Income to start.", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            ),
          )
        else
          ...transactions.take(4).map((t) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: t["type"] == "income" ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            t["type"] == "income" ? Icons.arrow_downward : Icons.arrow_upward,
                            color: t["type"] == "income" ? const Color(0xFF059669) : const Color(0xFFEF4444),
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t["title"] ?? "Untitled", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF0F172A))),
                            Text(t["category"] ?? "other", style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      "${t['type'] == 'income' ? '+' : '-'}₹${t['amount']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color: t["type"] == "income" ? const Color(0xFF059669) : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }
}