import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BudgetScreen extends StatefulWidget {
  final int userId;

  const BudgetScreen({
    super.key,
    required this.userId,
  });

  @override
  State<BudgetScreen> createState() =>
      _BudgetScreenState();
}

class _BudgetScreenState
    extends State<BudgetScreen> {

  bool loading = true;

  List budgets = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  // 🔥 LOAD BUDGETS
  Future<void> load() async {

    final res =
        await ApiService.getBudget(
            widget.userId);

    if (res["status"] == "success") {

      setState(() {

        budgets = res["budgets"];

        loading = false;
      });
    }
  }

  // ➕ ADD BUDGET DIALOG
  void addBudgetDialog() {

    TextEditingController category =
        TextEditingController();

    TextEditingController amount =
        TextEditingController();

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          backgroundColor:
              const Color(0xFF121826),

          title: const Text(
            "Add Budget",
            style:
                TextStyle(color: Colors.white),
          ),

          content: Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              TextField(
                controller: category,

                style: const TextStyle(
                    color: Colors.white),

                decoration: InputDecoration(

                  labelText: "Category",

                  labelStyle:
                      const TextStyle(
                    color: Colors.white70,
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderSide:
                        BorderSide(
                      color: Colors.white24,
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderSide:
                        BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: amount,

                keyboardType:
                    TextInputType.number,

                style: const TextStyle(
                    color: Colors.white),

                decoration: InputDecoration(

                  labelText: "Amount",

                  labelStyle:
                      const TextStyle(
                    color: Colors.white70,
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderSide:
                        BorderSide(
                      color: Colors.white24,
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderSide:
                        BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),

          actions: [

            TextButton(

              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text("Cancel"),
            ),

            ElevatedButton(

              onPressed: () async {

                await ApiService.addBudget(

                  widget.userId,

                  {
                    "category":
                        category.text,

                    "amount":
                        amount.text,
                  },
                );

                Navigator.pop(context);

                load();
              },

              child: const Text("Save"),
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

        title: const Text("Budget Planner"),

        backgroundColor:
            Colors.transparent,
      ),

      // ➕ BUTTON
      floatingActionButton:
          FloatingActionButton(

        backgroundColor:
            const Color(0xFF6c8fff),

        child: const Icon(Icons.add),

        onPressed: () {

          addBudgetDialog();
        },
      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : budgets.isEmpty

              ? const Center(
                  child: Text(
                    "No budgets added yet",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                )

              : SingleChildScrollView(

                  padding:
                      const EdgeInsets.all(16),

                  child: Column(

                    children:
                        budgets.map((b) {

                      double percent =
                          (b["percentage"] ?? 0)
                                  .toDouble() /
                              100;

                      Color color =
                          Colors.green;

                      String status =
                          "Safe";

                      if (percent >= 0.9) {

                        color = Colors.red;

                        status = "Danger";
                      }

                      else if (percent >= 0.7) {

                        color =
                            Colors.orange;

                        status =
                            "Warning";
                      }

                      return Container(

                        margin:
                            const EdgeInsets
                                    .only(
                                bottom: 18),

                        padding:
                            const EdgeInsets
                                .all(18),

                        decoration:
                            BoxDecoration(

                          color: Colors
                              .white
                              .withOpacity(
                                  0.05),

                          borderRadius:
                              BorderRadius
                                  .circular(
                                      18),

                          border: Border.all(
                            color: color
                                .withOpacity(
                                    0.3),
                          ),
                        ),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            // 🔥 TOP ROW
                            Row(

                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,

                              children: [

                                Text(
                                  b["category"],

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

                                Container(

                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),

                                  decoration:
                                      BoxDecoration(

                                    color: color
                                        .withOpacity(
                                            0.2),

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                20),
                                  ),

                                  child: Text(

                                    status,

                                    style:
                                        TextStyle(
                                      color:
                                          color,

                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 16),

                            // 💰 VALUES
                            Text(

                              "₹${b["spent"]} / ₹${b["budget"]}",

                              style:
                                  const TextStyle(
                                color:
                                    Colors.white70,

                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(
                                height: 12),

                            // 📊 PROGRESS
                            LinearProgressIndicator(

                              value: percent,

                              minHeight: 12,

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          30),

                              backgroundColor:
                                  Colors.white12,

                              color: color,
                            ),

                            const SizedBox(
                                height: 14),

                            // 📈 PERCENT
                            Text(

                              "${b["percentage"]}% used",

                              style:
                                  TextStyle(
                                color: color,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                                height: 8),

                            // 💵 REMAINING
                            Text(

                              "₹${b["remaining"]} remaining",

                              style:
                                  const TextStyle(
                                color:
                                    Colors.white54,
                              ),
                            ),

                            const SizedBox(
                                height: 12),

                            // 🧠 AI TIP
                            aiTip(
                              percent,
                              b["category"],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
    );
  }

  // 🧠 AI TIP
  Widget aiTip(
    double percent,
    String category,
  ) {

    String msg =
        "Excellent budget control.";

    if (percent >= 0.9) {

      msg =
          "⚠ Reduce spending in $category immediately.";
    }

    else if (percent >= 0.7) {

      msg =
          "📊 You are nearing your $category budget.";
    }

    else if (percent < 0.5) {

      msg =
          "💰 Great savings discipline in $category.";
    }

    return Container(

      width: double.infinity,

      padding:
          const EdgeInsets.all(12),

      decoration: BoxDecoration(

        color:
            Colors.white.withOpacity(0.03),

        borderRadius:
            BorderRadius.circular(12),
      ),

      child: Text(

        msg,

        style: const TextStyle(
          color: Colors.white70,
        ),
      ),
    );
  }
}