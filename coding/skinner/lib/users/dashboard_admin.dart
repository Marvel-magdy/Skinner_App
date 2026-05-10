import 'package:flutter/material.dart';
import 'package:skinner/authuntication/signin.dart';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class dashboard_admin extends StatefulWidget {
  const dashboard_admin({super.key});

  @override
 State<dashboard_admin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<dashboard_admin> {

  int _step = 0;
  int _selectedIndex = 0;

  bool isLoading = true;

  List<dynamic> _doctors = [];

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://187.127.227.63',
    ),
  );

  final TextEditingController _notesController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    getPendingDoctors();
  }

  Future<void> getPendingDoctors() async {

    try {

      SharedPreferences prefs =
      await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      Response response = await dio.get(

        '/api/admin/pending-doctors',

        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      setState(() {

        _doctors = response.data['doctors'];
        isLoading = false;

      });

    } catch (e) {

      print(e);

      setState(() {
        isLoading = false;
      });

    }
  }

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 28,
            horizontal: 24,
          ),
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
                painter: _BadgePainter(
                  color: const Color(0xFF22C55E),
                ),
                child: const SizedBox(
                  width: 80,
                  height: 80,
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 28,
            horizontal: 24,
          ),
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

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),

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
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

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
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  OutlinedButton.icon(

                    onPressed: () {

                      Navigator.of(context)
                          .pushAndRemoveUntil(

                        MaterialPageRoute(
                          builder: (_) => SignIn(),
                        ),

                            (route) => false,
                      );
                    },

                    icon: const Icon(
                      Icons.logout,
                      size: 16,
                      color: Colors.black87,
                    ),

                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),

                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.black26,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(8),
                      ),

                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                bottom: 12,
              ),

              child: Align(

                alignment: Alignment.centerLeft,

                child: Container(

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),

                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF22C55E),
                    ),

                    borderRadius:
                    BorderRadius.circular(20),
                  ),

                  child: Row(

                    mainAxisSize: MainAxisSize.min,

                    children: [

                      const Icon(
                        Icons.people_outline,
                        size: 16,
                        color: Color(0xFF22C55E),
                      ),

                      const SizedBox(width: 6),

                      Text(
                        'Doctor Verification (${_doctors.length})',

                        style: const TextStyle(
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

            Expanded(
              child: _step == 0
                  ? _buildListStep()
                  : _buildReviewStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListStep() {

    if (isLoading) {

      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),

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

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              Row(

                children: [

                  Text(
                    doc['name'] ?? '',

                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(

                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),

                    decoration: BoxDecoration(
                      border:
                      Border.all(color: Colors.orange),

                      borderRadius:
                      BorderRadius.circular(20),
                    ),

                    child: Row(

                      mainAxisSize: MainAxisSize.min,

                      children: const [

                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.orange,
                        ),

                        SizedBox(width: 4),

                        Text(
                          'Pending',

                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                doc['email'] ?? '',

                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                doc['specialization'] ?? '',

                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 2),

              const Text(
                'Pending Doctor',

                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(

                width: double.infinity,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(10),
                    ),

                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                  ),

                  onPressed: () {

                    setState(() {

                      _selectedIndex = index;
                      _step = 1;

                    });
                  },

                  child: const Text(
                    'Review Application',

                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
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

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),

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

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Text(
              doc['name'] ?? '',

              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              doc['email'] ?? '',
            ),

            const SizedBox(height: 10),

            Text(
              doc['phone'] ?? '',
            ),

            const SizedBox(height: 10),

            Text(
              doc['specialization'] ?? '',
            ),

            const SizedBox(height: 20),

            Row(

              children: [

                Expanded(

                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF22C55E),
                    ),

                    onPressed: _showDoneDialog,

                    child: const Text(
                      'Approve',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(

                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFFEF4444),
                    ),

                    onPressed: _showFailedDialog,

                    child: const Text(
                      'Reject',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgePainter extends CustomPainter {

  final Color color;

  const _BadgePainter({
    required this.color,
  });

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
  bool shouldRepaint(
      covariant CustomPainter oldDelegate) => false;
}