import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skinner/widgets/finished_card.dart';
import 'package:skinner/services/auth_service.dart';

class FinishedScreen extends StatefulWidget {
  const FinishedScreen({super.key});

  @override
  State<FinishedScreen> createState() => _FinishedScreenState();
}

class _FinishedScreenState extends State<FinishedScreen> {
  List reviewedCases = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCases();
  }

  /// Prefer in-memory global token (set right after login),
  /// fall back to SharedPreferences.
  Future<String> _resolveToken() async {
    if (adminToken != null && adminToken!.isNotEmpty) return adminToken!;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<void> getCases() async {
    try {
      final token = await _resolveToken();
      if (token.isEmpty) throw Exception('No auth token');

      final response = await AuthService().getReviewedCases(token: token);

      setState(() {
        reviewedCases = response.data['data'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      debugPrint('FinishedScreen error: $e');
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

    if (reviewedCases.isEmpty) {

      return const Center(
        child: Text(
          "No reviewed cases",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(

      padding: const EdgeInsets.all(16),

      itemCount: reviewedCases.length,

      itemBuilder: (context, index) {

        final caseData =
            reviewedCases[index];

        return Padding(

          padding:
              const EdgeInsets.only(
                  bottom: 12),

          child: FinishedCard(
            caseData: caseData,
          ),
        );
      },
    );
  }
}