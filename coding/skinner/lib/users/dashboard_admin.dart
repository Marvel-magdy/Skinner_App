import 'package:flutter/material.dart';
import 'package:skinner/authuntication/signin.dart';
import 'dart:math';

class dashboard_admin extends StatefulWidget {
  const dashboard_admin({super.key});

  @override
  State<dashboard_admin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<dashboard_admin> {
  int _step = 0;
  int _selectedIndex = 0;

  final List<Map<String, String>> _doctors = [
    {
      'name': 'Dr. Robert Williams',
      'email': 'r.williams@hospital.com',
      'info': 'Verify information id',
      'specialization': 'Dermatology',
      'submitted': '12/18/2024',
      'phone': '+1 (555) 123-4567',
    },
    {
      'name': 'Dr. Robert Williams',
      'email': 'r.williams@hospital.com',
      'info': 'Verify information id',
      'specialization': 'Dermatology',
      'submitted': '12/18/2024',
      'phone': '+1 (555) 123-4567',
    },
    {
      'name': 'Dr. Lisa Anderson',
      'email': 'l.anderson@clinic.com',
      'info': 'Verify information id',
      'specialization': 'General Practice',
      'submitted': '12/17/2024',
      'phone': '+1 (555) 987-6543',
    },
    {
      'name': 'Dr. Lisa Anderson',
      'email': 'l.anderson@clinic.com',
      'info': 'Verify information id',
      'specialization': 'General Practice',
      'submitted': '12/17/2024',
      'phone': '+1 (555) 987-6543',
    },
  ];

  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _showDoneDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF3B5BFF),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CustomPaint(
                size: const Size(80, 80),
                painter: _BadgePainter(color: const Color(0xFF22C55E)),
                child: const SizedBox(
                  width: 80,
                  height: 80,
                  child: Icon(Icons.check, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Done !',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B5BFF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFailedDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF3B5BFF),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE5E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFFCC3300),
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Failed !',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCC3300),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF9),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.monitor_heart_outlined,
                      color: Color(0xFF3B5BFF),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Skinner',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Admin Portal',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () {Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => sign_in()),
                          (route) => false,
                    );},
                    icon: const Icon(
                      Icons.logout,
                      size: 16,
                      color: Colors.black87,
                    ),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.black87),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Doctor Verification badge
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF22C55E)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.people_outline,
                        size: 16,
                        color: Color(0xFF22C55E),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Doctor Verification (2)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(child: _step == 0 ? _buildListStep() : _buildReviewStep()),
          ],
        ),
      ),
    );
  }

  Widget _buildListStep() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _doctors.length,
      itemBuilder: (context, index) {
        final doc = _doctors[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    doc['name']!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.access_time, size: 12, color: Colors.orange),
                        SizedBox(width: 4),
                        Text(
                          'Pending',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                doc['email']!,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                doc['info']!,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                doc['specialization']!,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                'Submitted: ${doc['submitted']!}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => setState(() {
                    _selectedIndex = index;
                    _step = 1;
                  }),
                  child: const Text(
                    'Review Application',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewStep() {
    final doc = _doctors[_selectedIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verify Doctor: ${doc['name']!}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Submitted on',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        doc['submitted']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => _step = 0),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Back to List',
                    style: TextStyle(color: Colors.black87, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF3FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(
                    Icons.monitor_heart_outlined,
                    color: Color(0xFF3B5BFF),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please verify the medical credentials before approving this application. All information will be cross-checked with medical licensing databases.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF3B5BFF)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _detailLabel('Full Name'),
            _detailValue(doc['name']!),
            const SizedBox(height: 14),
            _detailLabel('Email'),
            _detailValue(doc['email']!),
            const SizedBox(height: 14),
            _detailLabel('Phone Number'),
            _detailValue(doc['phone']!),
            const SizedBox(height: 14),

            Row(
              children: [
                const Text(
                  'ID Doctor',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Verify',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _detailLabel('Specialization'),
            _detailValue(doc['specialization']!),
            const SizedBox(height: 14),
            _detailLabel('Submission Date'),
            _detailValue(doc['submitted']!),
            const SizedBox(height: 14),

            _detailLabel('Verification Notes'),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter verification notes and comments...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),

                    label: const Text(
                      'Approve & Activate Account',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    onPressed: _showDoneDialog,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),

                    label: const Text(
                      'Reject Application',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    onPressed: _showFailedDialog,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailLabel(String text) =>
      Text(text, style: const TextStyle(fontSize: 13, color: Colors.grey));

  Widget _detailValue(String text) => Text(
    text,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
  );
}

// Green badge/star shape painter for Done dialog
class _BadgePainter extends CustomPainter {
  final Color color;
  const _BadgePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cx = size.width / 2;
    final cy = size.height / 2;
    const points = 8;
    const outerR = 40.0;
    const innerR = 30.0;
    final path = Path();

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi / points) - pi / 2;
      final r = i.isEven ? outerR : innerR;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
