import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HeatmapScreen extends StatefulWidget {

  final int userId;

  const HeatmapScreen({
    super.key,
    required this.userId,
  });

  @override
  State<HeatmapScreen> createState() =>
      _HeatmapScreenState();
}

class _HeatmapScreenState
    extends State<HeatmapScreen> {

  bool loading = true;

  List days = [];

  String insight = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {

    try {

      final res =
          await ApiService
              .getHeatmap(
                  widget.userId);

      setState(() {

        days =
            res["days"] ?? [];

        insight =
            res["insight"] ??

            "Track habits and tasks to unlock AI heatmap analysis.";

        loading = false;
      });

    } catch (e) {

      setState(() {

        loading = false;

        days = [];

        insight =
            "Unable to load heatmap currently.";
      });
    }
  }

  Color getColor(String level) {

    switch (level) {

      case "excellent":
        return Colors.green;

      case "average":
        return Colors.orange;

      case "low":
        return Colors.redAccent;

      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFF0a0f1e),

      appBar: AppBar(

        title:
            const Text(
                "AI Heatmap"),

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

                          Icons.calendar_month,

                          color:
                              Colors.white,

                          size: 70,
                        ),

                        SizedBox(
                            height:
                                18),

                        Text(

                          "Productivity Calendar",

                          style:
                              TextStyle(

                            color:
                                Colors.white,

                            fontSize:
                                24,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        SizedBox(
                            height:
                                10),

                        Text(

                          "AI tracks your daily lifestyle patterns",

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
                      height: 28),

                  // 📅 GRID
                  GridView.builder(

                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    itemCount:
                        days.length,

                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(

                      crossAxisCount: 5,

                      crossAxisSpacing:
                          12,

                      mainAxisSpacing:
                          12,
                    ),

                    itemBuilder:
                        (context, index) {

                      final d =
                          days[index];

                      return Container(

                        decoration:
                            BoxDecoration(

                          color:
                              getColor(
                                  d["level"]),

                          borderRadius:
                              BorderRadius.circular(
                                  18),
                        ),

                        child: Column(

                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                          children: [

                            Text(

                              "${d["day"]}",

                              style:
                                  const TextStyle(

                                color:
                                    Colors.white,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                                height:
                                    8),

                            Text(

                              "${d["score"]}",

                              style:
                                  const TextStyle(

                                color:
                                    Colors.white70,

                                fontSize:
                                    12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                      height: 30),

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

                            SizedBox(
                                width:
                                    10),

                            Text(

                              "AI Insight",

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
                                18),

                        Text(

                          insight,

                          style:
                              const TextStyle(

                            color:
                                Colors.white70,

                            fontSize:
                                15,

                            height:
                                1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 20),
                ],
              ),
            ),
    );
  }
}