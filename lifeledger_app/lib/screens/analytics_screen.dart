import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class AnalyticsScreen extends StatefulWidget {
  final int userId;

  const AnalyticsScreen({super.key, required this.userId});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool loading = true;
  Map data = {};

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final res = await ApiService.getAnalytics(widget.userId);

    if (res["status"] == "success") {
      setState(() {
        data = res;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double income =
        (data["total_income_month"] ?? 0).toDouble();

    double expense =
        (data["total_expense_month"] ?? 0).toDouble();

    double savings = income - expense;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0f1e),

      appBar: AppBar(
        title: const Text("Analytics"),
        backgroundColor: Colors.transparent,
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // 🔥 SUMMARY CARDS
                  Row(
                    children: [
                      Expanded(
                        child: summaryCard(
                          "Income",
                          "₹ $income",
                          Colors.green,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: summaryCard(
                          "Expense",
                          "₹ $expense",
                          Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  summaryCard(
                    "Savings",
                    "₹ $savings",
                    savings >= 0
                        ? Colors.blue
                        : Colors.orange,
                  ),

                  const SizedBox(height: 25),

                  // 🥧 PIE CHART
                  const Text(
                    "Expense Categories",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  pieChart(),

                  const SizedBox(height: 30),

                  // 📊 CATEGORY BARS
                  const Text(
                    "Category Breakdown",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  categoryBars(),

                  const SizedBox(height: 30),

                  // 🧠 AI INSIGHTS
                  aiInsights(
                    income,
                    expense,
                    savings,
                  ),
                ],
              ),
            ),
    );
  }

  // 🔥 SUMMARY CARD
  Widget summaryCard(
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 🥧 PIE CHART
  Widget pieChart() {
    Map categories =
        data["category_breakdown"] ?? {};

    List<Color> colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    int i = 0;

    List<PieChartSectionData> sections = [];

    categories.forEach((key, value) {

      sections.add(
        PieChartSectionData(
          color: colors[
              i % colors.length],

          value:
              value.toDouble(),

          title:
              "$key\n₹$value",

          radius: 80,

          titleStyle:
              const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      );

      i++;
    });

    return SizedBox(
      height: 260,

      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  // 📊 CATEGORY BARS
  Widget categoryBars() {

    Map categories =
        data["category_breakdown"] ?? {};

    double total =
        (data["total_expense_month"] ?? 0)
            .toDouble();

    return Column(
      children: categories.entries.map((e) {

        double percent = total > 0
            ? (e.value / total)
            : 0;

        return Container(
          margin:
              const EdgeInsets.only(
                  bottom: 16),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [
                  Text(
                    e.key,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                    ),
                  ),

                  Text(
                    "${(percent * 100).toInt()}%",
                    style:
                        const TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(
                value: percent,
                minHeight: 10,

                borderRadius:
                    BorderRadius.circular(
                        20),

                backgroundColor:
                    Colors.white12,

                color: Colors.blue,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 🧠 AI INSIGHTS
  Widget aiInsights(
    double income,
    double expense,
    double savings,
  ) {

    String msg =
        "Great financial balance!";

    if (expense > income) {
      msg =
          "⚠ You are overspending this month.";
    }

    else if (expense >
        income * 0.7) {
      msg =
          "📊 Expenses are getting high.";
    }

    else if (savings > 0) {
      msg =
          "💰 You are saving well this month!";
    }

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white
            .withOpacity(0.05),

        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Text(
            "AI Insights",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            msg,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}