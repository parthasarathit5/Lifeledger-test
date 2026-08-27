import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LifeScoreScreen
    extends StatefulWidget {

  final int userId;

  const LifeScoreScreen({
    super.key,
    required this.userId,
  });

  @override
  State<LifeScoreScreen>
      createState() =>
          _LifeScoreScreenState();
}

class _LifeScoreScreenState
    extends State<LifeScoreScreen> {

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
          await ApiService.getLifeScore(
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

  Widget scoreCard(
    String title,
    int value,
    Color color,
    IconData icon,
  ) {

    return Container(

      margin:
          const EdgeInsets.only(
              bottom: 16),

      padding:
          const EdgeInsets.all(18),

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
                24),
      ),

      child: Row(

        children: [

          Container(

            padding:
                const EdgeInsets
                    .all(14),

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

              size: 30,
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
                    height: 8),

                Text(

                  "$value / 25",

                  style:
                      const TextStyle(

                    color:
                        Colors.white,

                    fontSize: 20,

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
            const Text("Life Score"),

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

                  // 🏆 MAIN SCORE
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

                          "Your Life Score",

                          style: TextStyle(

                            color:
                                Colors.white70,

                            fontSize:
                                18,
                          ),
                        ),

                        const SizedBox(
                            height: 16),

                        Text(

                          "${data["total_score"] ?? 0}/100",

                          style:
                              const TextStyle(

                            color:
                                Colors.white,

                            fontSize:
                                42,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 28),

                  scoreCard(

                    "Finance",

                    data["finance"] ?? 0,

                    Colors.green,

                    Icons.attach_money,
                  ),

                  scoreCard(

                    "Habits",

                    data["habits"] ?? 0,

                    Colors.orange,

                    Icons.local_fire_department,
                  ),

                  scoreCard(

                    "Productivity",

                    data["productivity"] ?? 0,

                    Colors.blue,

                    Icons.check_circle,
                  ),

                  scoreCard(

                    "Mood",

                    data["mood"] ?? 0,

                    Colors.purple,

                    Icons.mood,
                  ),

                  const SizedBox(
                      height: 24),

                  // 🤖 AI ANALYSIS
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

                        const Text(

                          "AI Analysis",

                          style: TextStyle(

                            color:
                                Colors.white,

                            fontSize:
                                22,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                            height: 16),

                        Text(

                          data["message"] ??
                              "",

                          style:
                              const TextStyle(

                            color:
                                Colors.white70,

                            fontSize:
                                15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}