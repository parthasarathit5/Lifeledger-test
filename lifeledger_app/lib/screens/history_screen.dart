import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryScreen extends StatefulWidget {
  final int userId;
  HistoryScreen({required this.userId});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isFetching = true;
  List history = [];
  String selectedType = 'all';
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final List<Map> types = [
    {'value': 'all', 'label': 'All', 'icon': '📋'},
    {'value': 'expense', 'label': 'Expense', 'icon': '💸'},
    {'value': 'income', 'label': 'Income', 'icon': '💰'},
    {'value': 'task', 'label': 'Tasks', 'icon': '✅'},
    {'value': 'habit', 'label': 'Habits', 'icon': '🏃'},
    {'value': 'mood', 'label': 'Mood', 'icon': '😄'},
  ];

  final List<String> months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  void fetchHistory() async {
    setState(() => _isFetching = true);
    try {
      String url =
          "https://lifeledger-backend.onrender.com/history/${widget.userId}/?month=$selectedMonth&year=$selectedYear";
      if (selectedType != 'all') {
        url += "&type=$selectedType";
      }
      var response = await http.get(Uri.parse(url));
      var data = jsonDecode(response.body);
      if (data["status"] == "success") {
        setState(() {
          history = data["history"];
          _isFetching = false;
        });
      }
    } catch (e) {
      setState(() => _isFetching = false);
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'expense':
        return Color(0xFFf87171);
      case 'income':
        return Color(0xFF4ade80);
      case 'task':
        return Color(0xFFa78bfa);
      case 'habit':
        return Color(0xFF6c8fff);
      case 'mood':
        return Color(0xFFfbbf24);
      default:
        return Color(0xFF6c8fff);
    }
  }

  String _typeIcon(String type) {
    switch (type) {
      case 'expense':
        return '💸';
      case 'income':
        return '💰';
      case 'task':
        return '✅';
      case 'habit':
        return '🏃';
      case 'mood':
        return '😄';
      default:
        return '📋';
    }
  }

  double get totalExpense => history
      .where((h) => h['type'] == 'expense')
      .fold(0, (sum, h) => sum + (h['amount'] ?? 0).toDouble());

  double get totalIncome => history
      .where((h) => h['type'] == 'income')
      .fold(0, (sum, h) => sum + (h['amount'] ?? 0).toDouble());

  int get completedTasks =>
      history.where((h) => h['type'] == 'task').length;

  int get completedHabits =>
      history.where((h) => h['type'] == 'habit').length;

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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    Text("History",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    Container(width: 40),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedMonth,
                            dropdownColor: Color(0xFF101828),
                            style: TextStyle(
                                color: Colors.white, fontSize: 13),
                            items: List.generate(12, (i) {
                              return DropdownMenuItem(
                                value: i + 1,
                                child: Text(months[i]),
                              );
                            }),
                            onChanged: (val) {
                              setState(() => selectedMonth = val!);
                              fetchHistory();
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedYear,
                            dropdownColor: Color(0xFF101828),
                            style: TextStyle(
                                color: Colors.white, fontSize: 13),
                            items: [2024, 2025, 2026, 2027].map((y) {
                              return DropdownMenuItem(
                                value: y,
                                child: Text(y.toString()),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => selectedYear = val!);
                              fetchHistory();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: types.map((t) {
                      bool isSelected = selectedType == t['value'];
                      Color tColor = _typeColor(t['value']);
                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedType = t['value']);
                          fetchHistory();
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 8),
                          padding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? tColor.withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? tColor
                                  : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            "${t['icon']} ${t['label']}",
                            style: TextStyle(
                              color: isSelected
                                  ? tColor
                                  : Colors.white.withOpacity(0.5),
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                          "💸 Spent",
                          "₹${totalExpense.toStringAsFixed(0)}",
                          Color(0xFFf87171)),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _summaryCard(
                          "💰 Earned",
                          "₹${totalIncome.toStringAsFixed(0)}",
                          Color(0xFF4ade80)),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _summaryCard(
                          "✅ Tasks",
                          "$completedTasks done",
                          Color(0xFFa78bfa)),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _summaryCard(
                          "🏃 Habits",
                          "$completedHabits done",
                          Color(0xFF6c8fff)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: _isFetching
                    ? Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF6c8fff)))
                    : history.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("📋",
                                    style: TextStyle(fontSize: 48)),
                                SizedBox(height: 12),
                                Text("No history found",
                                    style: TextStyle(
                                        color:
                                            Colors.white.withOpacity(0.3),
                                        fontSize: 14)),
                                SizedBox(height: 6),
                                Text(
                                    "Try selecting a different month or filter",
                                    style: TextStyle(
                                        color:
                                            Colors.white.withOpacity(0.2),
                                        fontSize: 12)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding:
                                EdgeInsets.symmetric(horizontal: 24),
                            itemCount: history.length,
                            itemBuilder: (_, i) {
                              var h = history[i];
                              Color hColor = _typeColor(h['type']);
                              return Container(
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                      color: hColor.withOpacity(0.15)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44, height: 44,
                                      decoration: BoxDecoration(
                                        color: hColor.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _typeIcon(h['type']),
                                          style:
                                              TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(h['title'],
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight.w500)),
                                          SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets
                                                    .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: hColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(4),
                                                ),
                                                child: Text(
                                                  h['type']
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      color: hColor,
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight
                                                              .w600),
                                                ),
                                              ),
                                              SizedBox(width: 6),
                                              Text(h['date'],
                                                  style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(
                                                              0.3),
                                                      fontSize: 11)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (h['amount'] != null)
                                      Text(
                                        "${h['type'] == 'income' ? '+' : '-'}₹${(h['amount'] as num).toStringAsFixed(0)}",
                                        style: TextStyle(
                                          color: hColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 9,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}