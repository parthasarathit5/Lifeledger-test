import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../services/api_service.dart';

class ExpenseScreen extends StatefulWidget {
  final int userId;
  const ExpenseScreen({super.key, required this.userId});

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

  // NLP Auto-Categorization state
  bool _isPredicting = false;
  String? _predictedCategory;
  double _predictionConfidence = 0.0;
  Timer? _debounceTimer;

  final List<Map<String, String>> categories = [
    {'value': 'food', 'label': 'Food & Dining', 'icon': '🍕'},
    {'value': 'rent', 'label': 'Rent & Housing', 'icon': '🏠'},
    {'value': 'transport', 'label': 'Transport & Fuel', 'icon': '🚗'},
    {'value': 'shopping', 'label': 'Shopping & Retail', 'icon': '🛍️'},
    {'value': 'health', 'label': 'Health & Fitness', 'icon': '💊'},
    {'value': 'entertainment', 'label': 'Entertainment', 'icon': '🎬'},
    {'value': 'education', 'label': 'Education', 'icon': '📚'},
    {'value': 'other', 'label': 'Other / Bills', 'icon': '🧾'},
  ];

  @override
  void initState() {
    super.initState();
    fetchExpenses();
    titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    titleController.removeListener(_onTitleChanged);
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    final text = titleController.text;
    _debounceTimer?.cancel();
    if (text.trim().length < 3) {
      if (_predictedCategory != null) {
        setState(() {
          _predictedCategory = null;
          _predictionConfidence = 0.0;
        });
      }
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _isPredicting = true);
      try {
        final res = await ApiService.aiCategorize(text.trim());
        if (res["status"] == "success" && mounted) {
          final String cat = res["predicted_category"] ?? "other";
          final double conf = (res["confidence"] ?? 0.0).toDouble();
          setState(() {
            _predictedCategory = cat;
            _predictionConfidence = conf;
            selectedCategory = cat;
            _isPredicting = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isPredicting = false);
      }
    });
  }

  Future<void> fetchExpenses() async {
    try {
      var url = Uri.parse("https://lifeledger-backend.onrender.com/expenses/${widget.userId}/");
      var response = await http.get(url);
      var data = jsonDecode(response.body);

      if (data["status"] == "success") {
        setState(() {
          expenses = data["expenses"] ?? [];
          _isFetching = false;
        });
      }
    } catch (e) {
      setState(() => _isFetching = false);
    }
  }

  Future<void> addExpense() async {
    if (titleController.text.trim().isEmpty || amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill title and amount")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      var url = Uri.parse("https://lifeledger-backend.onrender.com/expenses/${widget.userId}/");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": titleController.text.trim(),
          "amount": double.tryParse(amountController.text.trim()) ?? 0,
          "category": selectedCategory,
          "note": noteController.text.trim(),
        }),
      );

      var data = jsonDecode(response.body);

      if (data["status"] == "success") {
        titleController.clear();
        amountController.clear();
        noteController.clear();
        setState(() {
          selectedCategory = 'other';
          _predictedCategory = null;
          _isLoading = false;
        });
        Navigator.pop(context);
        fetchExpenses();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Expense added & AI models updated!"),
            backgroundColor: Color(0xFF059669),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      var url = Uri.parse("https://lifeledger-backend.onrender.com/expenses/delete/$id/");
      var response = await http.delete(url);
      var data = jsonDecode(response.body);
      if (data["status"] == "success") {
        fetchExpenses();
      }
    } catch (e) {}
  }

  void _showAddExpenseModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Log New Expense", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Title Field
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                    decoration: InputDecoration(
                      labelText: "Expense Title (e.g. Swiggy, Uber, Rent)",
                      labelStyle: const TextStyle(color: Color(0xFF64748B)),
                      prefixIcon: const Icon(Icons.title, color: Color(0xFF059669), size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5)),
                    ),
                  ),

                  // Real-time AI Badge
                  if (_isPredicting)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF059669))),
                          SizedBox(width: 8),
                          Text("AI analyzing title...", style: TextStyle(color: Color(0xFF059669), fontSize: 12, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    )
                  else if (_predictedCategory != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, color: Color(0xFF059669), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            "AI Predicted: ${_predictedCategory!.toUpperCase()} (${(_predictionConfidence * 100).toStringAsFixed(0)}% confidence)",
                            style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 14),

                  // Amount Field
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                    decoration: InputDecoration(
                      labelText: "Amount (₹)",
                      labelStyle: const TextStyle(color: Color(0xFF64748B)),
                      prefixIcon: const Icon(Icons.currency_rupee, color: Color(0xFF059669), size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Category Selector
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                    decoration: InputDecoration(
                      labelText: "Category",
                      labelStyle: const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    items: categories
                        .map((c) => DropdownMenuItem(
                              value: c['value'],
                              child: Text("${c['icon']} ${c['label']}"),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setModalState(() => selectedCategory = val ?? 'other');
                      setState(() => selectedCategory = val ?? 'other');
                    },
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _isLoading ? null : addExpense,
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Add Expense", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double total = expenses.fold(0.0, (sum, e) => sum + (e["amount"] as num).toDouble());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Expenses Ledger",
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF059669), size: 28),
            onPressed: _showAddExpenseModal,
          ),
        ],
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF059669)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Outflow Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFF59E0B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Monthly Outflow", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(
                          "₹${total.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text("${expenses.length} recorded entries", style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Entries List
                  const Text("All Expense Records", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 12),
                  if (expenses.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Center(
                        child: Text("No expenses recorded yet. Tap + to log one with AI Auto-Categorizer.", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                      ),
                    )
                  else
                    ...expenses.map((e) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.arrow_upward, color: Color(0xFFEF4444), size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(e["title"] ?? "Untitled", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                                      Text(e["category"] ?? "other", style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5)),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("-₹${e['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFEF4444))),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Color(0xFF94A3B8), size: 18),
                                    onPressed: () => deleteExpense(e["id"]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}