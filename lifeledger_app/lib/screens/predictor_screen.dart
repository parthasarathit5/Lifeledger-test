import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PredictorScreen
    extends StatefulWidget {

  final int userId;

  const PredictorScreen({
    super.key,
    required this.userId,
  });

  @override
  State<PredictorScreen>
      createState() =>
          _PredictorScreenState();
}

class _PredictorScreenState
    extends State<PredictorScreen> {

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
          await ApiService.getPrediction(
              widget.userId);

      setState(() {

        data = res;

        loading = false;
      });

    } catch (e) {

      setState(() {
        loading = false;
      });
    }
  }

  Widget card(
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
                    height: 8),

                Text(

                  value,

                  style:
                      const TextStyle(

                    color:
                        Colors.white,

                    fontSize: 18,

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
            const Text("AI Predictor"),

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

                  // 🔮 FUTURE SAVINGS
                  card(

                    "Future Savings",

                    "₹ ${data["predicted_savings"]}",

                    Icons.auto_graph,

                    Colors.green,
                  ),

                  // ⚠ RISK
                  card(

                    "Risk Analysis",

                    data["risk"],

                    Icons.warning,

                    Colors.orange,
                  ),

                  // 🔥 PRODUCTIVITY
                  card(

                    "Productivity Forecast",

                    data["productivity"],

                    Icons.bolt,

                    Colors.blue,
                  ),

                  // 🎯 GOAL
                  card(

                    "Goal Prediction",

                    data["goal_prediction"],

                    Icons.flag,

                    Colors.purple,
                  ),

                  // 🤖 AI COACH
                  Container(

                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets
                            .all(22),

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

                          "AI Recommendation",

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

                          data["advice"],

                          style:
                              const TextStyle(

                            color:
                                Colors.white,

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