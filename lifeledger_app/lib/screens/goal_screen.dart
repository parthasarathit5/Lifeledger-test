import 'package:flutter/material.dart';
import '../services/api_service.dart';

class GoalScreen extends StatefulWidget {

  final int userId;

  const GoalScreen({
    super.key,
    required this.userId,
  });

  @override
  State<GoalScreen> createState() =>
      _GoalScreenState();
}

class _GoalScreenState
    extends State<GoalScreen> {

  bool loading = true;

  List goals = [];

  final titleController =
      TextEditingController();

  final targetController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {

    try {

      final res =
          await ApiService.getGoals(
              widget.userId);

      setState(() {

        goals =
            res["goals"] ?? [];

        loading = false;
      });

    } catch (e) {

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> addGoal() async {

    if (titleController.text.isEmpty ||
        targetController.text.isEmpty) {
      return;
    }

    await ApiService.addGoal(

      widget.userId,

      {
        "title":
            titleController.text,

        "target_amount":
            int.parse(
                targetController.text),
      },
    );

    titleController.clear();

    targetController.clear();

    load();
  }

  Color getColor(int progress) {

    if (progress >= 80) {
      return Colors.green;
    }

    if (progress >= 40) {
      return Colors.orange;
    }

    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFF0a0f1e),

      appBar: AppBar(

        title:
            const Text("AI Goals"),

        backgroundColor:
            Colors.transparent,
      ),

      floatingActionButton:
          FloatingActionButton(

        backgroundColor:
            const Color(0xFF6c8fff),

        onPressed: () {

          showModalBottomSheet(

            context: context,

            backgroundColor:
                const Color(
                    0xFF121826),

            builder: (_) {

              return Padding(

                padding:
                    const EdgeInsets
                        .all(20),

                child: Column(

                  mainAxisSize:
                      MainAxisSize.min,

                  children: [

                    TextField(

                      controller:
                          titleController,

                      style:
                          const TextStyle(
                              color:
                                  Colors.white),

                      decoration:
                          const InputDecoration(

                        hintText:
                            "Goal Title",

                        hintStyle:
                            TextStyle(
                                color:
                                    Colors.white54),
                      ),
                    ),

                    const SizedBox(
                        height: 16),

                    TextField(

                      controller:
                          targetController,

                      keyboardType:
                          TextInputType
                              .number,

                      style:
                          const TextStyle(
                              color:
                                  Colors.white),

                      decoration:
                          const InputDecoration(

                        hintText:
                            "Target Amount",

                        hintStyle:
                            TextStyle(
                                color:
                                    Colors.white54),
                      ),
                    ),

                    const SizedBox(
                        height: 24),

                    ElevatedButton(

                      onPressed:
                          addGoal,

                      child:
                          const Text(
                              "Create Goal"),
                    ),
                  ],
                ),
              );
            },
          );
        },

        child:
            const Icon(Icons.add),
      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : goals.isEmpty

              ? const Center(

                  child: Text(

                    "No goals yet",

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

                      // 🎯 HEADER
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

                              Icons.flag,

                              color:
                                  Colors.white,

                              size: 70,
                            ),

                            SizedBox(
                                height:
                                    16),

                            Text(

                              "Goal Prediction Engine",

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
                          ],
                        ),
                      ),

                      const SizedBox(
                          height: 30),

                      // 🎯 GOALS
                      ...goals.map((g) {

                        int progress =
                            g["progress"] ?? 0;

                        Color color =
                            getColor(
                                progress);

                        return Container(

                          margin:
                              const EdgeInsets
                                  .only(
                                      bottom:
                                          22),

                          padding:
                              const EdgeInsets
                                  .all(
                                      24),

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

                                color:
                                    color
                                        .withOpacity(
                                            0.18),

                                blurRadius:
                                    18,
                              ),
                            ],
                          ),

                          child: Column(

                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Row(

                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,

                                children: [

                                  Expanded(

                                    child: Text(

                                      g["title"] ??
                                          "",

                                      style:
                                          const TextStyle(

                                        color:
                                            Colors.white,

                                        fontSize:
                                            22,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  Text(

                                    "$progress%",

                                    style:
                                        TextStyle(

                                      color:
                                          color,

                                      fontWeight:
                                          FontWeight.bold,

                                      fontSize:
                                          18,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                  height:
                                      18),

                              ClipRRect(

                                borderRadius:
                                    BorderRadius.circular(
                                        12),

                                child:
                                    LinearProgressIndicator(

                                  value:
                                      progress /
                                          100,

                                  minHeight:
                                      12,

                                  backgroundColor:
                                      Colors.white12,

                                  valueColor:
                                      AlwaysStoppedAnimation(
                                          color),
                                ),
                              ),

                              const SizedBox(
                                  height:
                                      18),

                              Text(

                                "₹${g["current"]} / ₹${g["target"]}",

                                style:
                                    const TextStyle(

                                  color:
                                      Colors.white70,
                                ),
                              ),

                              const SizedBox(
                                  height:
                                      12),

                              Text(

                                "🔮 ${g["prediction"]}",

                                style:
                                    const TextStyle(

                                  color:
                                      Colors.orange,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                  height:
                                      12),

                              Text(

                                "🤖 ${g["status"]}",

                                style:
                                    const TextStyle(

                                  color:
                                      Colors.white70,

                                  height:
                                      1.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
    );
  }
}