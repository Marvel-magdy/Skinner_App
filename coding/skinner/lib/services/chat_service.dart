import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  static const String baseUrl =
      "http://187.127.227.63";

  Future<Map<String, dynamic>> sendMessage({
    required String message,
    required String conversationId,
  }) async {

    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString('token');

    final response = await http.post(
      Uri.parse(
        '$baseUrl/api/chatbot/send',
      ),
      headers: {
        "Content-Type":
            "application/json",
        "Authorization":
            "Bearer $token",
      },
      body: jsonEncode({
        "query": message,
        "conversation_id":
            conversationId,
      }),
    );

    return jsonDecode(response.body);
  }
}