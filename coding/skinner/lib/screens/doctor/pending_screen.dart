import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skinner/widgets/pending_card.dart';
import 'package:skinner/services/auth_service.dart';

class PendingScreen extends StatefulWidget {
  const PendingScreen({super.key});

  @override
  State<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen> {
  List cases = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCases();
  }

  /// Resolve token: prefer the in-memory global (set right after login),
  /// fall back to SharedPreferences for cases where the app was restarted.
  Future<String> _resolveToken() async {
    if (adminToken != null && adminToken!.isNotEmpty) return adminToken!;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<void> getCases() async {
    try {
      final token = await _resolveToken();
      if (token.isEmpty) throw Exception('No auth token');

      final response = await AuthService().getPendingCases(token: token);

      setState(() {
        cases = response.data['data'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      debugPrint('PendingScreen error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (cases.isEmpty) {
      return const Center(
        child: Text(
          "No pending cases",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cases.length,
      itemBuilder: (context, index) {
        final caseData = cases[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PendingCard(
            caseData: caseData,
          ),
        );
      },
    );
  }
}