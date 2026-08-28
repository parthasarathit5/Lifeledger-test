import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AIAdvisorScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const AIAdvisorScreen({
    super.key,
    required this.userId,
    this.userName = "User",
  });

  @override
  State<AIAdvisorScreen> createState() => _AIAdvisorScreenState();
}

class _AIAdvisorScreenState extends State<AIAdvisorScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isFetchingHistory = true;

  final List<Map<String, dynamic>> _messages = [];

  final List<String> _suggestedPrompts = [
    "Can I afford a ₹50,000 purchase?",
    "Where am I overspending?",
    "Forecast next month cashflow",
    "How to reach my ₹1 Lakh goal?",
    "Analyze habit and spending correlation",
    "Give me a 30-day savings plan",
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final res = await ApiService.getAIAdvisorHistory(widget.userId);
      if (res["status"] == "success" && res["history"] != null) {
        final List hist = res["history"];
        setState(() {
          for (var item in hist) {
            _messages.add({
              "sender": "user",
              "text": item["question"] ?? "",
              "time": item["created_at"] ?? "",
            });
            _messages.add({
              "sender": "ai",
              "text": item["answer"] ?? "",
              "time": item["created_at"] ?? "",
            });
          }
          _isFetchingHistory = false;
        });
        _scrollToBottom();
      } else {
        _setWelcomeMessage();
      }
    } catch (e) {
      _setWelcomeMessage();
    }
  }

  void _setWelcomeMessage() {
    setState(() {
      _isFetchingHistory = false;
      if (_messages.isEmpty) {
        _messages.add({
          "sender": "ai",
          "text":
              "👋 Hello ${widget.userName}! I am your **LifeLedger AI Financial & Lifestyle Coach** powered by real-time Machine Learning models.\n\nAsk me anything about affordability, expense forecasts, spending leaks, habits correlation, or custom savings plans!",
          "time": "Just now",
        });
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String query) async {
    final text = query.trim();
    if (text.isEmpty || _isLoading) return;

    _textController.clear();
    setState(() {
      _messages.add({
        "sender": "user",
        "text": text,
        "time": "Just now",
      });
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final res = await ApiService.askAIAdvisor(widget.userId, text);
      if (res["status"] == "success") {
        setState(() {
          _messages.add({
            "sender": "ai",
            "text": res["answer"] ?? "Analysis complete.",
            "time": res["timestamp"] ?? "Just now",
            "suggested_actions": res["suggested_actions"] ?? [],
          });
          _isLoading = false;
        });
      } else {
        setState(() {
          _messages.add({
            "sender": "ai",
            "text": res["answer"] ?? "Error processing request.",
            "time": "Just now",
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          "sender": "ai",
          "text": "⚠️ Network communication error with AI engine.",
          "time": "Just now",
        });
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isUser = msg["sender"] == "user";
    final text = msg["text"] ?? "";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.84,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFF1E2640), Color(0xFF161D31)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          border: Border.all(
            color: isUser
                ? Colors.transparent
                : const Color(0xFF38BDF8).withOpacity(0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? const Color(0xFF7C3AED).withOpacity(0.25)
                  : Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF38BDF8),
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "LifeLedger ML Coach",
                    style: TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                msg["time"] ?? "",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121826),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Financial Advisor",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "ML Models Online • RandomForest & NLP",
                  style: TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Suggested prompts carousel
          Container(
            height: 48,
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _suggestedPrompts.length,
              itemBuilder: (context, idx) {
                final p = _suggestedPrompts[idx];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: const Color(0xFF1E2640),
                    side: const BorderSide(color: Color(0xFF334155)),
                    label: Text(
                      p,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () => _sendMessage(p),
                  ),
                );
              },
            ),
          ),

          // Message stream
          Expanded(
            child: _isFetchingHistory
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, idx) {
                      return _buildMessageBubble(_messages[idx]);
                    },
                  ),
          ),

          // Thinking / loading indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "AI is analyzing your dataset & forecasting...",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Input field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF121826),
              border: Border(
                top: BorderSide(color: Color(0xFF1E293B), width: 1),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2640),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: "Ask AI about budget, goals, spending...",
                          hintStyle: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (val) => _sendMessage(val),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _sendMessage(_textController.text),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF9333EA)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
