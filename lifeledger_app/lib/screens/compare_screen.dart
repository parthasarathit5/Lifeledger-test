import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CompareScreen extends StatefulWidget {

  final int userId;

  const CompareScreen({
    super.key,
    required this.userId,
  });

  @override
  State<CompareScreen> createState() =>
      _CompareScreenState();
}

class _CompareScreenState
    extends State<CompareScreen> {

  bool loading = true;

  Map data = {};

  int overallGrowth = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {

    try {

      final res =
          await ApiService.compareData(
              widget.userId);

      setState(() {

        data = res ?? {};

        calculateGrowth();

        loading = false;
      });

    } catch (e) {

      setState(() {

        loading = false;

        data = {};
      });
    }
  }

  void calculateGrowth() {

    int score = 0;

    if ((data["savings"] ?? "")
        .toString()
        .contains("improved")) {

      score += 25;
    }

    if ((data["habits"] ?? "")
        .toString()
        .contains("improved")) {

      score += 25;
    }

    if ((data["tasks"] ?? "")
        .toString()
        .contains("Excellent")) {

      score += 25;
    }

    if ((data["mood"] ?? "")
        .toString()
        .contains("Strong")) {

      score += 25;
    }

    overallGrowth = score;
  }

  Widget sectionCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {

    return Container(

      margin:
          const EdgeInsets.only(
              bottom: 18),

      padding:
          const EdgeInsets.all(22),

      decoration: BoxDecoration(

        gradient:
            const LinearGradient(

          colors: [

            Color(0xFF121826),
            Color(0xFF1b2440),
          ],
        ),

        borderRadius:
            BorderRadius.circular(
                26),

        boxShadow: [

          BoxShadow(

            color:
                color.withOpacity(
                    0.18),

            blurRadius: 18,
          ),
        ],
      ),

      child: Row(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Container(

            padding:
                const EdgeInsets
                    .all(16),

            decoration:
                BoxDecoration(

              color:
                  color.withOpacity(
                      0.15),

              borderRadius:
                  BorderRadius
                      .circular(
                          18),
            ),

            child: Icon(

              icon,

              color: color,

              size: 34,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(

                  title,

                  style:
                      const TextStyle(

                    color:
                        Colors.white54,

                    fontSize: 13,
                  ),
                ),

                const SizedBox(
                    height: 10),

                Text(

                  value,

                  style:
                      const TextStyle(

                    color:
                        Colors.white,

                    fontSize: 17,

                    fontWeight:
                        FontWeight.bold,

                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget progressTile(
    String title,
    int value,
    Color color,
  ) {

    return Container(

      margin:
          const EdgeInsets.only(
              bottom: 18),

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color:
            Colors.white.withOpacity(
                0.05),

        borderRadius:
            BorderRadius.circular(
                24),
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(

            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [

              Text(

                title,

                style:
                    const TextStyle(

                  color:
                      Colors.white,

                  fontSize: 16,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              Text(

                "$value%",

                style: TextStyle(

                  color: color,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(

            borderRadius:
                BorderRadius.circular(
                    10),

            child:
                LinearProgressIndicator(

              value: value / 100,

              minHeight: 10,

              backgroundColor:
                  Colors.white12,

              valueColor:
                  AlwaysStoppedAnimation(
                      color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFF0a0f1e),

      appBar: AppBar(

        title:
            const Text(
                "AI Life Evolution"),

        backgroundColor:
            Colors.transparent,
      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : SingleChildScrollView(

              padding:
                  const EdgeInsets.all(
                      18),

              child: Column(

                children: [

                  // 🏆 OVERALL GROWTH
                  Container(

                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets
                            .all(30),

                    decoration:
                        BoxDecoration(

                      gradient:
                          const LinearGradient(

                        colors: [

                          Color(
                              0xFF6c8fff),

                          Color(
                              0xFFa78bfa),
                        ],
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                                  30),
                    ),

                    child: Column(

                      children: [

                        const Text(

                          "Overall Growth",

                          style: TextStyle(

                            color:
                                Colors.white70,

                            fontSize:
                                18,
                          ),
                        ),

                        const SizedBox(
                            height: 18),

                        Text(

                          "$overallGrowth%",

                          style:
                              const TextStyle(

                            color:
                                Colors.white,

                            fontSize:
                                44,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                            height: 12),

                        const Text(

                          "AI-based lifestyle evolution analysis",

                          textAlign:
                              TextAlign.center,

                          style: TextStyle(

                            color:
                                Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 30),

                  // 📈 PROGRESS
                  progressTile(
                    "Financial Growth",
                    overallGrowth,
                    Colors.green,
                  ),

                  progressTile(
                    "Habit Consistency",
                    overallGrowth > 20
                        ? overallGrowth - 5
                        : overallGrowth,
                    Colors.orange,
                  ),

                  progressTile(
                    "Productivity Level",
                    overallGrowth > 10
                        ? overallGrowth - 10
                        : overallGrowth,
                    Colors.blue,
                  ),

                  progressTile(
                    "Emotional Stability",
                    overallGrowth > 15
                        ? overallGrowth - 8
                        : overallGrowth,
                    Colors.purple,
                  ),

                  const SizedBox(
                      height: 10),

                  // 💰 FINANCE
                  sectionCard(

                    title:
                        "Financial Evolution",

                    value:
                        data["savings"] ??
                            "No financial data",

                    icon:
                        Icons.savings,

                    color:
                        Colors.green,
                  ),

                  // 🔥 HABITS
                  sectionCard(

                    title:
                        "Habit Progression",

                    value:
                        data["habits"] ??
                            "No habit data",

                    icon:
                        Icons.local_fire_department,

                    color:
                        Colors.orange,
                  ),

                  // ✅ PRODUCTIVITY
                  sectionCard(

                    title:
                        "Productivity Evolution",

                    value:
                        data["tasks"] ??
                            "No productivity data",

                    icon:
                        Icons.check_circle,

                    color:
                        Colors.blue,
                  ),

                  // 😊 MOOD
                  sectionCard(

                    title:
                        "Mood Progression",

                    value:
                        data["mood"] ??
                            "No mood data",

                    icon:
                        Icons.mood,

                    color:
                        Colors.purple,
                  ),

                  const SizedBox(
                      height: 14),

                  // 🤖 AI ENGINE
                  Container(

                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets
                            .all(26),

                    decoration:
                        BoxDecoration(

                      gradient:
                          const LinearGradient(

                        colors: [

                          Color(
                              0xFF121826),

                          Color(
                              0xFF1b2440),
                        ],
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                                  30),
                    ),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        const Row(

                          children: [

                            Icon(
                              Icons.auto_awesome,
                              color:
                                  Colors.white,
                            ),

                            SizedBox(width: 10),

                            Text(

                              "AI Evolution Insight",

                              style:
                                  TextStyle(

                                color:
                                    Colors.white,

                                fontSize:
                                    22,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                            height: 18),

                        Text(

                          data["insight"] ??
                              "No AI insight available",

                          style:
                              const TextStyle(

                            color:
                                Colors.white70,

                            fontSize:
                                15,

                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 30),
                ],
              ),
            ),
    );
  }
}