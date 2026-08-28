import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';

class ExpenseScreen extends StatefulWidget {
  final int userId;
  ExpenseScreen({required this.userId});

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  String selectedCategory = 'other';
  bool _isLoading = false;
  bool _isFetching = true;
  List expenses = [];

  final List<Map> categories = [
    {'value': 'food', 'label': 'Food & Dining', 'icon': '🍕'},
    {'value': 'rent', 'label': 'Rent', 'icon': '🏠'},
    {'value': 'transport', 'label': 'Transport', 'icon': '🚗'},
    {'value': 'shopping', 'label': 'Shopping', 'icon': '🛒'},
    {'value': 'health', 'label': 'Health', 'icon': '💊'},
    {'value': 'entertainment', 'label': 'Entertainment', 'icon': '🎬'},
    {'value': 'education', 'label': 'Education', 'icon': '📚'},
    {'value': 'other', 'label': 'Other', 'icon': '💸'},
  ];

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void fetchExpenses() async {
    try {
      var url =
          Uri.parse("https://lifeledger-backend.onrender.com/expenses/${widget.userId}/");
      var response = await http.get(url);
      var data = jsonDecode(response.body);
      if (data["status"] == "success") {
        setState(() {
          expenses = data["expenses"];
          _isFetching = false;
        });
      }
    } catch (e) {
      setState(() => _isFetching = false);
    }
  }

  void addExpense() async {
    if (titleController.text.isEmpty || amountController.text.isEmpty) {
      _showSnack("Please enter title and amount");
      return;
    }
    setState(() => _isLoading = true);
    try {
      var url =
          Uri.parse("https://lifeledger-backend.onrender.com/expenses/${widget.userId}/");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": titleController.text.trim(),
          "amount": double.parse(amountController.text.trim()),
          "category": selectedCategory,
          "note": noteController.text.trim(),
        }),
      );
      var data = jsonDecode(response.body);
      if (data["status"] == "success") {
        titleController.clear();
        amountController.clear();
        noteController.clear();
        setState(() => selectedCategory = 'other');
        Navigator.pop(context);
        fetchExpenses();
        _showSnack("Expense added successfully");
      }
    } catch (e) {
      _showSnack("Unable to connect. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void deleteExpense(int id) async {
    try {
      var url =
          Uri.parse("https://lifeledger-backend.onrender.com/expenses/${widget.userId}/");
      await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );
      fetchExpenses();
      _showSnack("Expense deleted");
    } catch (e) {
      _showSnack("Unable to delete. Please try again.");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Color(0xFF1e2a4a),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _getCategoryIcon(String category) {
    return categories
            .firstWhere((c) => c['value'] == category,
                orElse: () => {'icon': '💸'})['icon'] ??
        '💸';
  }

  String? _aiSuggestedCategory;
  double _aiConfidence = 0.0;
  bool _isAutoCategorizing = false;

  void _onTitleChanged(String text, StateSetter setSheetState) async {
    if (text.trim().length < 3) {
      setSheetState(() {
        _aiSuggestedCategory = null;
        _aiConfidence = 0.0;
      });
      return;
    }

    setSheetState(() => _isAutoCategorizing = true);
    final res = await ApiService.aiCategorize(text.trim());
    if (res["status"] == "success" && res["predicted_category"] != null) {
      final predCat = res["predicted_category"];
      final conf = (res["confidence_percent"] ?? (res["confidence"] ?? 0.0) * 100).toDouble();

      setSheetState(() {
        _isAutoCategorizing = false;
        _aiSuggestedCategory = predCat;
        _aiConfidence = conf;
        // Auto-select if confident
        if (conf >= 40.0) {
          selectedCategory = predCat;
        }
      });
    } else {
      setSheetState(() => _isAutoCategorizing = false);
    }
  }

  void _showAddExpenseSheet() {
    _aiSuggestedCategory = null;
    _aiConfidence = 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF101828),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Add Expense",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 16),
                        SizedBox(width: 4),
                        Text(
                          "AI Smart NLP",
                          style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _sheetInput(
                    controller: titleController,
                    hint: "Title (e.g. Swiggy pizza, Uber cab)",
                    icon: Icons.title_rounded,
                    onChanged: (val) => _onTitleChanged(val, setSheetState)),
                if (_aiSuggestedCategory != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.psychology, color: Color(0xFF38BDF8), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "AI Predicted: ${_getCategoryLabel(_aiSuggestedCategory!)} (${_aiConfidence.toStringAsFixed(0)}% confidence)",
                            style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _sheetInput(
                    controller: amountController,
                    hint: "Amount (₹)",
                    icon: Icons.currency_rupee_rounded,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _sheetInput(
                    controller: noteController,
                    hint: "Note (optional)",
                    icon: Icons.note_outlined),
                const SizedBox(height: 16),
                Text("Category",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    bool isSelected =
                        selectedCategory == cat['value'];
                    return GestureDetector(
                      onTap: () => setSheetState(
                          () => selectedCategory = cat['value']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFf87171).withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFf87171)
                                : Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          "${cat['icon']} ${cat['label']}",
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFFf87171)
                                : Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFf87171), Color(0xFFfb923c)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : addExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text("Add Expense",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                    ),
                  ),
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCategoryLabel(String val) {
    final match = categories.firstWhere(
      (c) => c['value'] == val,
      orElse: () => {'label': val.toUpperCase()},
    );
    return match['label'] ?? val;
  }

  Widget _sheetInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
        prefixIcon:
            Icon(icon, color: Colors.white.withOpacity(0.4), size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Colors.white.withOpacity(0.1))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Colors.white.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFFf87171), width: 1.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double total = expenses.fold(
        0, (sum, e) => sum + (e["amount"] as num).toDouble());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0a0f1e), Color(0xFF101828), Color(0xFF0d1533)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    Text("Expenses",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    GestureDetector(
                      onTap: _showAddExpenseSheet,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Color(0xFFf87171),
                            Color(0xFFfb923c)
                          ]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.add_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFFf87171), Color(0xFFfb923c)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Color(0xFFf87171).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Expenses",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13)),
                      SizedBox(height: 6),
                      Text("₹ ${total.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: _isFetching
                    ? Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF6c8fff)))
                    : expenses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("💸",
                                    style: TextStyle(fontSize: 48)),
                                SizedBox(height: 12),
                                Text("No expenses yet",
                                    style: TextStyle(
                                        color:
                                            Colors.white.withOpacity(0.3),
                                        fontSize: 14)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding:
                                EdgeInsets.symmetric(horizontal: 24),
                            itemCount: expenses.length,
                            itemBuilder: (_, i) {
                              var e = expenses[i];
                              return Container(
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withOpacity(0.04),
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Colors.white
                                          .withOpacity(0.07)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44, height: 44,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFf87171)
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _getCategoryIcon(
                                              e["category"]),
                                          style: TextStyle(
                                              fontSize: 20),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(e["title"],
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight:
                                                      FontWeight.w500)),
                                          SizedBox(height: 2),
                                          Text(e["date"],
                                              style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.4),
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "-₹ ${(e["amount"] as num).toStringAsFixed(0)}",
                                      style: TextStyle(
                                          color: Color(0xFFf87171),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () =>
                                          deleteExpense(e["id"]),
                                      child: Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.white
                                              .withOpacity(0.3),
                                          size: 18),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}