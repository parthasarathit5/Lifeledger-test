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
    "Where am I spending the most?",
    "Forecast next month cashflow",
    "How to save on tax (80C & 80D)?",
    "Simulate my FIRE retirement target",
    "How do my daily habits affect savings?",
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
              "👋 Hello ${widget.userName}! I am your **LifeLedger Precision AI Financial Coach**.\n\nAsk me specific questions about affordability, expense forecasts, tax savings, debt strategies, or wealth planning!",
          "time": "Just now",
        });
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 140,
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
          "text": "⚠️ Network error connecting to the AI inference engine.",
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
          maxWidth: MediaQuery.of(context).size.width * 0.86,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF059669) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          border: Border.all(
            color: isUser ? Colors.transparent : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: isUser ? const Color(0xFF059669).withOpacity(0.2) : Colors.black.withOpacity(0.04),
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
                      color: const Color(0xFFECFDF5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology, color: Color(0xFF059669), size: 16),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "LifeLedger Precision AI",
                    style: TextStyle(
                      color: Color(0xFF059669),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Text(
              text,
              style: TextStyle(
                color: isUser ? Colors.white : const Color(0xFF1E293B),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                msg["time"] ?? "",
                style: TextStyle(
                  color: isUser ? Colors.white70 : const Color(0xFF94A3B8),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Financial Coach",
                  style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "RandomForest & NLP Engine Active",
                  style: TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Prompt suggestions
          Container(
            height: 48,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _suggestedPrompts.length,
              itemBuilder: (context, idx) {
                final p = _suggestedPrompts[idx];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    label: Text(
                      p,
                      style: const TextStyle(color: Color(0xFF334155), fontSize: 12, fontWeight: FontWeight.w500),
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
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF059669)))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, idx) => _buildMessageBubble(_messages[idx]),
                  ),
          ),

          // Typing indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF059669)),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "AI is computing your customized mathematical verdict...",
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

          // Input field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -3)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: "Ask AI (e.g. Can I afford a 60k laptop?)...",
                          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (val) => _sendMessage(val),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(_textController.text),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)]),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
