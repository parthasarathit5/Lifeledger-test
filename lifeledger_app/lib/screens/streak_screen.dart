import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StreakScreen extends StatefulWidget {

  final int userId;

  const StreakScreen({
    super.key,
    required this.userId,
  });

  @override
  State<StreakScreen> createState() =>
      _StreakScreenState();
}

class _StreakScreenState
    extends State<StreakScreen> {

  bool loading = true;

  Map data = {};

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {

    try {

      final res =
          await ApiService.getStreaks(
              widget.userId);

      setState(() {

        data = res ?? {};

        loading = false;
      });

    } catch (e) {

      setState(() {

        loading = false;

        data = {};
      });
    }
  }

  Widget streakCard(
    String title,
    int value,
    IconData icon,
    Color color,
  ) {

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
                  ),
                ),

                const SizedBox(
                    height: 10),

                Text(

                  "$value Days",

                  style:
                      const TextStyle(

                    color:
                        Colors.white,

                    fontSize: 24,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
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
            const Text("AI Streaks"),

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

                  // 🔥 MAIN CARD
                  Container(

                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets
                            .all(28),

                    decoration:
                        BoxDecoration(

                      gradient:
                          const LinearGradient(

                        colors: [

                          Color(
                              0xFFFF7B54),

                          Color(
                              0xFFFFB26B),
                        ],
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                                  30),
                    ),

                    child: Column(

                      children: [

                        const Icon(

                          Icons.local_fire_department,

                          color:
                              Colors.white,

                          size: 60,
                        ),

                        const SizedBox(
                            height: 18),

                        const Text(

                          "Consistency Engine",

                          style: TextStyle(

                            color:
                                Colors.white70,

                            fontSize:
                                18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 28),

                  streakCard(

                    "Habit Streak",

                    data["habit_streak"] ??
                        0,

                    Icons.local_fire_department,

                    Colors.orange,
                  ),

                  streakCard(

                    "Productivity Streak",

                    data["task_streak"] ??
                        0,

                    Icons.check_circle,

                    Colors.blue,
                  ),

                  streakCard(

                    "Mood Streak",

                    data["mood_streak"] ??
                        0,

                    Icons.mood,

                    Colors.purple,
                  ),

                  streakCard(

                    "Saving Streak",

                    data["saving_streak"] ??
                        0,

                    Icons.savings,

                    Colors.green,
                  ),

                  const SizedBox(
                      height: 10),

                  // 🤖 AI INSIGHT
                  Container(

                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets
                            .all(24),

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
                                  28),
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

                              "AI Streak Insight",

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
                              "",

                          style:
                              const TextStyle(

                            color:
                                Colors.white70,

                            fontSize:
                                15,

                            height: 1.5,
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