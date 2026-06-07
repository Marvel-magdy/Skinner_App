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
  bool _showForm          = false;

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
        token:         adminToken!,
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
    final theme    = Theme.of(context);
    final isDark   = theme.brightness == Brightness.dark;

    // ── adaptive colours ──────────────────────────────────────
    final Color scaffoldBg  = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);
    final Color appBarBg    = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color cardBg      = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color cardBorder  = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
    final Color labelGrey   = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final Color bodyText    = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A);
    final Color outlinedBtn = isDark ? const Color(0xFF475569) : const Color(0xFFD1D5DB);
    final Color outlinedTxt = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF374151);
    final Color aiBoxBg     = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFF0F4FF);
    final Color warnBoxBg   = isDark ? const Color(0xFF2D2000) : const Color(0xFFFFFBEB);
    final Color warnBorder  = isDark ? Colors.amber.shade800   : Colors.amber.shade200;
    final Color warnText    = isDark ? const Color(0xFFFCD34D) : const Color(0xFF92400E);
    final Color fieldFill   = isDark ? const Color(0xFF0F172A) : Colors.white;
    final Color fieldBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
    final Color backBtnColor = isDark ? Colors.white : const Color(0xFF0F172A);

    final Map    d          = widget.caseData;
    final String name       = d['patient_name'] ?? 'Patient';
    final String age        = (d['age'] ?? d['patient_age'] ?? '--').toString();
    final String gender     = (d['gender'] ?? d['patient_gender'] ?? '--').toString();
    final String diagnosis  = d['skin_disease_classification'] ??
                              d['ai_diagnosis'] ?? 'Unknown';
    final String imageUrl   = d['skin_image_upload'] ?? d['image_url'] ?? '';
    final double conf       = ((d['confidence'] ?? d['ai_confidence'] ?? 0.0) as num).toDouble();
    final String severity   = conf >= 0.85 ? 'HIGH' : conf >= 0.60 ? 'MEDIUM' : 'LOW';
    final String confLabel  = '${(conf * 100).toStringAsFixed(0)}% Confidence';
    final String dateRaw    = (d['created_at'] ?? '').toString();
    final String dateLabel  = dateRaw.length >= 10
        ? () {
            final p = dateRaw.substring(0, 10).split('-');
            return p.length == 3 ? '${p[1]}/${p[2]}/${p[0]}' : dateRaw;
          }()
        : dateRaw;
    final String chatId     = (d['chat_id'] ?? '').toString();
    final String chatTitle  = 'Chat – $name';

    // severity colours (bg stays pastel even in dark; fg stays vivid)
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
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        leading: BackButton(color: backBtnColor),
        title: const Text(''),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: outlinedBtn),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Text('Back to List',
                  style: TextStyle(color: outlinedTxt, fontSize: 13)),
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
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: bodyText),
            ),
            const SizedBox(height: 4),
            Text(
              'Submitted on $dateLabel',
              style: TextStyle(fontSize: 13, color: labelGrey),
            ),

            const SizedBox(height: 20),

            // ── Card ───────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Image
                  Text('Patient Image',
                      style: TextStyle(fontSize: 12, color: labelGrey)),
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
                  Text('Patient Information',
                      style: TextStyle(fontSize: 12, color: labelGrey)),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                          color: bodyText, fontSize: 14, height: 1.7),
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
                      color: aiBoxBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diagnosis,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: bodyText),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _badge('$severity Severity', sevBg, sevFg),
                            const SizedBox(width: 8),
                            _badge(
                              confLabel,
                              isDark
                                  ? const Color(0xFF334155)
                                  : Colors.grey.shade100,
                              isDark ? Colors.white70 : Colors.black87,
                            ),
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
                      color: warnBoxBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: warnBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 16, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI analysis is preliminary.\nPlease provide your professional assessment.',
                            style: TextStyle(
                                fontSize: 12, color: warnText, height: 1.4),
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
                onPressed: () => setState(() => _showForm = !_showForm),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: outlinedBtn),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _showForm ? 'Hide Report Form' : 'view&Edit report',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: outlinedTxt),
                ),
              ),
            ),

            // ── Collapsible form ───────────────────────────────
            if (_showForm) ...[
              const SizedBox(height: 16),
              _formField('Diagnosis',    _diagnosisCtrl,    maxLines: 3,
                  fill: fieldFill, border: fieldBorder, labelColor: bodyText),
              const SizedBox(height: 12),
              _formField('Prescription', _prescriptionCtrl, maxLines: 3,
                  fill: fieldFill, border: fieldBorder, labelColor: bodyText),
              const SizedBox(height: 12),
              _formField('Notes',        _notesCtrl,        maxLines: 4,
                  fill: fieldFill, border: fieldBorder, labelColor: bodyText),
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
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Submit Review',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // ── Continue chat ──────────────────────────────────
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
                  disabledBackgroundColor:
                      isDark ? const Color(0xFF334155) : Colors.grey.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Continue chat',
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
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
      );

  Widget _formField(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    required Color fill,
    required Color border,
    required Color labelColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: labelColor)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: TextStyle(color: labelColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: fill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF2C67FF), width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
