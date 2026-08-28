import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "https://lifeledger-backend.onrender.com";

  // ================= DASHBOARD =================
  static Future<Map> getDashboard(int userId) async {
    final res = await http.get(Uri.parse("$baseUrl/dashboard/$userId/"));
    return jsonDecode(res.body);
  }

  // ================= ANALYTICS =================
  static Future<Map> getAnalytics(int userId) async {
    final res = await http.get(Uri.parse("$baseUrl/analytics/$userId/"));
    return jsonDecode(res.body);
  }

  // ================= LIFE SCORE =================
  static Future<Map> getLifeScore(int userId) async {
    final res = await http.get(Uri.parse("$baseUrl/lifescore/$userId/"));
    return jsonDecode(res.body);
  }

  // ================= EXPENSE =================
  static Future<Map> getExpenses(int userId) async {
    final res = await http.get(Uri.parse("$baseUrl/expenses/$userId/"));
    return jsonDecode(res.body);
  }

  static Future<Map> addExpense(int userId, Map data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/expenses/$userId/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  // ================= INCOME =================
  static Future<Map> getIncome(int userId) async {
    final res = await http.get(Uri.parse("$baseUrl/income/$userId/"));
    return jsonDecode(res.body);
  }

  static Future<Map> addIncome(int userId, Map data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/income/$userId/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  // ================= HABITS =================
  static Future<Map> getHabits(int userId) async {
    final res = await http.get(Uri.parse("$baseUrl/habits/$userId/"));
    return jsonDecode(res.body);
  }

  static Future<Map> toggleHabit(int habitId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/habits/log/$habitId/"),
    );
    return jsonDecode(res.body);
  }

  // ================= TASKS =================
  static Future<Map> getTasks(int userId) async {
    final res = await http.get(Uri.parse("$baseUrl/tasks/$userId/"));
    return jsonDecode(res.body);
  }

  // ================= MOOD =================
  static Future<Map> getMood(int userId) async {
    final res = await http.get(Uri.parse("$baseUrl/mood/$userId/"));
    return jsonDecode(res.body);
  }

  // ================= HISTORY =================
  static Future<Map> getHistory(int userId) async {
    final res = await http.get(Uri.parse("$baseUrl/history/$userId/"));
    return jsonDecode(res.body);
  }

  // ================= BUDGET =================
// ================= BUDGET =================
static Future getBudget(int userId) async {

  final res = await http.get(
    Uri.parse("$baseUrl/budget/$userId/"),
  );

  return jsonDecode(res.body);
}

static Future addBudget(
  int userId,
  Map data,
) async {

  final res = await http.post(

    Uri.parse("$baseUrl/budget/$userId/"),

    headers: {
      "Content-Type": "application/json"
    },

    body: jsonEncode(data),
  );

  return jsonDecode(res.body);
}
  // ================= PREDICTOR =================
  static Future<Map> getPrediction(int userId) async {
    final res = await http.get(Uri.parse("$baseUrl/predictor/$userId/"));
    return jsonDecode(res.body);
  }

  // ================= COMPARE =================
  static Future<Map> getCompare(int userId) async {
    final res = await http.get(Uri.parse("$baseUrl/compare/$userId/"));
    return jsonDecode(res.body);
  }

  // ================= ALERTS =================
  static Future<Map> getAlerts(int userId) async {
    final res = await http.get(Uri.parse("$baseUrl/alerts/$userId/"));
    return jsonDecode(res.body);
  }

  // ================= BEHAVIOR =================
  static Future<Map> getBehavior(int userId) async {
    final res = await http.get(Uri.parse("$baseUrl/behavior/$userId/"));
    return jsonDecode(res.body);
  }
  static Future getSmartAlerts(int userId) async {
  final res = await http.get(
    Uri.parse("$baseUrl/smart-alerts/$userId/")
  );
  return jsonDecode(res.body);
}
// ================= GOALS =================
static Future getGoals(
  int userId,
) async {

  final res = await http.get(
    Uri.parse(
      "$baseUrl/goals/$userId/",
    ),
  );

  return jsonDecode(res.body);
}

static Future addGoal(int userId, Map data) async {
  final res = await http.post(
    Uri.parse("$baseUrl/goals/$userId/"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );
  return jsonDecode(res.body);
}
// ================= DAILY SUMMARY =================
static Future getDailySummary(
  int userId,
) async {

  final res = await http.get(
    Uri.parse(
      "$baseUrl/daily-summary/$userId/",
    ),
  );

  return jsonDecode(res.body);
}
// ================= HEATMAP =================
static Future getHeatmap(
  int userId,
) async {

  final res = await http.get(
    Uri.parse(
      "$baseUrl/heatmap/$userId/",
    ),
  );

  return jsonDecode(res.body);
}
// ================= ACHIEVEMENTS =================
static Future getAchievements(
  int userId,
) async {

  final res = await http.get(
    Uri.parse(
      "$baseUrl/achievements/$userId/",
    ),
  );

  return jsonDecode(res.body);
}
// ================= STREAKS =================
static Future getStreaks(
  int userId,
) async {

  final res = await http.get(
    Uri.parse(
      "$baseUrl/streaks/$userId/",
    ),
  );

  return jsonDecode(res.body);
}
// ================= NET WORTH =================
static Future getNetWorth(
  int userId,
) async {

  final res = await http.get(
    Uri.parse(
      "$baseUrl/networth/$userId/",
    ),
  );

  return jsonDecode(res.body);
}
// ================= COMPARE =================
static Future compareData(
  int userId,
) async {

  final res = await http.get(

    Uri.parse(
      "$baseUrl/compare/$userId/",
    ),
  );

  return jsonDecode(res.body);
}
  // ================= FORGOT PASSWORD =================
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/forgot-password/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      ).timeout(const Duration(seconds: 45));
      return Map<String, dynamic>.from(jsonDecode(res.body));
    } catch (e) {
      return {
        "status": "error",
        "message": "Connection error: Server is starting up. Please try again in a few moments."
      };
    }
  }

  // ================= VERIFY OTP =================
  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/verify-otp/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      ).timeout(const Duration(seconds: 30));
      return Map<String, dynamic>.from(jsonDecode(res.body));
    } catch (e) {
      return {
        "status": "error",
        "message": "Connection error verifying OTP."
      };
    }
  }

  // ================= RESET PASSWORD =================
  static Future<Map<String, dynamic>> resetPassword(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/reset-password/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      ).timeout(const Duration(seconds: 30));
      return Map<String, dynamic>.from(jsonDecode(res.body));
    } catch (e) {
      return {
        "status": "error",
        "message": "Connection error resetting password."
      };
    }
  }

  // ================= ADVANCED AI & MACHINE LEARNING =================

  /// NLP Auto-Categorization (TF-IDF + Random Forest)
  static Future<Map<String, dynamic>> aiCategorize(String text, {double amount = 0.0}) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/ai/categorize/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text, "amount": amount}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {
        "status": "error",
        "predicted_category": "other",
        "confidence": 0.0,
        "is_high_confidence": false
      };
    }
  }

  /// AI Time-Series & Behavioral Expense / Savings Forecast
  static Future<Map<String, dynamic>> getAIForecast(int userId) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/api/ai/predict/$userId/"));
      return jsonDecode(res.body);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  /// AI Anomaly & Overspending Detection (IsolationForest)
  static Future<Map<String, dynamic>> getAIAnomalies(int userId) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/api/ai/anomaly/$userId/"));
      return jsonDecode(res.body);
    } catch (e) {
      return {"status": "error", "anomalies_detected": 0, "anomaly_items": []};
    }
  }

  /// AI Conversational Financial Advisor (Q&A Coach)
  static Future<Map<String, dynamic>> askAIAdvisor(int userId, String question) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/ai/advisor/$userId/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"question": question}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {
        "status": "error",
        "answer": "I am having trouble connecting to the AI engine. Please verify network connection.",
        "suggested_actions": ["Try Again", "Check ML Forecast"]
      };
    }
  }

  /// AI Advisor Chat History
  static Future<Map<String, dynamic>> getAIAdvisorHistory(int userId) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/api/ai/advisor/history/$userId/"));
      return jsonDecode(res.body);
    } catch (e) {
      return {"status": "error", "history": []};
    }
  }

  /// Active AI Models Status and Accuracy Metrics
  static Future<Map<String, dynamic>> getAIStatus() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/api/ai/status/"));
      return jsonDecode(res.body);
    } catch (e) {
      return {"status": "offline"};
    }
  }
}