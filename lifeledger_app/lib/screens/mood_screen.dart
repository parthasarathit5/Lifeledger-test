import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MoodScreen extends StatefulWidget {
  final int userId;
  const MoodScreen({required this.userId, super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  static const String baseUrl = "https://lifeledger-backend.onrender.com";

  bool isFetching = true;
  bool isSaving = false;
  List<dynamic> moods = [];
  String? todayMood;
  final noteController = TextEditingController();

  final List<Map<String, dynamic>> moodOptions = const [
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

  Uri _moodUrl() => Uri.parse("$baseUrl/mood/${widget.userId}/");

  Future<void> fetchMoods() async {
    setState(() => isFetching = true);
    try {
      final response = await http.get(_moodUrl()).timeout(const Duration(seconds: 25));
      final data = jsonDecode(response.body);
      if (!mounted) return;

      if (data["status"] == "success") {
        final list = data["moods"] as List<dynamic>? ?? [];
        String? latestToday;
        if (list.isNotEmpty) {
          final today = DateTime.now().toIso8601String().split('T')[0];
          if (list[0]["date"] == today) latestToday = list[0]["mood"];
        }
        setState(() {
          moods = list;
          todayMood = latestToday;
          isFetching = false;
        });
      } else {
        setState(() => isFetching = false);
        _showSnack(data["message"]?.toString() ?? "Failed to load moods");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isFetching = false);
      _showSnack("Network error: $e");
    }
  }

  Future<void> logMood(String mood) async {
    setState(() => isSaving = true);
    try {
      final response = await http
          .post(
            _moodUrl(),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"mood": mood, "note": noteController.text.trim()}),
          )
          .timeout(const Duration(seconds: 25));

      final data = jsonDecode(response.body);
      if (!mounted) return;

      if (data["status"] == "success") {
        noteController.clear();
        Navigator.pop(context);
        _showSnack("Mood logged successfully ✅");
        await fetchMoods();
      } else {
        _showSnack(data["message"]?.toString() ?? "Failed to save mood");
      }
    } catch (e) {
      _showSnack("Network error: $e");
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF1e2a4a),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _emojiFor(String mood) => moodOptions.firstWhere(
      (m) => m['value'] == mood, orElse: () => {'emoji': '😐'})['emoji'];

  Color _colorFor(String mood) => Color(moodOptions.firstWhere(
      (m) => m['value'] == mood, orElse: () => {'color': 0xFF6c8fff})['color']);

  void _showLogMoodSheet() {
    String? selected = todayMood;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF101828),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
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
                const SizedBox(height: 20),
                const Text("How are you feeling?",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text("Log your mood for today",
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: moodOptions.map((m) {
                    bool isSelected = selected == m['value'];
                    Color mColor = Color(m['color'] as int);
                    return GestureDetector(
                      onTap: () => setSheetState(() => selected = m['value'] as String),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: isSelected ? mColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? mColor : Colors.white.withOpacity(0.1),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(child: Text(m['emoji'] as String, style: const TextStyle(fontSize: 26))),
                          ),
                          const SizedBox(height: 6),
                          Text(m['label'] as String,
                              style: TextStyle(
                                color: isSelected ? mColor : Colors.white.withOpacity(0.4),
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: noteController,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Add a note (optional)",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                    prefixIcon: Icon(Icons.note_outlined, color: Colors.white.withOpacity(0.4), size: 20),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFfbbf24), width: 1.5)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFfbbf24), Color(0xFFf59e0b)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: (isSaving || selected == null) ? null : () => logMood(selected!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Log Mood →",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0a0f1e), Color(0xFF101828), Color(0xFF0d1533)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: fetchMoods,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                      const Text("Mood Tracker",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      GestureDetector(
                        onTap: _showLogMoodSheet,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFfbbf24), Color(0xFFf59e0b)]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: todayMood != null
                            ? [_colorFor(todayMood!), _colorFor(todayMood!).withOpacity(0.6)]
                            : const [Color(0xFFfbbf24), Color(0xFFf59e0b)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (todayMood != null ? _colorFor(todayMood!) : const Color(0xFFfbbf24))
                              .withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Today's Mood",
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                            const SizedBox(height: 6),
                            Text(
                              todayMood != null
                                  ? todayMood!.substring(0, 1).toUpperCase() + todayMood!.substring(1)
                                  : "Not logged yet",
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              todayMood != null ? "Saved to history ✓" : "Tap + to log your mood",
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                            ),
                          ],
                        ),
                        Text(todayMood != null ? _emojiFor(todayMood!) : "😐", style: const TextStyle(fontSize: 48)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Mood History",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      Text("Last 30 days", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: isFetching
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF6c8fff)))
                      : moods.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 80),
                                const Center(child: Text("😐", style: TextStyle(fontSize: 48))),
                                const SizedBox(height: 12),
                                Center(
                                  child: Text("No moods logged yet",
                                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14)),
                                ),
                                const SizedBox(height: 6),
                                Center(
                                  child: Text("Tap + to log how you feel today",
                                      style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12)),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: moods.length,
                              itemBuilder: (_, i) {
                                var m = moods[i];
                                Color mColor = _colorFor(m["mood"]);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: mColor.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: mColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                            child: Text(_emojiFor(m["mood"]), style: const TextStyle(fontSize: 24))),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              m["mood"].toString().substring(0, 1).toUpperCase() +
                                                  m["mood"].toString().substring(1),
                                              style: const TextStyle(
                                                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                            ),
                                            if (m["note"] != null && m["note"].toString().isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(m["note"],
                                                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                                            ],
                                            const SizedBox(height: 4),
                                            Text(m["date"],
                                                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: mColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(_emojiFor(m["mood"]), style: const TextStyle(fontSize: 20)),
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
      ),
    );
  }
}