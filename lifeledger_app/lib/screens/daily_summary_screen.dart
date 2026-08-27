import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DailySummaryScreen
    extends StatefulWidget {

  final int userId;

  const DailySummaryScreen({
    super.key,
    required this.userId,
  });

  @override
  State<DailySummaryScreen>
      createState() =>
          _DailySummaryScreenState();
}

class _DailySummaryScreenState
    extends State<DailySummaryScreen> {

  bool loading = true;

  String summary = "";

  Map data = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {

    try {

      final res =
          await ApiService
              .getDailySummary(
                  widget.userId);

      setState(() {

        summary =
            res["summary"] ??

            "Start tracking activities to unlock AI insights.";

        data = res;

        loading = false;
      });

    } catch (e) {

      setState(() {

        loading = false;

        summary =
            "Unable to load AI summary currently.";
      });
    }
  }

  Widget statCard(

    String title,

    dynamic value,

    IconData icon,

    Color color,
  ) {

    return Container(

      padding:
          const EdgeInsets.all(
              18),

      decoration:
          BoxDecoration(

        gradient:
            const LinearGradient(

          colors: [

            Color(0xFF121826),

            Color(0xFF1b2440),
          ],
        ),

        borderRadius:
            BorderRadius.circular(
                22),

        boxShadow: [

          BoxShadow(

            color:
                color.withOpacity(
                    0.15),

            blurRadius: 18,
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [

          Icon(

            icon,

            color: color,

            size: 30,
          ),

          const SizedBox(
              height: 16),

          Text(

            title,

            style:
                const TextStyle(

              color:
                  Colors.white70,
            ),
          ),

          const SizedBox(
              height: 8),

          Text(

            "$value",

            style:
                const TextStyle(

              color:
                  Colors.white,

              fontSize: 22,

              fontWeight:
                  FontWeight.bold,
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
                "AI Daily Summary"),

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

                  // 🔥 HEADER
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
                                  30),
                    ),

                    child: const Column(

                      children: [

                        Icon(

                          Icons.auto_awesome,

                          color:
                              Colors.white,

                          size: 70,
                        ),

                        SizedBox(
                            height:
                                18),

                        Text(

                          "AI Life Report",

                          style:
                              TextStyle(

                            color:
                                Colors.white,

                            fontSize:
                                26,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        SizedBox(
                            height:
                                10),

                        Text(

                          "Your lifestyle patterns analyzed daily",

                          textAlign:
                              TextAlign.center,

                          style:
                              TextStyle(

                            color:
                                Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 30),

                  // 📊 STATS
                  GridView.count(

                    crossAxisCount: 2,

                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    crossAxisSpacing:
                        16,

                    mainAxisSpacing:
                        16,

                    childAspectRatio:
                        1.1,

                    children: [

                      statCard(

                        "Income",

                        "₹${data["income"] ?? 0}",

                        Icons.currency_rupee,

                        Colors.green,
                      ),

                      statCard(

                        "Expense",

                        "₹${data["expense"] ?? 0}",

                        Icons.money_off,

                        Colors.redAccent,
                      ),

                      statCard(

                        "Savings",

                        "₹${data["savings"] ?? 0}",

                        Icons.savings,

                        Colors.orange,
                      ),

                      statCard(

                        "AI Status",

                        "Active",

                        Icons.psychology,

                        Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 30),

                  // 🤖 SUMMARY
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

                            SizedBox(
                                width:
                                    10),

                            Text(

                              "AI Insight Engine",

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
                            height:
                                22),

                        Text(

                          summary,

                          style:
                              const TextStyle(

                            color:
                                Colors.white70,

                            fontSize:
                                15,

                            height:
                                1.8,
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