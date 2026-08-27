import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AchievementsScreen
    extends StatefulWidget {

  final int userId;

  const AchievementsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AchievementsScreen>
      createState() =>
          _AchievementsScreenState();
}

class _AchievementsScreenState
    extends State<AchievementsScreen> {

  bool loading = true;

  List achievements = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {

    try {

      final res =
          await ApiService
              .getAchievements(
                  widget.userId);

      setState(() {

        achievements =
            res["achievements"] ??
                [];

        loading = false;
      });

    } catch (e) {

      setState(() {
        loading = false;
      });
    }
  }

  Color getColor(int index) {

    List<Color> colors = [

      Colors.orange,

      Colors.green,

      Colors.blue,

      Colors.purple,

      Colors.redAccent,
    ];

    return colors[
        index % colors.length];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFF0a0f1e),

      appBar: AppBar(

        title:
            const Text(
                "AI Awards"),

        backgroundColor:
            Colors.transparent,
      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : achievements.isEmpty

              ? const Center(

                  child: Text(

                    "No awards yet",

                    style: TextStyle(

                      color:
                          Colors.white70,
                    ),
                  ),
                )

              : SingleChildScrollView(

                  padding:
                      const EdgeInsets
                          .all(18),

                  child: Column(

                    children: [

                      // 🏆 HEADER
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
                                  0xFFFFB347),

                              Color(
                                  0xFFFFCC33),
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

                              Icons.emoji_events,

                              color:
                                  Colors.white,

                              size: 70,
                            ),

                            SizedBox(
                                height:
                                    16),

                            Text(

                              "Achievement Engine",

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

                              "Unlock rewards through consistency and growth",

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

                      // 🏅 AWARDS
                      ...List.generate(

                        achievements.length,

                        (index) {

                          final a =
                              achievements[
                                  index];

                          final color =
                              getColor(
                                  index);

                          return Container(

                            margin:
                                const EdgeInsets
                                    .only(
                                        bottom:
                                            20),

                            padding:
                                const EdgeInsets
                                    .all(
                                        22),

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

                              boxShadow: [

                                BoxShadow(

                                  color: color
                                      .withOpacity(
                                          0.18),

                                  blurRadius:
                                      18,
                                ),
                              ],
                            ),

                            child: Row(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Container(

                                  width: 70,

                                  height:
                                      70,

                                  decoration:
                                      BoxDecoration(

                                    color: color
                                        .withOpacity(
                                            0.15),

                                    borderRadius:
                                        BorderRadius.circular(
                                            20),
                                  ),

                                  child: Center(

                                    child:
                                        Text(

                                      a["icon"] ??
                                          "🏆",

                                      style:
                                          const TextStyle(

                                        fontSize:
                                            34,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                    width:
                                        18),

                                Expanded(

                                  child:
                                      Column(

                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      Text(

                                        a["title"] ??
                                            "",

                                        style:
                                            const TextStyle(

                                          color:
                                              Colors.white,

                                          fontSize:
                                              20,

                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(
                                          height:
                                              10),

                                      Text(

                                        a["description"] ??
                                            "",

                                        style:
                                            const TextStyle(

                                          color:
                                              Colors.white70,

                                          fontSize:
                                              15,

                                          height:
                                              1.5,
                                        ),
                                      ),

                                      const SizedBox(
                                          height:
                                              14),

                                      Container(

                                        padding:
                                            const EdgeInsets.symmetric(

                                          horizontal:
                                              14,

                                          vertical:
                                              8,
                                        ),

                                        decoration:
                                            BoxDecoration(

                                          color:
                                              color.withOpacity(
                                                  0.15),

                                          borderRadius:
                                              BorderRadius.circular(
                                                  14),
                                        ),

                                        child:
                                            Text(

                                          "Achievement Unlocked",

                                          style:
                                              TextStyle(

                                            color:
                                                color,

                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(
                          height: 20),
                    ],
                  ),
                ),
    );
  }
}