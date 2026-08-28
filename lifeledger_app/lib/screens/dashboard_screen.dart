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
import 'achievements_screen.dart';
import 'streak_screen.dart';
import 'networth_screen.dart';
import 'alerts_screen.dart';

import 'yearly_heatmap_screen.dart';
import 'summary_screen.dart';
import 'ai_advisor_screen.dart';

class DashboardScreen extends StatefulWidget {

  final String userName;

  final int userId;

  const DashboardScreen({

    super.key,

    required this.userName,

    required this.userId,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {

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

      var url = Uri.parse(
        "https://lifeledger-backend.onrender.com/dashboard/${widget.userId}/",
      );

      var res = await http.get(url);

      var data = jsonDecode(res.body);

      if (data["status"] == "success") {

        setState(() {

          balance =
              (data["balance"] ?? 0)
                  .toDouble();

          totalIncome =
              (data["total_income"] ?? 0)
                  .toDouble();

          totalExpense =
              (data["total_expense"] ?? 0)
                  .toDouble();

          pendingTasks =
              data["pending_tasks"] ?? 0;

          completedTasks =
              data["completed_tasks"] ?? 0;

          completedHabits =
              data["completed_habits"] ?? 0;

          totalHabits =
              data["total_habits"] ?? 0;

          transactions =
              data["transactions"] ?? [];

          _isLoading = false;
        });
      }

    } catch (e) {

      setState(() {

        _isLoading = false;
      });
    }
  }

  String greet() {

    int h = DateTime.now().hour;

    if (h < 12) {
      return "Good Morning";
    }

    if (h < 17) {
      return "Good Afternoon";
    }

    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Stack(
        children: [
          // Base dark gradient (same tone as before)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0a0f1e),
                  Color(0xFF101828),
                ],
              ),
            ),
          ),

          // Subtle glowing ambient orbs — decorative, doesn't affect layout/scroll
          Positioned(
            top: -60,
            right: -40,
            child: _glowOrb(
              size: 220,
              color: const Color(0xFF6c8fff),
              opacity: 0.18,
            ),
          ),
          Positioned(
            top: 260,
            left: -70,
            child: _glowOrb(
              size: 180,
              color: const Color(0xFFa78bfa),
              opacity: 0.14,
            ),
          ),
          Positioned(
            bottom: 40,
            right: -50,
            child: _glowOrb(
              size: 200,
              color: const Color(0xFF4ade80),
              opacity: 0.12,
            ),
          ),
          Positioned(
            bottom: 300,
            left: -40,
            child: _glowOrb(
              size: 150,
              color: const Color(0xFFfbbf24),
              opacity: 0.10,
            ),
          ),

