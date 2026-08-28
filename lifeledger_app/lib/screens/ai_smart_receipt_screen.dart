import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AISmartReceiptScreen extends StatefulWidget {
  final int userId;

  const AISmartReceiptScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AISmartReceiptScreen> createState() => _AISmartReceiptScreenState();
}

class _AISmartReceiptScreenState extends State<AISmartReceiptScreen> {
  bool _isAnalyzing = false;
  Map<String, dynamic>? _scannedResult;

  final List<Map<String, dynamic>> _sampleReceipts = [
    {
      "merchant": "DMart Supermarket",
      "total": 3480.50,
      "category": "food",
      "items": [
        {"name": "Organic Wheat Flour 5kg", "price": 280.0},
        {"name": "Sunflower Cooking Oil 2L", "price": 320.0},
        {"name": "Dairy Milk Pack & Butter", "price": 190.50},
        {"name": "Household Cleaning Supplies", "price": 690.0},
        {"name": "Fresh Fruits & Vegetables", "price": 2000.0}
      ],
      "tax": 174.0,
      "date": "Today, 10:15 AM"
    },
    {
      "merchant": "Apollo Pharmacy",
      "total": 1250.0,
      "category": "health",
      "items": [
        {"name": "Prescription Blood Pressure Tablets", "price": 620.0},
        {"name": "Multivitamin Supplements", "price": 450.0},
        {"name": "First Aid Bandages", "price": 180.0}
      ],
      "tax": 62.5,
      "date": "Yesterday, 07:30 PM"
    }
  ];

  void _simulateScan(Map<String, dynamic> receipt) async {
    setState(() {
      _isAnalyzing = true;
      _scannedResult = null;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    setState(() {
      _isAnalyzing = false;
      _scannedResult = receipt;
    });
  }

  void _addScannedExpense() async {
    if (_scannedResult == null) return;
    try {
      await ApiService.addExpense(widget.userId, {
        "title": _scannedResult!["merchant"],
        "amount": _scannedResult!["total"],
        "category": _scannedResult!["category"],
        "note": "Scanned via AI Smart Receipt OCR",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Added ₹${_scannedResult!['total']} to ${_scannedResult!['category']}!"),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error saving expense")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "AI Smart Receipt Analyzer",
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scanner Prompt Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.document_scanner, color: Color(0xFF059669), size: 36),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Instant Receipt OCR & Itemizer",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Select a simulated receipt or camera snap to parse line items, tax, and auto-categorize:",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.shopping_cart, size: 16),
                        label: const Text("Scan Grocery Bill", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                        onPressed: () => _simulateScan(_sampleReceipts[0]),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF059669),
                          side: const BorderSide(color: Color(0xFF059669)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.medication, size: 16),
                        label: const Text("Scan Pharmacy", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                        onPressed: () => _simulateScan(_sampleReceipts[1]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (_isAnalyzing)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF059669)),
                      const SizedBox(height: 14),
                      const Text(
                        "AI is extracting merchant, GST, and line items...",
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),

            if (_scannedResult != null) ...[
              const Text(
                "Parsed OCR Result",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _scannedResult!["merchant"],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            (_scannedResult!["category"] as String).toUpperCase(),
                            style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(_scannedResult!["date"], style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5)),
                    const Divider(height: 24),
                    ...(_scannedResult!["items"] as List).map((it) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(it["name"], style: const TextStyle(color: Color(0xFF334155), fontSize: 13)),
                              Text("₹${it['price']}", style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        )),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Bill Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                        Text("₹${_scannedResult!['total']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF059669))),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text("Log Expense to LifeLedger", style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: _addScannedExpense,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
