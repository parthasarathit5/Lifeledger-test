import 'package:flutter/material.dart';
import '../services/api_service.dart';

class GoalsScreen extends StatefulWidget {

  final int userId;

  const GoalsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<GoalsScreen> createState() =>
      _GoalsScreenState();
}

class _GoalsScreenState
    extends State<GoalsScreen> {

  bool loading = true;

  List goals = [];

  final titleController =
      TextEditingController();

  final targetController =
      TextEditingController();

  final currentController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadGoals();
  }

  Future<void> loadGoals() async {

    final res =
        await ApiService.getGoals(
            widget.userId);

    if (res["status"] == "success") {

      setState(() {

        goals = res["goals"];

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
            targetController.text,

        "current_amount":
            currentController.text
                    .isEmpty
                ? "0"
                : currentController.text,
      },
    );

    Navigator.pop(context);

    titleController.clear();
    targetController.clear();
    currentController.clear();

    loadGoals();
  }

  void openDialog() {

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          backgroundColor:
              const Color(0xFF121826),

          title: const Text(
            "New Goal",
            style: TextStyle(
              color: Colors.white,
            ),
          ),

          content: Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              field(
                titleController,
                "Goal title",
              ),

              const SizedBox(height: 12),

              field(
                targetController,
                "Target amount",
              ),

              const SizedBox(height: 12),

              field(
                currentController,
                "Current savings",
              ),
            ],
          ),

          actions: [

            TextButton(

              onPressed: () {
                Navigator.pop(
                    context);
              },

              child: const Text(
                "Cancel",
              ),
            ),

            ElevatedButton(

              onPressed: addGoal,

              child: const Text(
                "Save",
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFF0a0f1e),

      appBar: AppBar(

        title:
            const Text("Goals"),

        backgroundColor:
            Colors.transparent,
      ),

      floatingActionButton:
          FloatingActionButton(

        backgroundColor:
            const Color(0xFF6c8fff),

        onPressed: openDialog,

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
                          Colors.white54,
                    ),
                  ),
                )

              : ListView.builder(

                  padding:
                      const EdgeInsets.all(
                          16),

                  itemCount:
                      goals.length,

                  itemBuilder:
                      (_, index) {

                    final g =
                        goals[index];

                    double progress =
                        (g["percentage"] ??
                                0)
                            .toDouble();

                    return Container(

                      margin:
                          const EdgeInsets.only(
                              bottom: 18),

                      padding:
                          const EdgeInsets.all(
                              18),

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
                                    22),

                        boxShadow: [

                          BoxShadow(

                            color: Colors
                                .black
                                .withOpacity(
                                    0.25),

                            blurRadius:
                                12,
                          ),
                        ],
                      ),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          Row(

                            children: [

                              Container(

                                padding:
                                    const EdgeInsets
                                        .all(12),

                                decoration:
                                    BoxDecoration(

                                  color: Colors
                                      .blue
                                      .withOpacity(
                                          0.15),

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              14),
                                ),

                                child:
                                    const Icon(

                                  Icons.flag,

                                  color:
                                      Colors.blue,
                                ),
                              ),

                              const SizedBox(
                                  width: 14),

                              Expanded(

                                child: Column(

                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [

                                    Text(

                                      g["title"],

                                      style:
                                          const TextStyle(

                                        color:
                                            Colors.white,

                                        fontSize:
                                            18,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(
                                        height:
                                            4),

                                    Text(

                                      "Remaining ₹${g["remaining"]}",

                                      style:
                                          const TextStyle(

                                        color:
                                            Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                              height: 24),

                          ClipRRect(

                            borderRadius:
                                BorderRadius
                                    .circular(
                                        20),

                            child:
                                LinearProgressIndicator(

                              value:
                                  progress /
                                      100,

                              minHeight:
                                  14,

                              backgroundColor:
                                  Colors
                                      .white12,

                              color:
                                  progress >= 100
                                      ? Colors.green
                                      : Colors.blue,
                            ),
                          ),

                          const SizedBox(
                              height: 14),

                          Row(

                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [

                              Text(

                                "₹${g["current_amount"]}",

                                style:
                                    const TextStyle(

                                  color:
                                      Colors.green,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              Text(

                                "${g["percentage"]}%",

                                style:
                                    const TextStyle(

                                  color:
                                      Colors.white,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              Text(

                                "₹${g["target_amount"]}",

                                style:
                                    const TextStyle(

                                  color:
                                      Colors.redAccent,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                              height: 18),

                          // 🤖 AI MESSAGE
                          Container(

                            width:
                                double.infinity,

                            padding:
                                const EdgeInsets
                                    .all(14),

                            decoration:
                                BoxDecoration(

                              color: Colors
                                  .white
                                  .withOpacity(
                                      0.05),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          14),
                            ),

                            child: Text(

                              aiMessage(
                                  progress),

                              style:
                                  const TextStyle(

                                color:
                                    Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget field(
    TextEditingController c,
    String hint,
  ) {

    return TextField(

      controller: c,

      style: const TextStyle(
        color: Colors.white,
      ),

      decoration: InputDecoration(

        hintText: hint,

        hintStyle:
            const TextStyle(
          color: Colors.white38,
        ),

        filled: true,

        fillColor:
            Colors.white.withOpacity(
                0.05),

        border:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(
                  14),

          borderSide:
              BorderSide.none,
        ),
      ),
    );
  }

  String aiMessage(
    double progress,
  ) {

    if (progress >= 100) {

      return
          "🏆 Goal achieved! Amazing work!";
    }

    if (progress >= 75) {

      return
          "🔥 Almost there! Keep pushing.";
    }

    if (progress >= 40) {

      return
          "📈 Good progress so far.";
    }

    return
        "🚀 Start saving consistently to reach this goal faster.";
  }
}