          // Actual dashboard content, untouched
          SafeArea(

            child: RefreshIndicator(

              onRefresh: fetchDashboard,

              child: SingleChildScrollView(

                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding:
                    const EdgeInsets.all(20),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    _topBar(),

                    const SizedBox(height: 20),

                    _balanceCard(),

                    const SizedBox(height: 20),

                    _smartInsights(),

                    const SizedBox(height: 20),

                    _quickActions(),

                    const SizedBox(height: 20),

                    _alerts(),

                    const SizedBox(height: 20),

                    _stats(),

                    const SizedBox(height: 20),

                    _transactions(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Soft blurred glowing circle used for ambient background decoration
  Widget _glowOrb({
    required double size,
    required Color color,
    required double opacity,
  }) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(opacity),
              color.withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }

  // 🔝 TOP BAR

  Widget _topBar() {

    return Row(

      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [

        Text(

          "${greet()}, ${widget.userName}",

          style: const TextStyle(

            color: Colors.white,

            fontSize: 18,

            fontWeight:
                FontWeight.bold,
          ),
        ),

        Row(

          children: [

            IconButton(

              icon: const Icon(

                Icons.person,

                color: Colors.white,
              ),

              onPressed: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>

                        ProfileScreen(

                      userName:
                          widget.userName,

                      userId:
                          widget.userId,
                    ),
                  ),
                );
              },
            ),

            IconButton(

              icon: const Icon(

                Icons.logout,

                color: Colors.white,
              ),

              onPressed: () {

                Navigator.pushReplacement(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        LoginScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // 💰 BALANCE CARD

  Widget _balanceCard() {

    return Container(

      width: double.infinity,

      padding: EdgeInsets.all(20),

      decoration: BoxDecoration(

        gradient: LinearGradient(

          colors: [

            Color(0xFF6c8fff),

            Color(0xFFa78bfa),
          ],
        ),

        borderRadius:
            BorderRadius.circular(20),

        boxShadow: [

          BoxShadow(

            color: Color(0xFF6c8fff)
                .withOpacity(0.4),

            blurRadius: 25,
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(

            "Total Balance",

            style: TextStyle(

              color: Colors.white70,
            ),
          ),

          SizedBox(height: 8),

          Text(

            "₹ $balance",

            style: TextStyle(

              color: Colors.white,

              fontSize: 30,

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 🧠 SMART AI INSIGHTS & COACH
  Widget _smartInsights() {
    String msg = "ML Models Active: Financial wellness is stable";
    if (totalExpense > totalIncome) {
      msg = "⚠️ Deficit alert: Discretionary expenses exceed income";
    } else if (balance < 1000) {
      msg = "⚠️ Low liquid balance: Build your emergency fund";
    } else if (totalIncome > 0 && totalExpense / totalIncome < 0.6) {
      msg = "🌟 High savings rate! You are in the top 20% savings cohort";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2640), Color(0xFF161D31)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withOpacity(0.08),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 18),
                  SizedBox(width: 8),
                  Text(
                    "AI Predictive Intelligence",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "ML 2.0",
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            msg,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AIAdvisorScreen(
                          userId: widget.userId,
                          userName: widget.userName,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, color: Colors.white, size: 15),
                        SizedBox(width: 6),
                        Text(
                          "AI Coach",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PredictorScreen(
                          userId: widget.userId,
                          userName: widget.userName,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_graph, color: Color(0xFF38BDF8), size: 15),
                        SizedBox(width: 6),
                        Text(
                          "ML Forecast",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ⚡ ACTIONS
  Widget _quickActions() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        btn(
          "AI Coach",
          Icons.psychology,
          AIAdvisorScreen(
            userId: widget.userId,
            userName: widget.userName,
          ),
        ),

        btn(
          "Income",
          Icons.attach_money,
          IncomeScreen(
            userId: widget.userId,
          ),
        ),

        btn(
          "Expense",
          Icons.money_off,
          ExpenseScreen(
            userId: widget.userId,
          ),
        ),

        btn(
          "Habit",
          Icons.track_changes,
          HabitScreen(
            userId: widget.userId,
          ),
        ),

        btn(
          "Task",
          Icons.check_circle,
          TaskScreen(
            userId: widget.userId,
          ),
        ),

        btn(
          "Mood",
          Icons.mood,
          MoodScreen(
            userId: widget.userId,
          ),
        ),

        btn(
          "History",
          Icons.history,
          HistoryScreen(
            userId: widget.userId,
          ),
        ),

        btn(
          "Analytics",
          Icons.bar_chart,
          AnalyticsScreen(
            userId: widget.userId,
          ),
        ),

        btn(
          "Life Score",
          Icons.star,
          LifeScoreScreen(
            userId: widget.userId,
          ),
        ),

        btn(
          "Budget",
          Icons.wallet,
          BudgetScreen(
            userId: widget.userId,
          ),
        ),

        btn(
          "Predict",
          Icons.trending_up,
          PredictorScreen(
            userId: widget.userId,
          ),
        ),

        btn(
          "Behavior",
          Icons.psychology,
          BehaviorScreen(
            userId: widget.userId,
          ),
        ),

        btn(
          "Goals",
          Icons.flag,
          GoalsScreen(
            userId: widget.userId,
          ),
        ),

        btn(
          "Streaks",
          Icons.local_fire_department,
          StreakScreen(
            userId: widget.userId,
          ),
        ),

        btn(
          "Wealth",
          Icons.account_balance_wallet,
          NetWorthScreen(
            userId: widget.userId,
          ),
        ),

        btn(
          "Awards",
          Icons.emoji_events,
          AchievementsScreen(
            userId: widget.userId,
          ),
        ),

        // 🔥 NEW CALENDAR

        btn(
          "Calendar",
          Icons.calendar_month,
          YearlyHeatmapScreen(),
        ),

        // 🔥 SMART SUMMARY

        btn(
          "Summary",
          Icons.auto_graph,
          SummaryScreen(),
        ),

        // 🔥 SMART ALERTS (now using the real AlertsScreen with live backend data)
        btn(
          "Alerts",
          Icons.notifications_active,
          AlertsScreen(userId: widget.userId),
        ),
      ],
    );
  }

  Widget btn(
    String text,
    IconData icon,
    Widget screen,
  ) {

    return GestureDetector(

      onTap: () {

        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (_) => screen,
          ),
        ).then((_) {

          fetchDashboard();
        });
      },

      child: Container(

        width: 85,

        padding:
            EdgeInsets.symmetric(vertical: 14),

        decoration: BoxDecoration(

          color:
              Colors.white.withOpacity(0.05),

          borderRadius:
              BorderRadius.circular(14),
        ),

        child: Column(

          children: [

            Icon(

              icon,

              color: Color(0xFF6c8fff),
            ),

            SizedBox(height: 6),

            Text(

              text,

              textAlign: TextAlign.center,

              style: TextStyle(

                color: Colors.white70,

                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🚨 ALERTS

  Widget _alerts() {

    List<String> alerts = [];

    if (totalExpense > totalIncome) {

      alerts.add(
        "Overspending detected",
      );
    }

    if (pendingTasks > 0) {

      alerts.add(
        "$pendingTasks tasks pending",
      );
    }

    if (alerts.isEmpty) {

      alerts.add(
        "No alerts",
      );
    }

    return Column(

      children: alerts.map((a) {

        return Container(

          width: double.infinity,

          margin:
              EdgeInsets.only(bottom: 8),

          padding: EdgeInsets.all(12),

          decoration: BoxDecoration(

            color:
                Colors.orange.withOpacity(0.1),

            borderRadius:
                BorderRadius.circular(12),
          ),

          child: Text(

            "⚠ $a",

            style: TextStyle(

              color: Colors.orange,
            ),
          ),
        );

      }).toList(),
    );
  }

  // 📊 STATS

  Widget _stats() {

    return Row(

      children: [

        Expanded(

          child: _statCard(

            "Tasks",

            "$pendingTasks",

            Colors.orange,
          ),
        ),

        SizedBox(width: 10),

        Expanded(

          child: _statCard(

            "Done",

            "$completedTasks",

            Colors.green,
          ),
        ),

        SizedBox(width: 10),

        Expanded(

          child: _statCard(

            "Habits",

            "$completedHabits/$totalHabits",

            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _statCard(

    String title,

    String value,

    Color color,
  ) {

    return Container(

      padding: EdgeInsets.all(12),

      decoration: BoxDecoration(

        color:
            Colors.white.withOpacity(0.05),

        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Column(

        children: [

          Text(

            title,

            style: TextStyle(

              color: Colors.white54,
            ),
          ),

          SizedBox(height: 6),

          Text(

            value,

            style: TextStyle(

              color: color,

              fontSize: 16,

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 📄 TRANSACTIONS

  Widget _transactions() {

    if (_isLoading) {

      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (transactions.isEmpty) {

      return const Center(

        child: Text(

          "No data yet",

          style: TextStyle(
            color: Colors.white54,
          ),
        ),
      );
    }

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(

          "Recent Transactions",

          style: TextStyle(

            color: Colors.white,

            fontSize: 16,

            fontWeight:
                FontWeight.w600,
          ),
        ),

        SizedBox(height: 12),

        ...transactions.map((t) {

          bool isIncome =
              t["type"] == "income";

          return Container(

            margin:
                EdgeInsets.only(bottom: 10),

            padding: EdgeInsets.all(12),

            decoration: BoxDecoration(

              color:
                  Colors.white.withOpacity(0.04),

              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: Row(

              children: [

                Icon(

                  isIncome

                      ? Icons.arrow_downward

                      : Icons.arrow_upward,

                  color:

                      isIncome

                          ? Colors.green

                          : Colors.red,
                ),

                SizedBox(width: 10),

                Expanded(

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(

                        t["title"] ?? "",

                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),

                      Text(

                        t["category"] ?? "",

                        style: TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(

                  "₹${t["amount"]}",

                  style: TextStyle(

                    color:

                        isIncome

                            ? Colors.green

                            : Colors.red,
                  ),
                ),
              ],
            ),
          );

        }).toList(),
      ],
    );
  }
}