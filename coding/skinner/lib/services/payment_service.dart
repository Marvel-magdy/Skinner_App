import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart' show adminToken;

class PaymentService {
  PaymentService({this.baseUrl = 'https://api.skinnerai.site'});

  final String baseUrl;

  /// Book an appointment for the doctor and slot.
  /// Returns the response body, which contains the 'appointment_id'.
  Future<Map<String, dynamic>> bookAppointment({
    required String doctorSyndicateId,
    required String date,
    required String analysisId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? adminToken ?? '';
    final dio = Dio(BaseOptions(baseUrl: baseUrl));

    final response = await dio.post(
      '/api/appointment/book',
      data: {
        'medical_syndicate_id_card': doctorSyndicateId,
        'date': date,
        'analysis_id': analysisId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return response.data as Map<String, dynamic>;
  }

  /// Complete payment for the booked appointment.
  /// Returns the response body, which contains the 'chat_id' for messaging.
  Future<Map<String, dynamic>> payAppointment({
    required String appointmentId,
    required String method,
    required String cardHolderName,
    required String cardLast4,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? adminToken ?? '';
    final dio = Dio(BaseOptions(baseUrl: baseUrl));

    final response = await dio.post(
      '/api/payment/pay',
      data: {
        'appointment_id': appointmentId,
        'method': method,
        'card_holder_name': cardHolderName,
        'card_last4': cardLast4,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return response.data as Map<String, dynamic>;
  }

  /// Resolves the latest analysis_id from patient's history.
  /// If history is empty, uploads a dummy asset image to create a new analysis.
  Future<String?> getLatestAnalysisId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? adminToken ?? '';
    final dio = Dio(BaseOptions(baseUrl: baseUrl));

    // 1. Fetch analysis history
    try {
      final historyResp = await dio.get(
        '/api/analysis/history',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      final history = historyResp.data['data'] ?? historyResp.data ?? [];
      if (history is List && history.isNotEmpty) {
        final latest = history.first;
        return latest['analysis_id']?.toString() ?? latest['id']?.toString();
      }
    } catch (e) {
      debugPrint("Failed to fetch analysis history: $e");
    }

    // 2. Fallback: Upload a dummy image to create a new analysis
    try {
      debugPrint("Analysis history is empty. Creating a dummy analysis record...");
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/download_temp.png');
      
      final byteData = await rootBundle.load('assets/download.png');
      await tempFile.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          tempFile.path,
          filename: 'download.png',
        ),
      });

      final uploadResp = await dio.post(
        '/api/analysis/upload-and-analyze',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = uploadResp.data['data'] ?? uploadResp.data;
      if (data != null) {
        return data['analysis_id']?.toString() ?? data['id']?.toString();
      }
    } catch (e) {
      debugPrint("Failed to create dummy analysis fallback: $e");
    }

    return null;
  }

  /// Original payment confirmation logic (maintained for backward compatibility).
  Future<PaymentResult> sendPaymentConfirmation({
    required String transactionId,
    required double amount,
    String? appointmentId,
    Map<String, dynamic>? metadata,
    String? apiKey,
  }) async {
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    final body = {
      'transaction_id': transactionId,
      'amount': amount,
      if (appointmentId != null) 'appointment_id': appointmentId,
      if (metadata != null) 'metadata': metadata,
    };

    try {
      final response = await dio.post(
        '/payments/confirm',
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (apiKey != null) 'Authorization': 'Bearer $apiKey',
          },
        ),
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return PaymentResult.success(response.data);
      } else {
        return PaymentResult.failure('HTTP ${response.statusCode}', response.data);
      }
    } catch (e) {
      return PaymentResult.failure(e.toString(), null);
    }
  }

  /// Get all appointments for the logged-in user.
  Future<List<dynamic>> getMyAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? adminToken ?? '';
    final dio = Dio(BaseOptions(baseUrl: baseUrl));

    final response = await dio.get(
      '/api/appointment/my',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final data = response.data['data'] ?? response.data ?? [];
    if (data is List) {
      return data;
    }
    return [];
  }
}

class PaymentResult {
  PaymentResult._({required this.ok, this.data, this.error});

  final bool ok;
  final dynamic data;
  final dynamic error;

  factory PaymentResult.success(dynamic data) => PaymentResult._(ok: true, data: data);

  factory PaymentResult.failure(String message, dynamic data) =>
      PaymentResult._(ok: false, error: {'message': message, 'data': data});
}
