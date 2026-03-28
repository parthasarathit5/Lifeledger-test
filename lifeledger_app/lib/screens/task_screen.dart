import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskScreen extends StatefulWidget {
  final int userId;
  TaskScreen({required this.userId});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final titleController = TextEditingController();
  String selectedPriority = 'medium';
  bool _isLoading = false;
  bool _isFetching = true;
  List pendingTasks = [];
  List completedTasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void fetchTasks() async {
    try {
      var url =
          Uri.parse("https://lifeledger-backend.onrender.com/tasks/${widget.userId}/");
      var response = await http.get(url);
      var data = jsonDecode(response.body);
      if (data["status"] == "success") {
        setState(() {
          pendingTasks = data["tasks"]
              .where((t) => t["completed"] == false)
              .toList();
          completedTasks = data["tasks"]
              .where((t) => t["completed"] == true)
              .toList();
          _isFetching = false;
        });
      }
    } catch (e) {
      setState(() => _isFetching = false);
    }
  }

  void addTask() async {
    if (titleController.text.isEmpty) {
      _showSnack("Please enter task title");
      return;
    }
    setState(() => _isLoading = true);
    try {
      var url =
          Uri.parse("https://lifeledger-backend.onrender.com/tasks/${widget.userId}/");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": titleController.text.trim(),
          "priority": selectedPriority,
        }),
      );
      var data = jsonDecode(response.body);
      if (data["status"] == "success") {
        titleController.clear();
        setState(() => selectedPriority = 'medium');
        Navigator.pop(context);
        fetchTasks();
        _showSnack("Task added!");
      }
    } catch (e) {
      _showSnack("Unable to connect. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void completeTask(int id, String title) async {
    try {
      var url =
          Uri.parse("https://lifeledger-backend.onrender.com/tasks/${widget.userId}/");
      await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );
      fetchTasks();
      _showSnack("Task completed! Saved to history ✅");
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

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Color(0xFFf87171);
      case 'medium':
        return Color(0xFFfbbf24);
      case 'low':
        return Color(0xFF4ade80);
      default:
        return Color(0xFF6c8fff);
    }
  }

  String _priorityLabel(String priority) {
    switch (priority) {
      case 'high':
        return '🔴 High';
      case 'medium':
        return '🟡 Medium';
      case 'low':
        return '🟢 Low';
      default:
        return '🔵 Medium';
    }
  }

  void _showAddTaskSheet() {
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
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text("Add Task",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: "Task title (e.g. Buy groceries)",
                    hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.25)),
                    prefixIcon: Icon(
                        Icons.check_circle_outline_rounded,
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
                            color: Color(0xFFa78bfa), width: 1.5)),
                  ),
                ),
                SizedBox(height: 16),
                Text("Priority",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                Row(
                  children: ['low', 'medium', 'high'].map((p) {
                    bool isSelected = selectedPriority == p;
                    Color pColor = _priorityColor(p);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setSheetState(
                            () => selectedPriority = p),
                        child: Container(
                          margin: EdgeInsets.only(
                              right: p != 'high' ? 8 : 0),
                          padding:
                              EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? pColor.withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? pColor
                                  : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _priorityLabel(p),
                              style: TextStyle(
                                color: isSelected
                                    ? pColor
                                    : Colors.white.withOpacity(0.5),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
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
                        Color(0xFFa78bfa),
                        Color(0xFF6c8fff)
                      ]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : addTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2))
                          : Text("Add Task",
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

  Widget _buildTaskItem(Map t, bool done) {
    Color pColor = _priorityColor(t["priority"]);
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: done
            ? Colors.white.withOpacity(0.02)
            : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done
              ? Color(0xFF4ade80).withOpacity(0.15)
              : pColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: done
                  ? Color(0xFF4ade80).withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: done
                    ? Color(0xFF4ade80)
                    : Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: done
                ? Icon(Icons.check_rounded,
                    color: Color(0xFF4ade80), size: 16)
                : null,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t["title"],
                    style: TextStyle(
                      color: done
                          ? Colors.white.withOpacity(0.35)
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration:
                          done ? TextDecoration.lineThrough : null,
                    )),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: pColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _priorityLabel(t["priority"]),
                        style: TextStyle(
                            color: pColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    if (done && t["completed_at"] != null) ...[
                      SizedBox(width: 8),
                      Text(
                        "Done on ${t["completed_at"]}",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (!done)
            GestureDetector(
              onTap: () => completeTask(t["id"], t["title"]),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF4ade80).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Color(0xFF4ade80).withOpacity(0.3)),
                ),
                child: Text(
                  "Complete",
                  style: TextStyle(
                      color: Color(0xFF4ade80),
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
                    Text("Tasks",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    GestureDetector(
                      onTap: _showAddTaskSheet,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Color(0xFFa78bfa),
                            Color(0xFF6c8fff)
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
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              Color(0xFFfbbf24).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Color(0xFFfbbf24)
                                  .withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Text("${pendingTasks.length}",
                                style: TextStyle(
                                    color: Color(0xFFfbbf24),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700)),
                            Text("Pending",
                                style: TextStyle(
                                    color: Colors.white
                                        .withOpacity(0.5),
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              Color(0xFF4ade80).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Color(0xFF4ade80)
                                  .withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Text("${completedTasks.length}",
                                style: TextStyle(
                                    color: Color(0xFF4ade80),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700)),
                            Text("Completed",
                                style: TextStyle(
                                    color: Colors.white
                                        .withOpacity(0.5),
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: _isFetching
                    ? Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF6c8fff)))
                    : (pendingTasks.isEmpty && completedTasks.isEmpty)
                        ? Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text("✅",
                                    style:
                                        TextStyle(fontSize: 48)),
                                SizedBox(height: 12),
                                Text("No tasks yet",
                                    style: TextStyle(
                                        color: Colors.white
                                            .withOpacity(0.3),
                                        fontSize: 14)),
                                SizedBox(height: 6),
                                Text(
                                    "Tap + to add your first task",
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
                              if (pendingTasks.isNotEmpty) ...[
                                Padding(
                                  padding: EdgeInsets.only(
                                      bottom: 12),
                                  child: Text(
                                    "Pending (${pendingTasks.length})",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight:
                                            FontWeight.w600),
                                  ),
                                ),
                                ...pendingTasks.map(
                                    (t) => _buildTaskItem(t, false)),
                              ],
                              if (completedTasks.isNotEmpty) ...[
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 8, bottom: 12),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Completed (${completedTasks.length})",
                                        style: TextStyle(
                                            color: Color(0xFF4ade80),
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
                                ...completedTasks.map(
                                    (t) => _buildTaskItem(t, true)),
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