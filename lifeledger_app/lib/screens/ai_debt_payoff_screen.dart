import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AIDebtPayoffScreen extends StatefulWidget {
  final int userId;

  const AIDebtPayoffScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AIDebtPayoffScreen> createState() => _AIDebtPayoffScreenState();
}

class _AIDebtPayoffScreenState extends State<AIDebtPayoffScreen> {
  List<Map<String, dynamic>> _debts = [];
  double _extraMonthlyPayment = 5000.0;
  String _strategy = "avalanche"; // 'avalanche' or 'snowball'
  bool _isLoading = true;

  final List<Map<String, dynamic>> _demoSampleDebts = [
    {"name": "HDFC Credit Card", "balance": 45000.0, "rate": 36.0, "min_pay": 2250.0},
    {"name": "Personal Loan (SBI)", "balance": 180000.0, "rate": 14.5, "min_pay": 5800.0},
    {"name": "Two-Wheeler Bike EMI", "balance": 65000.0, "rate": 11.0, "min_pay": 2100.0},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserDebts();
  }

  Future<void> _loadUserDebts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? saved = prefs.getString("user_debts_${widget.userId}");
      if (saved != null && saved.isNotEmpty) {
        final List decoded = jsonDecode(saved);
        setState(() {
          _debts = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _debts = []; // Default is 0 debts (Debt-Free)
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _debts = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserDebts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_debts_${widget.userId}", jsonEncode(_debts));
    } catch (e) {
      // ignore
    }
  }

  void _loadDemoData() {
    setState(() {
      _debts = List.from(_demoSampleDebts);
    });
    _saveUserDebts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("📊 Loaded 3 Demo Debt Accounts for Presentation"),
        backgroundColor: Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearAllDebts() {
    setState(() {
      _debts.clear();
    });
    _saveUserDebts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🎉 All debts cleared! You are 100% Debt-Free!"),
        backgroundColor: Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddDebtDialog() {
    final nameCtrl = TextEditingController();
    final balanceCtrl = TextEditingController();
    final rateCtrl = TextEditingController(text: "18.0");
    final minPayCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.credit_card, color: Color(0xFF059669)),
            SizedBox(width: 8),
            Text("Add Loan / Credit Card", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Account Name (e.g. Axis Card, Education Loan)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: balanceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Outstanding Balance (₹)", border: OutlineInputBorder(), prefixText: "₹ "),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: rateCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Interest Rate (% APR)", border: OutlineInputBorder(), suffixText: "%"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: minPayCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Monthly Minimum EMI (₹)", border: OutlineInputBorder(), prefixText: "₹ "),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
            onPressed: () {
              final name = nameCtrl.text.trim();
              final bal = double.tryParse(balanceCtrl.text.trim()) ?? 0.0;
              final rate = double.tryParse(rateCtrl.text.trim()) ?? 18.0;
              final minPay = double.tryParse(minPayCtrl.text.trim()) ?? (bal * 0.05);

              if (name.isNotEmpty && bal > 0) {
                Navigator.pop(ctx);
                setState(() {
                  _debts.add({"name": name, "balance": bal, "rate": rate, "min_pay": minPay});
                });
                _saveUserDebts();
              }
            },
            child: const Text("Save Account"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF059669))),
      );
    }

    double totalDebt = _debts.fold(0.0, (acc, d) => acc + (d["balance"] as num).toDouble());
    double totalMinPay = _debts.fold(0.0, (acc, d) => acc + (d["min_pay"] as num).toDouble());

    // Mathematical Payoff Projection
    int monthsWithExtra = totalDebt > 0 ? (totalDebt / (totalMinPay + _extraMonthlyPayment)).ceil().clamp(2, 120) : 0;
    int monthsWithoutExtra = totalDebt > 0 ? (totalDebt / (totalMinPay > 0 ? totalMinPay : 1000)).ceil().clamp(4, 240) : 0;
    int monthsSaved = (monthsWithoutExtra - monthsWithExtra).clamp(0, 240);
    double interestSaved = monthsSaved * (totalDebt * 0.011);

