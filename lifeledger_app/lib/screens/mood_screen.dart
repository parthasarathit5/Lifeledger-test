import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MoodScreen extends StatefulWidget {
  final int userId;
  MoodScreen({required this.userId});

  @override
  _MoodScreenState createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  bool _isFetching = true;
  bool _isLoading = false;
  List moods = [];
  String? todayMood;
  final noteController = TextEditingController();

  final List<Map> moodOptions = [
    {'value': 'great', 'emoji': '😄', 'label': 'Great', 'color': 0xFF4ade80},
    {'value': 'good', 'emoji': '🙂', 'label': 'Good', 'color': 0xFF6c8fff},
    {'value': 'okay', 'emoji': '😐', 'label': 'Okay', 'color': 0xFFfbbf24},
    {'value': 'bad', 'emoji': '😔', 'label': 'Bad', 'color': 0xFFf87171},
    {'value': 'terrible', 'emoji': '😢', 'label': 'Terrible', 'color': 0xFFa78bfa},
  ];

  @override
  void initState() {
    super.initState();
    fetchMoods();
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  void fetchMoods() async {
    try {
      var url =
          Uri.parse("https://lifeledger-backend.onrender.com/mood/${widget.userId}/");
      var response = await http.get(url);
      var data = jsonDecode(response.body);
      if (data["status"] == "success") {
        setState(() {
          moods = data["moods"];
          _isFetching = false;
          if (moods.isNotEmpty) {
            String today =
                DateTime.now().toString().split(' ')[0];
            if (moods[0]["date"] == today) {
              todayMood = moods[0]["mood"];
            }
          }
        });
      }
    } catch (e) {
      setState(() => _isFetching = false);
    }
  }

  void logMood(String mood) async {
    setState(() => _isLoading = true);
    try {
      var url =
          Uri.parse("https://lifeledger-backend.onrender.com/mood/${widget.userId}/");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "mood": mood,
          "note": noteController.text.trim(),
        }),
      );
      var data = jsonDecode(response.body);
      if (data["status"] == "success") {
        noteController.clear();
        Navigator.pop(context);
        fetchMoods();
        _showSnack("Mood logged! Saved to history ✅");
      }
    } catch (e) {
      _showSnack("Unable to connect. Please try again.");
    } finally {
      setState(() => _isLoading = false);
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

  void _showLogMoodSheet() {
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
                Text("How are you feeling?",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text("Log your mood for today",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 13)),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: moodOptions.map((m) {
                    bool isSelected = todayMood == m['value'];
                    Color mColor = Color(m['color'] as int);
                    return GestureDetector(
                      onTap: () {
                        setSheetState(
                            () => todayMood = m['value'] as String);
                        setState(
                            () => todayMood = m['value'] as String);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? mColor.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius:
                                  BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? mColor
                                    : Colors.white
                                        .withOpacity(0.1),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(m['emoji'] as String,
                                  style:
                                      TextStyle(fontSize: 26)),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(m['label'] as String,
                              style: TextStyle(
                                color: isSelected
                                    ? mColor
                                    : Colors.white
                                        .withOpacity(0.4),
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: noteController,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Add a note (optional)",
                    hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.25)),
                    prefixIcon: Icon(Icons.note_outlined,
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
                            color: Color(0xFFfbbf24), width: 1.5)),
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Color(0xFFfbbf24),
                        Color(0xFFf59e0b)
                      ]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading || todayMood == null
                          ? null
                          : () => logMood(todayMood!),
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
                                  color: Colors.white,
                                  strokeWidth: 2))
                          : Text("Log Mood →",
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

  String _getMoodEmoji(String mood) {
    return moodOptions.firstWhere(
            (m) => m['value'] == mood,
            orElse: () => {'emoji': '😐'})['emoji'] as String;
  }

  Color _getMoodColor(String mood) {
    return Color(moodOptions.firstWhere(
            (m) => m['value'] == mood,
            orElse: () => {'color': 0xFF6c8fff})['color'] as int);
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
                    Text("Mood Tracker",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    GestureDetector(
                      onTap: _showLogMoodSheet,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Color(0xFFfbbf24),
                            Color(0xFFf59e0b)
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
                      Color(0xFFfbbf24),
                      Color(0xFFf59e0b)
                    ]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color:
                              Color(0xFFfbbf24).withOpacity(0.3),
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
                          Text("Today's Mood",
                              style: TextStyle(
                                  color:
                                      Colors.white.withOpacity(0.8),
                                  fontSize: 13)),
                          SizedBox(height: 6),
                          Text(
                            todayMood != null
                                ? todayMood!
                                    .substring(0, 1)
                                    .toUpperCase() +
                                    todayMood!.substring(1)
                                : "Not logged yet",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 4),
                          Text(
                            todayMood != null
                                ? "Saved to history ✓"
                                : "Tap + to log your mood",
                            style: TextStyle(
                                color:
                                    Colors.white.withOpacity(0.7),
                                fontSize: 11),
                          ),
                        ],
                      ),
                      Text(
                        todayMood != null
                            ? _getMoodEmoji(todayMood!)
                            : "😐",
                        style: TextStyle(fontSize: 48),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Mood History",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    Text("Last 30 days",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 12)),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: _isFetching
                    ? Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF6c8fff)))
                    : moods.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text("😐",
                                    style:
                                        TextStyle(fontSize: 48)),
                                SizedBox(height: 12),
                                Text("No moods logged yet",
                                    style: TextStyle(
                                        color: Colors.white
                                            .withOpacity(0.3),
                                        fontSize: 14)),
                                SizedBox(height: 6),
                                Text(
                                    "Tap + to log how you feel today",
                                    style: TextStyle(
                                        color: Colors.white
                                            .withOpacity(0.2),
                                        fontSize: 12)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24),
                            itemCount: moods.length,
                            itemBuilder: (_, i) {
                              var m = moods[i];
                              Color mColor =
                                  _getMoodColor(m["mood"]);
                              return Container(
                                margin:
                                    EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(0.04),
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                      color: mColor
                                          .withOpacity(0.2)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: mColor
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(
                                                12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _getMoodEmoji(m["mood"]),
                                          style: TextStyle(
                                              fontSize: 24),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            m["mood"]
                                                    .substring(0, 1)
                                                    .toUpperCase() +
                                                m["mood"]
                                                    .substring(1),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight:
                                                    FontWeight.w600),
                                          ),
                                          if (m["note"] != null &&
                                              m["note"]
                                                  .isNotEmpty) ...[
                                            SizedBox(height: 2),
                                            Text(m["note"],
                                                style: TextStyle(
                                                    color: Colors
                                                        .white
                                                        .withOpacity(
                                                            0.4),
                                                    fontSize: 12)),
                                          ],
                                          SizedBox(height: 4),
                                          Text(m["date"],
                                              style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(
                                                          0.3),
                                                  fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            mColor.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _getMoodEmoji(m["mood"]),
                                        style: TextStyle(
                                            fontSize: 20),
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
}