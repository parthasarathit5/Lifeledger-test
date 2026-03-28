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

class DashboardScreen extends StatefulWidget {
  final String userName;
  final int userId;
  DashboardScreen({required this.userName, required this.userId});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
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

  void fetchDashboard() async {
    try {
      var url = Uri.parse(
          "https://lifeledger-backend.onrender.com/dashboard/${widget.userId}/");
      var response = await http.get(url);
      var data = jsonDecode(response.body);
      if (data["status"] == "success") {
        setState(() {
          balance = data["balance"].toDouble();
          totalIncome = data["total_income"].toDouble();
          totalExpense = data["total_expense"].toDouble();
          pendingTasks = data["pending_tasks"];
          completedTasks = data["completed_tasks"] ?? 0;
          completedHabits = data["completed_habits"];
          totalHabits = data["total_habits"];
          transactions = data["transactions"];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _greeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0a0f1e), Color(0xFF101828), Color(0xFF0d1533)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => fetchDashboard(),
            color: Color(0xFF6c8fff),
            backgroundColor: Color(0xFF101828),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  SizedBox(height: 24),
                  _buildBalanceCard(),
                  SizedBox(height: 24),
                  _buildQuickActions(),
                  SizedBox(height: 24),
                  _buildStatsRow(),
                  SizedBox(height: 24),
                  _buildRecentTransactions(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${_greeting()}, ${widget.userName} 👋",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13)),
            Text("LifeLedger",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5)),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Icon(Icons.logout_rounded,
                    color: Colors.white.withOpacity(0.6), size: 14),
                SizedBox(width: 6),
                Text("Logout",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6c8fff), Color(0xFFa78bfa)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Color(0xFF6c8fff).withOpacity(0.35),
              blurRadius: 30,
              spreadRadius: 2)
        ],
      ),
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Balance",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13)),
                SizedBox(height: 8),
                Text("₹ ${balance.toStringAsFixed(2)}",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1)),
                SizedBox(height: 16),
                Row(
                  children: [
                    _statChip("↑ Income",
                        "₹ ${totalIncome.toStringAsFixed(0)}"),
                    SizedBox(width: 12),
                    _statChip("↓ Expense",
                        "₹ ${totalExpense.toStringAsFixed(0)}"),
                  ],
                )
              ],
            ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quick Actions",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        SizedBox(height: 16),
        // Row 1
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _actionButton(
              icon: Icons.remove_circle_outline_rounded,
              label: "Expense",
              color: Color(0xFFf87171),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExpenseScreen(userId: widget.userId),
                ),
              ).then((_) => fetchDashboard()),
            ),
            _actionButton(
              icon: Icons.add_circle_outline_rounded,
              label: "Income",
              color: Color(0xFF4ade80),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => IncomeScreen(userId: widget.userId),
                ),
              ).then((_) => fetchDashboard()),
            ),
            _actionButton(
              icon: Icons.track_changes_rounded,
              label: "Habits",
              color: Color(0xFF6c8fff),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HabitScreen(userId: widget.userId),
                ),
              ).then((_) => fetchDashboard()),
            ),
            _actionButton(
              icon: Icons.check_circle_outline_rounded,
              label: "Tasks",
              color: Color(0xFFa78bfa),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskScreen(userId: widget.userId),
                ),
              ).then((_) => fetchDashboard()),
            ),
          ],
        ),
        SizedBox(height: 12),
        // Row 2
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _actionButton(
              icon: Icons.mood_rounded,
              label: "Mood",
              color: Color(0xFFf472b6),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MoodScreen(userId: widget.userId),
                ),
              ).then((_) => fetchDashboard()),
            ),
            _actionButton(
              icon: Icons.history_rounded,
              label: "History",
              color: Color(0xFFfbbf24),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(userId: widget.userId),
                ),
              ).then((_) => fetchDashboard()),
            ),
            SizedBox(width: 76),
            SizedBox(width: 76),
          ],
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.track_changes_rounded,
            label: "Habits Today",
            value: "$completedHabits / $totalHabits",
            color: Color(0xFF6c8fff),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.pending_actions_rounded,
            label: "Pending Tasks",
            value: "$pendingTasks",
            color: Color(0xFFfbbf24),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.task_alt_rounded,
            label: "Completed",
            value: "$completedTasks",
            color: Color(0xFF4ade80),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 10)),
          SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
        ],
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
            Text("Recent Transactions",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(userId: widget.userId),
                ),
              ),
              child: Text("See all",
                  style: TextStyle(
                      color: Color(0xFF6c8fff), fontSize: 13)),
            ),
          ],
        ),
        SizedBox(height: 16),
        transactions.isEmpty
            ? Container(
                width: double.infinity,
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.07)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        color: Colors.white.withOpacity(0.15),
                        size: 40),
                    SizedBox(height: 10),
                    Text("No transactions yet",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 13)),
                  ],
                ),
              )
            : Column(
                children: transactions
                    .map((t) => _transactionItem(t))
                    .toList(),
              ),
      ],
    );
  }

  Widget _transactionItem(Map t) {
    bool isIncome = t["type"] == "income";
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: isIncome
                  ? Color(0xFF4ade80).withOpacity(0.1)
                  : Color(0xFFf87171).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isIncome ? Color(0xFF4ade80) : Color(0xFFf87171),
              size: 18,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t["title"],
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: 2),
                Text(t["category"],
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12)),
              ],
            ),
          ),
          Text(
            "${isIncome ? '+' : '-'}₹ ${t["amount"].toStringAsFixed(0)}",
            style: TextStyle(
              color: isIncome ? Color(0xFF4ade80) : Color(0xFFf87171),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 11)),
          SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}