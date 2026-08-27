import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BehaviorScreen extends StatefulWidget {

  final int userId;

  const BehaviorScreen({
    super.key,
    required this.userId,
  });

  @override
  State<BehaviorScreen> createState() =>
      _BehaviorScreenState();
}

class _BehaviorScreenState
    extends State<BehaviorScreen> {

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
          await ApiService.getBehavior(
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

  Widget aiCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {

    return Container(

      margin:
          const EdgeInsets.only(
              bottom: 18),

      padding:
          const EdgeInsets.all(20),

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
                    height: 8),

                Text(

                  value,

                  style:
                      const TextStyle(

                    color:
                        Colors.white,

                    fontSize: 17,

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
            const Text("AI Behavior"),

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

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  // 🧠 HEADER CARD
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
                              0xFF6c8fff),

                          Color(
                              0xFFa78bfa),
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

                          "Financial Personality",

                          style: TextStyle(

                            color:
                                Colors.white70,

                            fontSize:
                                16,
                          ),
                        ),

                        const SizedBox(
                            height: 12),

                        Text(

                          data["personality"] ??
                              "No personality data",

                          style:
                              const TextStyle(

                            color:
                                Colors.white,

                            fontSize:
                                28,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 26),

                  // 💰 FINANCE
                  aiCard(

                    "Financial Analysis",

                    data["finance"] ??
                        "No finance analysis",

                    Icons.account_balance_wallet,

                    Colors.green,
                  ),

                  // 🔥 PRODUCTIVITY
                  aiCard(

                    "Productivity Analysis",

                    data["productivity"] ??
                        "No productivity data",

                    Icons.bolt,

                    Colors.orange,
                  ),

                  // 🔁 HABITS
                  aiCard(

                    "Habit Consistency",

                    data["habits"] ??
                        "No habits data",

                    Icons.local_fire_department,

                    Colors.redAccent,
                  ),

                  // 😊 MOOD
                  aiCard(

                    "Mood Insight",

                    data["mood"] ??
                        "No mood data",

                    Icons.mood,

                    Colors.purple,
                  ),

                  const SizedBox(
                      height: 10),

                  // 🤖 AI COACH
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
                              Icons.smart_toy,
                              color:
                                  Colors.white,
                            ),

                            SizedBox(width: 10),

                            Text(

                              "AI Lifestyle Coach",

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

                          data["advice"] ??
                              "No AI advice available",

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