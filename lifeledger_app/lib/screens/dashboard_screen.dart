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
      backgroundColor: const Color(0xFFF1F5F9), // Soft background for high card contrast
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
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
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
                  style: TextStyle(color: Color(0xFF059669), fontSize: 10.5, fontWeight: FontWeight.bold),
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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1050),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Hero Balance Card (Vibrant Emerald Gradient)
                        _buildHeroBanner(),
                        const SizedBox(height: 14),

                        // 2. Step 1: Set Income CTA Card
                        _buildStep1IncomeCard(),
                        const SizedBox(height: 14),

                        // 3. AI Coach Banner
                        _buildAICoachCard(),
                        const SizedBox(height: 22),

                        // 4. Vibrant Categorized AI & Finance Suites
                        _buildRichSuites(),
                        const SizedBox(height: 24),

                        // 5. Recent Activity
                        _buildRecentTransactions(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF047857), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.3),
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
                "Total Net Balance",
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: Color(0xFFFDE047), size: 12),
                    SizedBox(width: 4),
                    Text(
                      "AI ML Active",
                      style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "₹${balance.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _balanceCol("Total Income", "₹${totalIncome.toStringAsFixed(0)}", const Color(0xFFFDE047), Icons.arrow_downward),
                Container(width: 1, height: 26, color: Colors.white24),
                _balanceCol("Total Expense", "₹${totalExpense.toStringAsFixed(0)}", Colors.white, Icons.arrow_upward),
                Container(width: 1, height: 26, color: Colors.white24),
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
            Icon(icon, color: valColor, size: 11),
            const SizedBox(width: 4),
            Text(val, style: TextStyle(color: valColor, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
      ],
    );
  }

  Widget _buildStep1IncomeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF059669).withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add_card, color: Color(0xFF059669), size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Step 1: Set Monthly Income",
                  style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                SizedBox(height: 2),
                Text(
                  "AI models automatically calculate budget, savings & forecast.",
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
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
        gradient: const LinearGradient(
          colors: [Color(0xFFFEF3C7), Color(0xFFFFFBEB)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.2),
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF92400E)),
                ),
                SizedBox(height: 2),
                Text(
                  "Ask anything: Affordability, tax saver, spending cuts & FIRE.",
                  style: TextStyle(color: Color(0xFF78350F), fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
            child: const Text("Chat AI", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRichSuites() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width > 750 ? 4 : (width > 450 ? 3 : 2);
        final double childAspectRatio = width > 750 ? 1.6 : 1.35;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. AI & Machine Learning Suite (Green & Emerald Theme)
            _sectionHeader("🤖 AI & Machine Learning Suite", const Color(0xFF059669)),
            const SizedBox(height: 10),
            _buildResponsiveGrid(
              crossAxisCount,
              childAspectRatio,
              [
                _greenCard("AI Predictor", "30-Day ML Forecast", Icons.auto_graph, const [Color(0xFF047857), Color(0xFF10B981)], PredictorScreen(userId: widget.userId, userName: widget.userName)),
                _greenCard("AI Coach Q&A", "Personal Advisor", Icons.psychology, const [Color(0xFF065F46), Color(0xFF059669)], AIAdvisorScreen(userId: widget.userId, userName: widget.userName)),
                _greenCard("AI Wealth FIRE", "Retirement Horizon", Icons.rocket_launch, const [Color(0xFF0F766E), Color(0xFF14B8A6)], AIWealthSimulatorScreen(userId: widget.userId, userName: widget.userName)),
                _greenCard("AI Tax Saver", "80C, 80D Radar", Icons.receipt_long, const [Color(0xFF1E3A8A), Color(0xFF3B82F6)], AITaxSaverScreen(userId: widget.userId)),
                _greenCard("AI Receipt OCR", "Auto-Itemizer", Icons.document_scanner, const [Color(0xFF581C87), Color(0xFF9333EA)], AISmartReceiptScreen(userId: widget.userId)),
                _greenCard("AI Debt Payoff", "Snowball Engine", Icons.speed, const [Color(0xFFC2410C), Color(0xFFF97316)], AIDebtPayoffScreen(userId: widget.userId)),
                _greenCard("AI Behavior", "Habit Velocity", Icons.insights, const [Color(0xFF9D174D), Color(0xFFEC4899)], BehaviorScreen(userId: widget.userId)),
                _greenCard("Smart Alerts", "Anomaly Radar", Icons.notifications_active, const [Color(0xFF991B1B), Color(0xFFEF4444)], AlertsScreen(userId: widget.userId)),
              ],
            ),
            const SizedBox(height: 22),

            // 2. Cashflow & Wealth Hub
            _sectionHeader("💰 Cashflow & Goals Hub", const Color(0xFFD97706)),
            const SizedBox(height: 10),
            _buildResponsiveGrid(
              crossAxisCount,
              childAspectRatio,
              [
                _greenCard("Add Expense", "Log with AI NLP", Icons.remove_circle_outline, const [Color(0xFF991B1B), Color(0xFFEF4444)], ExpenseScreen(userId: widget.userId)),
                _greenCard("Add Income", "Salary & Bonus", Icons.add_circle_outline, const [Color(0xFF047857), Color(0xFF10B981)], IncomeScreen(userId: widget.userId)),
                _greenCard("Budget Matrix", "Category Limits", Icons.wallet, const [Color(0xFF3730A3), Color(0xFF6366F1)], BudgetScreen(userId: widget.userId)),
                _greenCard("Goal Tracker", "Milestone Target", Icons.flag_outlined, const [Color(0xFFB45309), Color(0xFFF59E0B)], GoalsScreen(userId: widget.userId)),
                _greenCard("Net Worth", "Assets & Debt", Icons.account_balance, const [Color(0xFF065F46), Color(0xFF0D9488)], NetWorthScreen(userId: widget.userId)),
                _greenCard("Compare Months", "Spending Drift", Icons.compare_arrows, const [Color(0xFF0E7490), Color(0xFF06B6D4)], CompareScreen(userId: widget.userId)),
                _greenCard("Ledger History", "All Audit Trails", Icons.history, const [Color(0xFF334155), Color(0xFF64748B)], HistoryScreen(userId: widget.userId)),
                _greenCard("Savings Goals", "Emergency Fund", Icons.savings_outlined, const [Color(0xFF3F6212), Color(0xFF84CC16)], GoalScreen(userId: widget.userId)),
              ],
            ),
            const SizedBox(height: 22),

            // 3. Habits & LifeScore Hub
            _sectionHeader("🌱 Habits & LifeScore Engine", const Color(0xFF2563EB)),
            const SizedBox(height: 10),
            _buildResponsiveGrid(
              crossAxisCount,
              childAspectRatio,
              [
                _greenCard("Habits Log", "Daily Discipline", Icons.track_changes, const [Color(0xFF047857), Color(0xFF10B981)], HabitScreen(userId: widget.userId)),
                _greenCard("Daily Tasks", "Execution Matrix", Icons.checklist, const [Color(0xFF1E40AF), Color(0xFF3B82F6)], TaskScreen(userId: widget.userId)),
                _greenCard("Mood Journal", "Emotional Drift", Icons.mood, const [Color(0xFFB45309), Color(0xFFF59E0B)], MoodScreen(userId: widget.userId)),
                _greenCard("LifeScore 360", "Health Metric", Icons.star_outline, const [Color(0xFF6B21A8), Color(0xFFA855F7)], LifeScoreScreen(userId: widget.userId)),
                _greenCard("Daily Streaks", "Streak Flame", Icons.local_fire_department, const [Color(0xFFC2410C), Color(0xFFF97316)], StreakScreen(userId: widget.userId)),
                _greenCard("Achievements", "Badge Unlocks", Icons.emoji_events_outlined, const [Color(0xFF854D0E), Color(0xFFEAB308)], AchievementsScreen(userId: widget.userId)),
                _greenCard("Daily Summary", "Day Intelligence", Icons.today, const [Color(0xFF0F766E), Color(0xFF14B8A6)], DailySummaryScreen(userId: widget.userId)),
                _greenCard("Day Summary", "24-Hour Overview", Icons.summarize_outlined, const [Color(0xFF334155), Color(0xFF64748B)], const SummaryScreen()),
              ],
            ),
            const SizedBox(height: 22),

            // 4. Analytics & Deep Reports
            _sectionHeader("📊 Analytics & Deep Reports", const Color(0xFF7C3AED)),
            const SizedBox(height: 10),
            _buildResponsiveGrid(
              crossAxisCount,
              childAspectRatio,
              [
                _greenCard("Visual Charts", "Category Shares", Icons.pie_chart, const [Color(0xFF6B21A8), Color(0xFFA855F7)], AnalyticsScreen(userId: widget.userId)),
                _greenCard("Monthly Map", "Expense Heat", Icons.calendar_view_month, const [Color(0xFF0E7490), Color(0xFF06B6D4)], HeatmapScreen(userId: widget.userId)),
                _greenCard("Yearly Map", "365-Day Grid", Icons.grid_on, const [Color(0xFF047857), Color(0xFF10B981)], const YearlyHeatmapScreen()),
                _greenCard("Full Report", "Financial Audit", Icons.analytics, const [Color(0xFFB45309), Color(0xFFF59E0B)], ReportScreen(userId: widget.userId)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _sectionHeader(String title, Color accent) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
      ],
    );
  }

  Widget _buildResponsiveGrid(int count, double ratio, List<Widget> items) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: count,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: ratio,
      children: items,
    );
  }

  Widget _greenCard(String title, String subtitle, IconData icon, List<Color> gradientColors, Widget destination) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination)).then((_) => fetchDashboard()),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.28),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
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
              child: const Text("See All", style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 12)),
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