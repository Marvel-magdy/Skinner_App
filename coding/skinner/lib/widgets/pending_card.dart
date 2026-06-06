import 'package:flutter/material.dart';
import 'package:skinner/screens/chat_screens.dart';
import 'package:skinner/screens/doctor/review_case_screen.dart';

class PendingCard extends StatelessWidget {
  final Map caseData;
  const PendingCard({super.key, required this.caseData});

  // ── helpers ───────────────────────────────────────────────

  Color _severityColor(String label) {
    switch (label.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFFF6B6B);
      case 'MEDIUM':
        return const Color(0xFFFFD93D);
      default:
        return const Color(0xFF6BCB77); // LOW / unknown
    }
  }

  Color _severityBg(String label) {
    switch (label.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFFFEBEB);
      case 'MEDIUM':
        return const Color(0xFFFFF9E6);
      default:
        return const Color(0xFFE8F8EB);
    }
  }

  String _severityLabel(Map data) {
    final conf = (data['confidence'] ?? data['ai_confidence'] ?? 0.0);
    final double c = (conf is num) ? conf.toDouble() : 0.0;
    if (c >= 0.85) return 'HIGH';
    if (c >= 0.60) return 'MEDIUM';
    return 'LOW';
  }

  String _confidenceLabel(Map data) {
    final conf = (data['confidence'] ?? data['ai_confidence'] ?? 0.0);
    final double c = (conf is num) ? conf.toDouble() : 0.0;
    return '${(c * 100).toStringAsFixed(0)}% confidence';
  }

  String _dateLabel(Map data) {
    final raw = (data['created_at'] ?? data['appointment_date'] ?? '').toString();
    if (raw.length >= 10) {
      final parts = raw.substring(0, 10).split('-');
      if (parts.length == 3) return '${parts[1]}/${parts[2]}/${parts[0]}';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final String patientName = caseData['patient_name'] ?? 'Unknown';
    final String age         = (caseData['age'] ?? caseData['patient_age'] ?? '--').toString();
    final String gender      = (caseData['gender'] ?? caseData['patient_gender'] ?? '--').toString();
    final String diagnosis   = caseData['skin_disease_classification'] ?? caseData['ai_diagnosis'] ?? caseData['diagnosis'] ?? 'Unknown';
    final String imageUrl    = caseData['skin_image_upload'] ?? caseData['image_url'] ?? '';
    final String severity    = _severityLabel(caseData);
    final String confidence  = _confidenceLabel(caseData);
    final String date        = _dateLabel(caseData);
    final String chatId      = (caseData['chat_id'] ?? '').toString();
    final String doctorN     = (caseData['doctor_name'] ?? 'Patient Chat').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.07), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Skin image ──────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    'http://187.127.227.63$imageUrl',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, prog) =>
                        prog == null ? child : const _ImgPlaceholder(),
                    errorBuilder: (_, __, ___) => const _ImgPlaceholder(),
                  )
                : const _ImgPlaceholder(),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Name row ──────────────────────────────────
                Row(
                  children: [
                    Text(
                      patientName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    _pill('$age yrs, $gender',
                        isDark ? const Color(0xFF334155) : Colors.grey.shade100,
                        isDark ? Colors.white70 : Colors.black87),
                    const Spacer(),
                    _pill('pending', const Color(0xFFFFEDD5),
                        const Color(0xFFB45309)),
                  ],
                ),

                const SizedBox(height: 8),

                // ── AI Diagnosis ──────────────────────────────
                Text(
                  'AI Diagnosis: $diagnosis',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                ),

                const SizedBox(height: 12),

                // ── Severity + confidence + date ──────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _pill(severity, _severityBg(severity), _severityColor(severity)),
                    _pill(confidence,
                        isDark ? const Color(0xFF334155) : Colors.grey.shade100,
                        isDark ? Colors.white70 : Colors.black87),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 13, color: Color(0xFF6B7280)),
                        const SizedBox(width: 3),
                        Text(date,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Review Case button ────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ReviewCaseScreen(caseData: caseData),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF2C67FF) : const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.description_outlined, size: 18),
                    label: const Text(
                      'Review Case',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── Chat with Patient button with unread badge ─
                _ChatBadgeButton(
                  chatId: chatId,
                  patientName: doctorN,
                  unreadCount: (caseData['unread_count'] ?? 0) as int,
                  caseData: caseData,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
      );
}

class _ImgPlaceholder extends StatelessWidget {
  const _ImgPlaceholder();
  @override
  Widget build(BuildContext context) => Container(
        height: 180,
        color: const Color(0xFFEBE3D5),
        child: const Center(
          child: Icon(Icons.image_outlined, size: 48, color: Colors.brown),
        ),
      );
}

// ── Chat badge button ──────────────────────────────────────────────────────
class _ChatBadgeButton extends StatelessWidget {
  final String chatId;
  final String patientName;
  final int    unreadCount;
  final Map    caseData;

  const _ChatBadgeButton({
    required this.chatId,
    required this.patientName,
    required this.unreadCount,
    required this.caseData,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasChat = chatId.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Outlined button ──────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton(
            onPressed: hasChat
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          chatId: chatId,
                          title: patientName,
                          caseData: caseData,
                        ),
                      ),
                    )
                : null,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: hasChat
                    ? const Color(0xFF2563EB)
                    : Colors.grey.shade300,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              foregroundColor: hasChat
                  ? const Color(0xFF2563EB)
                  : Colors.grey,
            ),
            child: Text(
              'Chat with Patient',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: hasChat ? const Color(0xFF1E293B) : Colors.grey,
              ),
            ),
          ),
        ),

        // ── Red numbered badge ───────────────────────────────
        if (unreadCount > 0)
          Positioned(
            top: -8,
            right: -6,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 22,
                minHeight: 22,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
