import 'package:flutter/material.dart';
import 'package:skinner/screens/chat_screens.dart';
import 'package:skinner/services/auth_service.dart';

class ReviewCaseScreen extends StatefulWidget {
  final Map caseData;
  const ReviewCaseScreen({super.key, required this.caseData});

  @override
  State<ReviewCaseScreen> createState() => _ReviewCaseScreenState();
}

class _ReviewCaseScreenState extends State<ReviewCaseScreen> {
  final _diagnosisCtrl    = TextEditingController();
  final _prescriptionCtrl = TextEditingController();
  final _notesCtrl        = TextEditingController();
  bool _isSubmitting      = false;
  bool _showForm          = false; // toggle "view & Edit report" section

  @override
  void dispose() {
    _diagnosisCtrl.dispose();
    _prescriptionCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);
    try {
      await AuthService().reviewCase(
        token: adminToken!,
        appointmentId: widget.caseData['appointment_id'].toString(),
        diagnosis:     _diagnosisCtrl.text,
        prescription:  _prescriptionCtrl.text,
        notes:         _notesCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Case reviewed successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map d            = widget.caseData;
    final String name      = d['patient_name'] ?? 'Patient';
    final String age       = (d['age'] ?? d['patient_age'] ?? '--').toString();
    final String gender    = (d['gender'] ?? d['patient_gender'] ?? '--').toString();
    final String diagnosis = d['skin_disease_classification'] ??
                             d['ai_diagnosis'] ?? 'Unknown';
    final String imageUrl  = d['skin_image_upload'] ?? d['image_url'] ?? '';
    final double conf      = ((d['confidence'] ?? d['ai_confidence'] ?? 0.0) as num).toDouble();
    final String severity  = conf >= 0.85 ? 'HIGH' : conf >= 0.60 ? 'MEDIUM' : 'LOW';
    final String confLabel = '${(conf * 100).toStringAsFixed(0)}% Confidence';
    final String dateRaw   = (d['created_at'] ?? '').toString();
    final String dateLabel = dateRaw.length >= 10
        ? () {
            final p = dateRaw.substring(0, 10).split('-');
            return p.length == 3 ? '${p[1]}/${p[2]}/${p[0]}' : dateRaw;
          }()
        : dateRaw;

    final String chatId  = (d['chat_id'] ?? '').toString();
    final String chatTitle = 'Chat – $name';

    // severity colours
    final Color sevFg = severity == 'HIGH'
        ? const Color(0xFFEF4444)
        : severity == 'MEDIUM'
            ? const Color(0xFFD97706)
            : const Color(0xFF16A34A);
    final Color sevBg = severity == 'HIGH'
        ? const Color(0xFFFFEBEB)
        : severity == 'MEDIUM'
            ? const Color(0xFFFFF9E6)
            : const Color(0xFFE8F8EB);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF0F172A)),
        title: const Text(''),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: const Text('Back to List',
                  style: TextStyle(color: Color(0xFF374151), fontSize: 13)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ──────────────────────────────────────────
            Text(
              'Case Review: $name',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Submitted on $dateLabel',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),

            const SizedBox(height: 20),

            // ── White card ─────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Image
                  const Text('Patient Image',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280))),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            'http://187.127.227.63$imageUrl',
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, prog) =>
                                prog == null ? child : _placeholder(),
                            errorBuilder: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),

                  const SizedBox(height: 20),

                  // Patient Information
                  const Text('Patient Information',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280))),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          color: Color(0xFF0F172A), fontSize: 14, height: 1.7),
                      children: [
                        const TextSpan(
                            text: 'Age:\n',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: '$age\n'),
                        const TextSpan(
                            text: 'Gender:\n',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: '$gender\n'),
                        const TextSpan(
                            text: 'AI Analysis',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // AI Analysis box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diagnosis,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _badge('$severity Severity', sevBg, sevFg),
                            const SizedBox(width: 8),
                            _badge(confLabel, Colors.grey.shade100,
                                Colors.black87),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Preliminary warning
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 16, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'AI analysis is preliminary.\nPlease provide your professional assessment.',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF92400E),
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── view & Edit report ─────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () =>
                    setState(() => _showForm = !_showForm),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _showForm ? 'Hide Report Form' : 'view&Edit report',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151)),
                ),
              ),
            ),

            // ── Collapsible form ───────────────────────────────
            if (_showForm) ...[
              const SizedBox(height: 16),
              _formField('Diagnosis', _diagnosisCtrl, maxLines: 3),
              const SizedBox(height: 12),
              _formField('Prescription', _prescriptionCtrl, maxLines: 3),
              const SizedBox(height: 12),
              _formField('Notes', _notesCtrl, maxLines: 4),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Submit Review',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // ── Read chat ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: chatId.isNotEmpty
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              chatId: chatId,
                              title: chatTitle,
                              caseData: widget.caseData,
                            ),
                          ),
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Read chat',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        height: 220,
        color: const Color(0xFFEBE3D5),
        child: const Center(
          child: Icon(Icons.image_outlined, size: 52, color: Colors.brown),
        ),
      );

  Widget _badge(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
      );

  Widget _formField(String label, TextEditingController ctrl,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
