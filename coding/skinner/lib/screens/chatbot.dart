import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() =>
      _ChatBotScreenState();
}

class _ChatBotScreenState
    extends State<ChatBotScreen> {  
  @override
  final TextEditingController
    messageController =
        TextEditingController();

List<Map<String, dynamic>> messages = [];

String conversationId = "";
bool isLoading = false;
final Dio dio = Dio();

Future<void> sendMessage() async {
  print("SEND CLICKED");
  if (messageController.text.trim().isEmpty) {
    return;
  }

  String userMessage =
      messageController.text.trim();

  setState(() {
    messages.add({
      "isUser": true,
      "text": userMessage,
    });
  });

  messageController.clear();

  try {
    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString('token');

print("TOKEN = $token");
print("MESSAGE = $userMessage");
print("CONVERSATION = $conversationId");

setState(() {
  isLoading = true;
});
    final response = await dio.post(
      
      "http://187.127.227.63/api/chatbot/send",
      data: {
        "query": userMessage,
        "conversation_id": conversationId,
      },
      options: Options(
        headers: {
          "Authorization":
              "Bearer $token",
        },
      ),
    );
    print(response.data);

    final data =
        response.data["data"];

    conversationId =
        data["conversation_id"];
setState(() {
  isLoading = false;
});
    setState(() {
      messages.add({
        "isUser": false,
        "text": data["answer"],
      });
    });
  } catch (e) {

  setState(() {
    isLoading = false;

    messages.add({
      "isUser": false,
      "text": "Error connecting to chatbot",
    });
  });
}}
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2C67FF),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("AI Health Assistant", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("HIPAA Compliant • Encrypted", style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: Column(
        children: [
          /// Warning Box
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2000) : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFACC15)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "This chatbot provides general information only and is not a substitute for professional medical advice.",
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 52),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Encrypted", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (isLoading && index == messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 10),
                          Text("Typing..."),
                        ],
                      ),
                    ),
                  );
                }
                final msg = messages[index];
                return Align(
                  alignment: msg["isUser"] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg["isUser"]
                          ? const Color(0xFF2C67FF)
                          : (isDark ? const Color(0xFF1E293B) : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                        color: msg["isUser"]
                            ? Colors.white
                            : (isDark ? const Color(0xFFE2E8F0) : Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          /// Bottom Input
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        filled: true,
                        fillColor: isDark ? const Color(0xFF334155) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: sendMessage,
                    child: Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C67FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
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