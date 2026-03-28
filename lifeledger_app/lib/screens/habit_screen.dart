import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HabitScreen extends StatefulWidget {
  final int userId;
  HabitScreen({required this.userId});

  @override
  _HabitScreenState createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  final nameController = TextEditingController();
  String selectedIcon = '⭐';
  bool _isLoading = false;
  bool _isFetching = true;
  List pendingHabits = [];
  List completedHabits = [];

  final List<String> icons = [
    '⭐', '💪', '📚', '🏃', '💧', '🧘', '🎯', '🍎',
    '😴', '✍️', '🎵', '🧹', '💊', '🚴', '🌿', '🧠',
  ];

  @override
  void initState() {
    super.initState();
    fetchHabits();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void fetchHabits() async {
    try {
      var url = Uri.parse(
          "https://lifeledger-backend.onrender.com/habits/${widget.userId}/");
      var response = await http.get(url);
      var data = jsonDecode(response.body);
      if (data["status"] == "success") {
        setState(() {
          pendingHabits = data["habits"]
              .where((h) => h["completed_today"] == false)
              .toList();
          completedHabits = data["habits"]
              .where((h) => h["completed_today"] == true)
              .toList();
          _isFetching = false;
        });
      }
    } catch (e) {
      setState(() => _isFetching = false);
    }
  }

  void addHabit() async {
    if (nameController.text.isEmpty) {
      _showSnack("Please enter habit name");
      return;
    }
    setState(() => _isLoading = true);
    try {
      var url = Uri.parse(
          "https://lifeledger-backend.onrender.com/habits/${widget.userId}/");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text.trim(),
          "icon": selectedIcon,
        }),
      );
      var data = jsonDecode(response.body);
      if (data["status"] == "success") {
        nameController.clear();
        setState(() => selectedIcon = '⭐');
        Navigator.pop(context);
        fetchHabits();
        _showSnack("Habit added!");
      }
    } catch (e) {
      _showSnack("Unable to connect. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void completeHabit(int habitId, String name) async {
    try {
      var url = Uri.parse(
          "https://lifeledger-backend.onrender.com/habits/log/$habitId/");
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
      );
      fetchHabits();
      _showSnack("$name completed! Saved to history ✅");
    } catch (e) {
      _showSnack("Unable to update. Please try again.");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Color(0xFF1e2a4a),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showAddHabitSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Color(0xFF101828),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
              border:
                  Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text("Add Habit",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: "Habit name (e.g. Morning Run)",
                    hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.25)),
                    prefixIcon: Icon(Icons.track_changes_rounded,
                        color: Colors.white.withOpacity(0.4),
                        size: 20),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Color(0xFF6c8fff), width: 1.5)),
                  ),
                ),
                SizedBox(height: 16),
                Text("Pick an Icon",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: icons.map((icon) {
                    bool isSelected = selectedIcon == icon;
                    return GestureDetector(
                      onTap: () =>
                          setSheetState(() => selectedIcon = icon),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(0xFF6c8fff).withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? Color(0xFF6c8fff)
                                : Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Center(
                          child: Text(icon,
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Color(0xFF6c8fff),
                        Color(0xFFa78bfa)
                      ]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : addHabit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text("Add Habit",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                    ),
                  ),
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitItem(Map h, bool done) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: done
            ? Color(0xFF6c8fff).withOpacity(0.06)
            : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done
              ? Color(0xFF6c8fff).withOpacity(0.25)
              : Colors.white.withOpacity(0.07),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: done
                  ? Color(0xFF6c8fff).withOpacity(0.2)
                  : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: done
                    ? Color(0xFF6c8fff)
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Center(
              child: done
                  ? Icon(Icons.check_rounded,
                      color: Color(0xFF6c8fff), size: 22)
                  : Text(h["icon"],
                      style: TextStyle(fontSize: 20)),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(h["name"],
                    style: TextStyle(
                      color: done
                          ? Colors.white.withOpacity(0.4)
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration:
                          done ? TextDecoration.lineThrough : null,
                    )),
                SizedBox(height: 2),
                Text(
                  done
                      ? "Completed today → saved in history ✓"
                      : "Tap Complete when done",
                  style: TextStyle(
                      color: done
                          ? Color(0xFF6c8fff)
                          : Colors.white.withOpacity(0.3),
                      fontSize: 11),
                ),
              ],
            ),
          ),
          if (!done)
            GestureDetector(
              onTap: () => completeHabit(h["id"], h["name"]),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF6c8fff).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Color(0xFF6c8fff).withOpacity(0.3)),
                ),
                child: Text(
                  "Complete",
                  style: TextStyle(
                      color: Color(0xFF6c8fff),
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int total = pendingHabits.length + completedHabits.length;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0a0f1e),
              Color(0xFF101828),
              Color(0xFF0d1533)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 24, vertical: 20),
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
                              color:
                                  Colors.white.withOpacity(0.08)),
                        ),
                        child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16),
                      ),
                    ),
                    Text("Habits",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    GestureDetector(
                      onTap: _showAddHabitSheet,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Color(0xFF6c8fff),
                            Color(0xFFa78bfa)
                          ]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.add_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Color(0xFF6c8fff),
                      Color(0xFFa78bfa)
                    ]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Color(0xFF6c8fff).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2)
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Today's Progress",
                              style: TextStyle(
                                  color:
                                      Colors.white.withOpacity(0.8),
                                  fontSize: 13)),
                          SizedBox(height: 6),
                          Text(
                              "${completedHabits.length} / $total done",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text(
                            "Completed habits saved to history",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 11),
                          ),
                        ],
                      ),
                      Text(
                        total == 0
                            ? "🎯"
                            : completedHabits.length == total
                                ? "🏆"
                                : "💪",
                        style: TextStyle(fontSize: 40),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: _isFetching
                    ? Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF6c8fff)))
                    : (pendingHabits.isEmpty &&
                            completedHabits.isEmpty)
                        ? Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text("🏃",
                                    style:
                                        TextStyle(fontSize: 48)),
                                SizedBox(height: 12),
                                Text("No habits yet",
                                    style: TextStyle(
                                        color: Colors.white
                                            .withOpacity(0.3),
                                        fontSize: 14)),
                                SizedBox(height: 6),
                                Text(
                                    "Tap + to add your first habit",
                                    style: TextStyle(
                                        color: Colors.white
                                            .withOpacity(0.2),
                                        fontSize: 12)),
                              ],
                            ),
                          )
                        : ListView(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24),
                            children: [
                              if (pendingHabits.isNotEmpty) ...[
                                Padding(
                                  padding:
                                      EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    "Pending (${pendingHabits.length})",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight:
                                            FontWeight.w600),
                                  ),
                                ),
                                ...pendingHabits.map((h) =>
                                    _buildHabitItem(h, false)),
                              ],
                              if (completedHabits.isNotEmpty) ...[
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 8, bottom: 12),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Completed Today (${completedHabits.length})",
                                        style: TextStyle(
                                            color:
                                                Color(0xFF6c8fff),
                                            fontSize: 14,
                                            fontWeight:
                                                FontWeight.w600),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "→ saved in history",
                                        style: TextStyle(
                                            color: Colors.white
                                                .withOpacity(0.3),
                                            fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                ...completedHabits.map((h) =>
                                    _buildHabitItem(h, true)),
                              ],
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}