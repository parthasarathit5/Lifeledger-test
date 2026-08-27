import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NetWorthScreen
    extends StatefulWidget {

  final int userId;

  const NetWorthScreen({
    super.key,
    required this.userId,
  });

  @override
  State<NetWorthScreen>
      createState() =>
          _NetWorthScreenState();
}

class _NetWorthScreenState
    extends State<NetWorthScreen> {

  bool loading = true;

  Map data = {};

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {

    final res =
        await ApiService.getNetWorth(
            widget.userId);

    if (res["status"] == "success") {

      setState(() {

        data = res;

        loading = false;
      });
    }
  }

  Color getHealthColor() {

    switch (data["color"]) {

      case "green":
        return Colors.green;

      case "blue":
        return Colors.blue;

      case "orange":
        return Colors.orange;

      default:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFF0a0f1e),

      appBar: AppBar(

        title:
            const Text("Net Worth"),

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
                    CrossAxisAlignment.start,

                children: [

                  // 💎 MAIN CARD
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

                      boxShadow: [

                        BoxShadow(

                          color: Colors
                              .blue
                              .withOpacity(
                                  0.35),

                          blurRadius:
                              30,
                        ),
                      ],
                    ),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        const Text(

                          "Your Net Worth",

                          style: TextStyle(

                            color:
                                Colors.white70,

                            fontSize:
                                18,
                          ),
                        ),

                        const SizedBox(
                            height: 14),

                        Text(

                          "₹ ${data["networth"]}",

                          style:
                              const TextStyle(

                            color:
                                Colors.white,

                            fontSize:
                                38,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                            height: 18),

                        Row(

                          children: [

                            Icon(

                              Icons
                                  .trending_up,

                              color:
                                  Colors.white,
                            ),

                            const SizedBox(
                                width:
                                    8),

                            Text(

                              "${data["savings_rate"]}% savings rate",

                              style:
                                  const TextStyle(

                                color:
                                    Colors.white,

                                fontSize:
                                    16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 28),

                  // 📊 STATS
                  Row(

                    children: [

                      Expanded(

                        child: statCard(

                          "Income",

                          "₹ ${data["total_income"]}",

                          Colors.green,
                        ),
                      ),

                      const SizedBox(
                          width: 14),

                      Expanded(

                        child: statCard(

                          "Expense",

                          "₹ ${data["total_expense"]}",

                          Colors.redAccent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 24),

                  // 🧠 HEALTH
                  Container(

                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets
                            .all(22),

                    decoration:
                        BoxDecoration(

                      color: Colors.white
                          .withOpacity(
                              0.05),

                      borderRadius:
                          BorderRadius
                              .circular(
                                  24),
                    ),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        const Text(

                          "Financial Health",

                          style: TextStyle(

                            color:
                                Colors.white,

                            fontSize:
                                20,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                            height: 18),

                        Row(

                          children: [

                            Container(

                              padding:
                                  const EdgeInsets
                                      .symmetric(

                                horizontal:
                                    18,

                                vertical:
                                    10,
                              ),

                              decoration:
                                  BoxDecoration(

                                color:
                                    getHealthColor(),

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            20),
                              ),

                              child: Text(

                                data["health"],

                                style:
                                    const TextStyle(

                                  color:
                                      Colors.white,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(
                                width:
                                    16),

                            Expanded(

                              child: Text(

                                data["ai"],

                                style:
                                    const TextStyle(

                                  color:
                                      Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 28),

                  // 🤖 AI WEALTH COACH
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
                              0xFF121826),

                          Color(
                              0xFF1b2440),
                        ],
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                                  24),
                    ),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        const Text(

                          "AI Wealth Coach",

                          style: TextStyle(

                            color:
                                Colors.white,

                            fontSize:
                                20,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                            height: 16),

                        Text(

                          wealthAdvice(),

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

  Widget statCard(
    String title,
    String value,
    Color color,
  ) {

    return Container(

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color:
            Colors.white.withOpacity(
                0.05),

        borderRadius:
            BorderRadius.circular(
                20),
      ),

      child: Column(

        children: [

          Text(

            title,

            style: const TextStyle(
              color: Colors.white54,
            ),
          ),

          const SizedBox(height: 12),

          Text(

            value,

            style: TextStyle(

              color: color,

              fontSize: 20,

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String wealthAdvice() {

    int rate =
        data["savings_rate"];

    if (rate >= 50) {

      return
          "🔥 You're building wealth very efficiently. Continue investing and tracking your financial habits consistently.";
    }

    if (rate >= 25) {

      return
          "👍 You're financially stable. Increasing savings slightly can accelerate your long-term goals.";
    }

    if (rate >= 10) {

      return
          "📈 Your finances are improving, but reducing unnecessary expenses could significantly increase your savings.";
    }

    return
        "⚠ Your savings rate is low. Focus on reducing spending and increasing income sources.";
  }
}