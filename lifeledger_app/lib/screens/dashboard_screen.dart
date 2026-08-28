import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_screen.dart';
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
import 'settings_screen.dart';
import 'report_screen.dart';

// New Advanced AI Modules
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF10B981)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${greet()}, ${widget.userName}",
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "LifeLedger AI Platform",
                  style: TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF334155)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AlertsScreen(userId: widget.userId)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF334155)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(userName: widget.userName, userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : RefreshIndicator(
              onRefresh: fetchDashboard,
              color: const Color(0xFF10B981),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroBalanceCard(),
                    const SizedBox(height: 18),
                    _buildAICoachBanner(),
                    const SizedBox(height: 24),
                    _buildQuickMetricStats(),
                    const SizedBox(height: 28),
                    _buildCategorizedSuite(),
                    const SizedBox(height: 28),
                    _buildRecentTransactions(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeroBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
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
                "Total Net Balance",
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "AI ML Live",
                  style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "₹${balance.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _balanceCol("Total Income", "₹${totalIncome.toStringAsFixed(0)}", const Color(0xFFFDE047), Icons.arrow_downward),
                Container(width: 1, height: 30, color: Colors.white24),
                _balanceCol("Total Expense", "₹${totalExpense.toStringAsFixed(0)}", Colors.white, Icons.arrow_upward),
                Container(width: 1, height: 30, color: Colors.white24),
                _balanceCol("Savings Rate", "${totalIncome > 0 ? (((totalIncome - totalExpense) / totalIncome) * 100).clamp(0, 100).toStringAsFixed(0) : 0}%", const Color(0xFF6EE7B7), Icons.pie_chart),
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
            Icon(icon, color: valColor, size: 12),
            const SizedBox(width: 4),
            Text(val, style: TextStyle(color: valColor, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
      ],
    );
  }

  Widget _buildAICoachBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ask LifeLedger AI Coach",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  totalExpense > totalIncome
                      ? "⚠️ High burn alert: Discretionary expenses exceed income."
                      : "✨ Models active: Positive monthly savings trajectory.",
                  style: TextStyle(
                    color: totalExpense > totalIncome ? const Color(0xFFEF4444) : const Color(0xFF059669),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text("Chat AI", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AIAdvisorScreen(userId: widget.userId, userName: widget.userName),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMetricStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard("Habits Done", "$completedHabits / $totalHabits", Icons.check_circle_outline, const Color(0xFF10B981)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard("Pending Tasks", "$pendingTasks", Icons.assignment_outlined, const Color(0xFFF59E0B)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard("Completed", "$completedTasks", Icons.task_alt, const Color(0xFF3B82F6)),
        ),
      ],
    );
  }

  Widget _statCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
          Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildCategorizedSuite() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. AI & Machine Learning Suite
        _sectionHeader("🤖 AI & Machine Learning Suite", const Color(0xFF059669)),
        const SizedBox(height: 12),
        _gridSuite([
          _suiteItem("AI Predictor", Icons.auto_graph, const Color(0xFF10B981), PredictorScreen(userId: widget.userId, userName: widget.userName)),
          _suiteItem("AI Coach Q&A", Icons.psychology, const Color(0xFF059669), AIAdvisorScreen(userId: widget.userId, userName: widget.userName)),
          _suiteItem("AI Wealth FIRE", Icons.rocket_launch, const Color(0xFFF59E0B), AIWealthSimulatorScreen(userId: widget.userId, userName: widget.userName)),
          _suiteItem("AI Tax Saver", Icons.receipt_long, const Color(0xFF3B82F6), AITaxSaverScreen(userId: widget.userId)),
          _suiteItem("AI Receipt OCR", Icons.document_scanner, const Color(0xFF8B5CF6), AISmartReceiptScreen(userId: widget.userId)),
          _suiteItem("AI Debt Payoff", Icons.speed, const Color(0xFF0D9488), AIDebtPayoffScreen(userId: widget.userId)),
          _suiteItem("AI Behavior", Icons.insights, const Color(0xFFEC4899), BehaviorScreen(userId: widget.userId)),
          _suiteItem("Smart Alerts", Icons.notifications_active, const Color(0xFFEF4444), AlertsScreen(userId: widget.userId)),
        ]),
        const SizedBox(height: 24),

        // 2. Cashflow & Wealth Hub
        _sectionHeader("💰 Cashflow & Wealth Hub", const Color(0xFFD97706)),
        const SizedBox(height: 12),
        _gridSuite([
          _suiteItem("Add Expense", Icons.remove_circle_outline, const Color(0xFFEF4444), ExpenseScreen(userId: widget.userId)),
          _suiteItem("Add Income", Icons.add_circle_outline, const Color(0xFF10B981), IncomeScreen(userId: widget.userId)),
          _suiteItem("Budget Matrix", Icons.wallet, const Color(0xFF6366F1), BudgetScreen(userId: widget.userId)),
          _suiteItem("Goal Tracker", Icons.flag_outlined, const Color(0xFFF59E0B), GoalsScreen(userId: widget.userId)),
          _suiteItem("Net Worth", Icons.account_balance, const Color(0xFF059669), NetWorthScreen(userId: widget.userId)),
          _suiteItem("Compare Months", Icons.compare_arrows, const Color(0xFF06B6D4), CompareScreen(userId: widget.userId)),
          _suiteItem("Ledger History", Icons.history, const Color(0xFF64748B), HistoryScreen(userId: widget.userId)),
          _suiteItem("Savings Goals", Icons.savings_outlined, const Color(0xFF84CC16), GoalScreen(userId: widget.userId)),
        ]),
        const SizedBox(height: 24),

        // 3. Habits & LifeScore
        _sectionHeader("🌱 Habits & LifeScore Engine", const Color(0xFF2563EB)),
        const SizedBox(height: 12),
        _gridSuite([
          _suiteItem("Habits Log", Icons.track_changes, const Color(0xFF10B981), HabitScreen(userId: widget.userId)),
          _suiteItem("Daily Tasks", Icons.checklist, const Color(0xFF3B82F6), TaskScreen(userId: widget.userId)),
          _suiteItem("Mood Journal", Icons.mood, const Color(0xFFF59E0B), MoodScreen(userId: widget.userId)),
          _suiteItem("LifeScore 360", Icons.star_outline, const Color(0xFF8B5CF6), LifeScoreScreen(userId: widget.userId)),
          _suiteItem("Daily Streaks", Icons.local_fire_department, const Color(0xFFEA580C), StreakScreen(userId: widget.userId)),
          _suiteItem("Achievements", Icons.emoji_events_outlined, const Color(0xFFEAB308), AchievementsScreen(userId: widget.userId)),
          _suiteItem("Daily Summary", Icons.today, const Color(0xFF0D9488), DailySummaryScreen(userId: widget.userId)),
          _suiteItem("Day Summary", Icons.summarize_outlined, const Color(0xFF64748B), const SummaryScreen()),
        ]),
        const SizedBox(height: 24),

        // 4. Analytics & Heatmaps
        _sectionHeader("📊 Analytics & Deep Reports", const Color(0xFF7C3AED)),
        const SizedBox(height: 12),
        _gridSuite([
          _suiteItem("Visual Analytics", Icons.pie_chart, const Color(0xFF8B5CF6), AnalyticsScreen(userId: widget.userId)),
          _suiteItem("Monthly Heatmap", Icons.calendar_view_month, const Color(0xFF06B6D4), HeatmapScreen(userId: widget.userId)),
          _suiteItem("Yearly Heatmap", Icons.grid_on, const Color(0xFF10B981), const YearlyHeatmapScreen()),
          _suiteItem("Financial Report", Icons.analytics, const Color(0xFFF59E0B), ReportScreen(userId: widget.userId)),
          _suiteItem("Profile Settings", Icons.person_outline, const Color(0xFF64748B), ProfileScreen(userName: widget.userName, userId: widget.userId)),
          _suiteItem("Security Settings", Icons.security, const Color(0xFF475569), const SettingsScreen()),
          _suiteItem("Smart Alerts", Icons.notifications_none, const Color(0xFF3B82F6), AlertsScreen(userId: widget.userId)),
          _suiteItem("Logout / Exit", Icons.logout, const Color(0xFFEF4444), LoginScreen()),
        ]),
      ],
    );
  }

  Widget _sectionHeader(String title, Color accent) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
      ],
    );
  }

  Widget _gridSuite(List<Widget> items) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.88,
      children: items,
    );
  }

  Widget _suiteItem(String label, IconData icon, Color color, Widget destination) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
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
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(userId: widget.userId))),
              child: const Text("See All", style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (transactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text("No transactions recorded yet. Tap + to add income or expenses.", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5)),
            ),
          )
        else
          ...transactions.take(5).map((t) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: t["type"] == "income" ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            t["type"] == "income" ? Icons.arrow_downward : Icons.arrow_upward,
                            color: t["type"] == "income" ? const Color(0xFF059669) : const Color(0xFFEF4444),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t["title"] ?? "Untitled", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                            Text(t["category"] ?? "other", style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      "${t['type'] == 'income' ? '+' : '-'}₹${t['amount']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
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