    // Sorted according to Strategy
    List<Map<String, dynamic>> sortedDebts = List.from(_debts);
    if (_strategy == "avalanche") {
      sortedDebts.sort((a, b) => (b["rate"] as num).compareTo(a["rate"] as num));
    } else {
      sortedDebts.sort((a, b) => (a["balance"] as num).compareTo(b["balance"] as num));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "AI Debt Payoff Accelerator",
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF059669)),
            tooltip: "Add Debt",
            onPressed: _showAddDebtDialog,
          ),
          if (_debts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              tooltip: "Clear All (Mark Debt-Free)",
              onPressed: _clearAllDebts,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= IF USER HAS 0 DEBTS (DEBT-FREE STATE) =================
            if (_debts.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF0D9488)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF059669).withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "🎉 Congratulations! You Are Debt-Free!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "You have 0 active loans or credit card balances registered in LifeLedger. Zero interest fees!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 12.5),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatColumn(label: "Total Debt", val: "₹0"),
                          _StatColumn(label: "Interest Owed", val: "₹0 (0%)"),
                          _StatColumn(label: "Credit Health", val: "100 / 100"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ACTION BUTTONS FOR ZERO DEBT
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.add_card, size: 18),
                      label: const Text("+ Add My Loan / Card", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      onPressed: _showAddDebtDialog,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF059669),
                        side: const BorderSide(color: Color(0xFF059669), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.play_circle_outline, size: 18),
                      label: const Text("Load Demo Debts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      onPressed: _loadDemoData,
                    ),
                  ),
                ],
              ),
            ]

            // ================= IF USER HAS DEBTS (SIMULATION ACTIVE) =================
            else ...[
              // HERO HORIZON CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF0D9488)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF059669).withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "AI Projected Debt-Free Date",
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _strategy == "avalanche" ? "⚡ Avalanche (Highest APR)" : "🔥 Snowball (Small Balance)",
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "$monthsWithExtra Months",
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            "(~${(monthsWithExtra / 12).toStringAsFixed(1)} Years)",
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "🎉 You will become debt-free $monthsSaved Months Earlier and save ₹${interestSaved.toStringAsFixed(0)} in interest!",
                      style: const TextStyle(color: Color(0xFFFDE047), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatColumn(label: "Total Debt Balance", val: "₹${totalDebt.toStringAsFixed(0)}"),
                          _StatColumn(label: "Min Monthly EMI", val: "₹${totalMinPay.toStringAsFixed(0)}/mo"),
                          _StatColumn(label: "Interest Saved", val: "₹${interestSaved.toStringAsFixed(0)}"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // EXTRA PAYMENT SLIDER
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Extra Monthly Prepayment",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          "+₹${_extraMonthlyPayment.toStringAsFixed(0)}/month",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF059669)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text("Slide to see how extra savings accelerate your debt freedom:", style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5)),
                    Slider(
                      value: _extraMonthlyPayment.clamp(0.0, 20000.0),
                      min: 0,
                      max: 20000,
                      divisions: 40,
                      activeColor: const Color(0xFF059669),
                      inactiveColor: const Color(0xFFE2E8F0),
                      onChanged: (v) => setState(() => _extraMonthlyPayment = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // STRATEGY TOGGLE
              const Text("Select AI Payoff Strategy", style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _strategy = "avalanche"),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _strategy == "avalanche" ? const Color(0xFFECFDF5) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _strategy == "avalanche" ? const Color(0xFF059669) : const Color(0xFFE2E8F0), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.bolt, size: 16, color: _strategy == "avalanche" ? const Color(0xFF059669) : const Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Text("Avalanche", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _strategy == "avalanche" ? const Color(0xFF065F46) : const Color(0xFF0F172A))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text("Highest APR % First\nSaves Max Money", style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _strategy = "snowball"),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _strategy == "snowball" ? const Color(0xFFECFDF5) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _strategy == "snowball" ? const Color(0xFF059669) : const Color(0xFFE2E8F0), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.snowboarding, size: 16, color: _strategy == "snowball" ? const Color(0xFF059669) : const Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Text("Snowball", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _strategy == "snowball" ? const Color(0xFF065F46) : const Color(0xFF0F172A))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text("Smallest Balance First\nFast Psychological Wins", style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ACTIVE DEBT PRIORITY SEQUENCE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("AI Payoff Priority Sequence", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  Row(
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 15, color: Color(0xFF059669)),
                        label: const Text("Add Account", style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: _showAddDebtDialog,
                      ),
                      TextButton(
                        onPressed: _clearAllDebts,
                        child: const Text("Clear All", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ...sortedDebts.asMap().entries.map((entry) {
                int priority = entry.key + 1;
                var d = entry.value;
                bool isHighApr = (d['rate'] as num) >= 20;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: priority == 1 ? const Color(0xFF10B981) : const Color(0xFFE2E8F0), width: priority == 1 ? 1.5 : 1.0),
                    boxShadow: [
                      if (priority == 1) BoxShadow(color: const Color(0xFF10B981).withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: priority == 1 ? const Color(0xFF059669) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "#$priority",
                            style: TextStyle(color: priority == 1 ? Colors.white : const Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(d["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1E293B))),
                                if (priority == 1) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4)),
                                    child: const Text("ATTACK FIRST", style: TextStyle(color: Color(0xFF059669), fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text("Interest Rate: ${d['rate']}% APR • Min EMI: ₹${(d['min_pay'] as num).toStringAsFixed(0)}/mo", style: TextStyle(color: isHighApr ? const Color(0xFFDC2626) : const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("₹${(d['balance'] as num).toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _debts.remove(d);
                              });
                              _saveUserDebts();
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Text("Delete", style: TextStyle(color: Colors.redAccent, fontSize: 10.5)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String val;

  const _StatColumn({required this.label, required this.val});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
      ],
    );
  }
}
