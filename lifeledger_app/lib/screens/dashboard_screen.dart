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
      backgroundColor: const Color(0xFFF8FAFC), // Crisp clean background
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
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
              ),
              child: const Icon(Icons.auto_awesome, color: Color(0xFF059669), size: 18),
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
                  "LifeLedger AI • Supabase Synced",
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Hero Balance Banner (Light Green Box)
                        _buildHeroBanner(),
                        const SizedBox(height: 12),

                        // 2. Step 1: Set Income Banner (Light Green Box)
                        _buildStep1IncomeCard(),
                        const SizedBox(height: 12),

                        // 3. AI Coach Banner (Light Green / Warm Amber Accent)
                        _buildAICoachCard(),
                        const SizedBox(height: 20),

                        // 4. Small Light Green Dashboard Boxes
                        _buildSmallGreenDashboardsSuite(),
                        const SizedBox(height: 22),

                        // 5. Recent Activity
                        _buildRecentTransactions(),
                        const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5), // Light Green Box
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.12),
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
                "Total Net Balance",
                style: TextStyle(color: Color(0xFF065F46), fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: Color(0xFF059669), size: 13),
                    SizedBox(width: 4),
                    Text(
                      "Supabase Live",
                      style: TextStyle(color: Color(0xFF059669), fontSize: 10.5, fontWeight: FontWeight.bold),
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
              color: Color(0xFF047857),
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _balanceCol("Total Income", "₹${totalIncome.toStringAsFixed(0)}", const Color(0xFF059669), Icons.arrow_downward),
                Container(width: 1, height: 24, color: const Color(0xFFD1FAE5)),
                _balanceCol("Total Expense", "₹${totalExpense.toStringAsFixed(0)}", const Color(0xFFDC2626), Icons.arrow_upward),
                Container(width: 1, height: 24, color: const Color(0xFFD1FAE5)),
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
            Text(val, style: TextStyle(color: valColor, fontWeight: FontWeight.bold, fontSize: 12.5)),
          ],
        ),
        const SizedBox(height: 1),
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
      ],
    );
  }

  Widget _buildStep1IncomeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5), // Light Green Box
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF10B981), width: 1.3),
        boxShadow: [
          BoxShadow(color: const Color(0xFF10B981).withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF059669),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add_card, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Step 1: Set Monthly Income",
                  style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  "AI models automatically calculate budget, forecast & limits.",
                  style: TextStyle(color: Color(0xFF047857), fontSize: 10.5),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => IncomeScreen(userId: widget.userId))).then((_) => fetchDashboard());
            },
            child: const Text("+ Add Income", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAICoachCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // Light Mint Green Box
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF34D399), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF059669),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "LifeLedger Precision AI Advisor",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF065F46)),
                ),
                Text(
                  "Ask anything: Affordability, Tax Saver, Spending Cuts & FIRE.",
                  style: TextStyle(color: Color(0xFF047857), fontSize: 10.5),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            child: const Text("Chat AI", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallGreenDashboardsSuite() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        // Responsive grid: 4 columns on desktop, 3 on tablet, 2 on mobile
        final int crossAxisCount = width > 750 ? 4 : (width > 480 ? 3 : 2);
        final double childAspectRatio = width > 750 ? 2.5 : (width > 480 ? 2.2 : 2.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. AI & Machine Learning Suite (Light Green Boxes)
            _sectionHeader("🤖 AI & Machine Learning Suite"),
            const SizedBox(height: 8),
            _buildResponsiveGrid(
              crossAxisCount,
              childAspectRatio,
              [
                _lightGreenTile("AI Predictor", "30-Day Regressor", "99.6% R²", Icons.auto_graph, PredictorScreen(userId: widget.userId, userName: widget.userName)),
                _lightGreenTile("AI Coach Q&A", "Personal Advisor", "Active", Icons.psychology, AIAdvisorScreen(userId: widget.userId, userName: widget.userName)),
                _lightGreenTile("AI Wealth FIRE", "SIP Horizon", "Compound", Icons.rocket_launch, AIWealthSimulatorScreen(userId: widget.userId, userName: widget.userName)),
                _lightGreenTile("AI Tax Saver", "80C, 80D Radar", "Deductions", Icons.receipt_long, AITaxSaverScreen(userId: widget.userId)),
                _lightGreenTile("AI Receipt OCR", "Bill Itemizer", "OCR Scan", Icons.document_scanner, AISmartReceiptScreen(userId: widget.userId)),
                _lightGreenTile("AI Debt Payoff", "Snowball Matrix", "Payoff", Icons.speed, AIDebtPayoffScreen(userId: widget.userId)),
                _lightGreenTile("AI Behavior", "Habit Velocity", "Discipline", Icons.insights, BehaviorScreen(userId: widget.userId)),
                _lightGreenTile("Smart Alerts", "Anomaly Radar", "Outliers", Icons.notifications_active, AlertsScreen(userId: widget.userId)),
              ],
            ),
            const SizedBox(height: 18),

            // 2. Cashflow & Goals Hub (Light Green Boxes)
            _sectionHeader("💰 Cashflow & Goals Hub"),
            const SizedBox(height: 8),
            _buildResponsiveGrid(
              crossAxisCount,
              childAspectRatio,
              [
                _lightGreenTile("Add Expense", "AI Categorized", "Outflow", Icons.remove_circle_outline, ExpenseScreen(userId: widget.userId)),
                _lightGreenTile("Add Income", "Salary & Bonus", "Inflow", Icons.add_circle_outline, IncomeScreen(userId: widget.userId)),
                _lightGreenTile("Budget Matrix", "Category Limits", "Limits", Icons.wallet, BudgetScreen(userId: widget.userId)),
                _lightGreenTile("Goal Tracker", "Target Milestones", "Target", Icons.flag_outlined, GoalsScreen(userId: widget.userId)),
                _lightGreenTile("Net Worth", "Assets & Debt", "Equity", Icons.account_balance, NetWorthScreen(userId: widget.userId)),
                _lightGreenTile("Compare Months", "Spending Drift", "Variance", Icons.compare_arrows, CompareScreen(userId: widget.userId)),
                _lightGreenTile("Ledger History", "Audit Records", "History", Icons.history, HistoryScreen(userId: widget.userId)),
                _lightGreenTile("Savings Goals", "Emergency Fund", "Safety", Icons.savings_outlined, GoalScreen(userId: widget.userId)),
              ],
            ),
            const SizedBox(height: 18),

            // 3. Habits & LifeScore Hub (Light Green Boxes)
            _sectionHeader("🌱 Habits & LifeScore Engine"),
            const SizedBox(height: 8),
            _buildResponsiveGrid(
              crossAxisCount,
              childAspectRatio,
              [
                _lightGreenTile("Habits Log", "Daily Discipline", "Streaks", Icons.track_changes, HabitScreen(userId: widget.userId)),
                _lightGreenTile("Daily Tasks", "Execution Matrix", "Tasks", Icons.checklist, TaskScreen(userId: widget.userId)),
                _lightGreenTile("Mood Journal", "Emotional Drift", "Mindset", Icons.mood, MoodScreen(userId: widget.userId)),
                _lightGreenTile("LifeScore 360", "Health Metric", "Score", Icons.star_outline, LifeScoreScreen(userId: widget.userId)),
                _lightGreenTile("Daily Streaks", "Streak Flame", "Ignited", Icons.local_fire_department, StreakScreen(userId: widget.userId)),
                _lightGreenTile("Achievements", "Badge Unlocks", "Trophy", Icons.emoji_events_outlined, AchievementsScreen(userId: widget.userId)),
                _lightGreenTile("Daily Summary", "Day Intelligence", "Today", Icons.today, DailySummaryScreen(userId: widget.userId)),
                _lightGreenTile("Day Summary", "24-Hour Review", "Overview", Icons.summarize_outlined, const SummaryScreen()),
              ],
            ),
            const SizedBox(height: 18),

            // 4. Analytics & Deep Reports (Light Green Boxes)
            _sectionHeader("📊 Analytics & Deep Reports"),
            const SizedBox(height: 8),
            _buildResponsiveGrid(
              crossAxisCount,
              childAspectRatio,
              [
                _lightGreenTile("Visual Charts", "Category Shares", "Charts", Icons.pie_chart, AnalyticsScreen(userId: widget.userId)),
                _lightGreenTile("Monthly Map", "Expense Heatmap", "Monthly", Icons.calendar_view_month, HeatmapScreen(userId: widget.userId)),
                _lightGreenTile("Yearly Map", "365-Day Matrix", "Annual", Icons.grid_on, const YearlyHeatmapScreen()),
                _lightGreenTile("Full Report", "Financial Audit", "Report", Icons.analytics, ReportScreen(userId: widget.userId)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(width: 3.5, height: 15, decoration: BoxDecoration(color: const Color(0xFF059669), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
        ),
      ],
    );
  }

  Widget _buildResponsiveGrid(int count, double ratio, List<Widget> items) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: count,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: ratio,
      children: items,
    );
  }

  Widget _lightGreenTile(String title, String subtitle, String badge, IconData icon, Widget destination) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination)).then((_) => fetchDashboard()),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5), // Light Green Box Background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.45), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF059669),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 15),
            ),
            const SizedBox(width: 8),
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
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF064E3B), // Deep Green Text
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF059669), // Green Subtitle
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.35)),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF047857),
                ),
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
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(userId: widget.userId))),
              child: const Text("See All", style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 11.5)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (transactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
            ),
            child: const Center(
              child: Text("No transactions recorded yet. Tap + Add Income to start.", style: TextStyle(color: Color(0xFF059669), fontSize: 11.5)),
            ),
          )
        else
          ...transactions.take(4).map((t) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5), // Light Green Box
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: t["type"] == "income" ? const Color(0xFF059669) : const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            t["type"] == "income" ? Icons.arrow_downward : Icons.arrow_upward,
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t["title"] ?? "Untitled", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF064E3B))),
                            Text(t["category"] ?? "other", style: const TextStyle(color: Color(0xFF059669), fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      "${t['type'] == 'income' ? '+' : '-'}₹${t['amount']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: t["type"] == "income" ? const Color(0xFF047857) : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }
}