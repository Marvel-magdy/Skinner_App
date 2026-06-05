import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart' show adminToken;
/// Service for the patient ↔ doctor Chat API.
/// These are the persistent 1-to-1 chat channels (NOT the AI chatbot).
class ChatService {
  static const String baseUrl = 'https://api.skinnerai.site';
  final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));
  /// Helper: get Bearer token from SharedPreferences.
  /// Falls back to the global adminToken if SharedPreferences has no value.
  Future<Options> _authOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? adminToken ?? '';
    return Options(headers: {'Authorization': 'Bearer $token'});
  }
  /// GET /api/chat/my-chats
  /// Returns all chat channels for the logged-in user.
  /// Each channel includes: chat_id, status (active/locked),
  /// doctor_name / patient_name, last_message preview.
  Future<Response> getMyChats() async {
    return await _dio.get(
      '/api/chat/my-chats',
      options: await _authOptions(),
    );
  }
  /// GET /api/chat/messages/{chatId}
  /// Returns all messages for a chat (authorized).
  /// Response includes chat_status so the frontend knows if messaging is enabled.
  Future<Response> getChatMessages({required String chatId}) async {
    return await _dio.get(
      '/api/chat/messages/$chatId',
      options: await _authOptions(),
    );
  }
  /// POST /api/chat/send  (multipart/form-data)
  /// Sends a message to a chat channel.
  /// Will be rejected with 403 if the chat is locked.
  /// [chatId] is required. [messageText] and [file] are optional
  /// but at least one should be provided.
  Future<Response> sendMessage({
    required String chatId,
    String? messageText,
    File? file,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? adminToken ?? '';
    final Map<String, dynamic> formMap = {
      'chat_id': chatId,
    };
    if (messageText != null && messageText.trim().isNotEmpty) {
      formMap['message_text'] = messageText;
    }
    if (file != null) {
      formMap['chat_file'] = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      );
    }
    final formData = FormData.fromMap(formMap);
    return await _dio.post(
      '/api/chat/send',
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        contentType: 'multipart/form-data',
      ),
    );
  }
  /// GET /api/chat/access/{chatId}
  /// Check chat access and status (patient or doctor).
  /// Returns access result with chat status (active/locked).
  Future<Response> checkChatAccess({required String chatId}) async {
    return await _dio.get(
      '/api/chat/access/$chatId',
      options: await _authOptions(),
    );
  }

  /// POST /api/chat/mark-read/{chatId}
  /// Marks all messages in the chat as read by the current user.
  /// This enables the "seen" indicator for the other party.
  Future<Response?> markAsRead({required String chatId}) async {
    try {
      return await _dio.post(
        '/api/chat/mark-read/$chatId',
        options: await _authOptions(),
      );
    } catch (e) {
      // Silently fail — marking as read is not critical
      return null;
    }
  }
}