import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skinner/authuntication/signin.dart';
import 'package:skinner/services/auth_service.dart';
import 'package:skinner/users/dashboard_admin.dart';
import 'package:skinner/users/dashboard_doctor.dart';
import 'package:skinner/users/dashboard_user.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();

    Future.delayed(const Duration(seconds: 10), () async {
      if (!mounted) return;

      // Check for a saved session
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('token') ?? '';
      final savedRole  = prefs.getString('role')  ?? '';

      Widget destination;
      if (savedToken.isNotEmpty) {
        // Restore the in-memory token so all API calls work immediately
        adminToken = savedToken;

        if (savedRole == 'Administrator') {
          destination = const dashboard_admin();
        } else if (savedRole == 'Doctor') {
          destination = const DoctorPortalScreen();
        } else {
          destination = const DashboardUser();
        }
      } else {
        destination = const SignIn();
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F6),
      body: Stack(
        children: [
          // ── Top-left large blue blob ──
          Positioned(
            top: -60,
            left: -60,
            child: _Blob(
              width: size.width * 0.65,
              height: size.width * 0.65,
              color: const Color(0xFFB8CADF).withOpacity(0.55),
            ),
          ),

          // ── Top-right smaller blob ──
          Positioned(
            top: size.height * 0.04,
            right: -30,
            child: _Blob(
              width: size.width * 0.38,
              height: size.width * 0.38,
              color: const Color(0xFFB8CADF).withOpacity(0.40),
            ),
          ),

          // ── Mid-left tiny dot ──
          Positioned(
            top: size.height * 0.38,
            left: size.width * 0.06,
            child: _Dot(radius: 7, color: const Color(0xFFB8CADF)),
          ),

          // ── Mid-right small blob ──
          Positioned(
            top: size.height * 0.52,
            right: -20,
            child: _Blob(
              width: size.width * 0.30,
              height: size.width * 0.30,
              color: const Color(0xFFB8CADF).withOpacity(0.45),
            ),
          ),

          // ── Mid-right dark dot ──
          Positioned(
            top: size.height * 0.60,
            right: size.width * 0.12,
            child: _Dot(radius: 14, color: const Color(0xFF1B2A4A)),
          ),

          // ── Bottom-right small light dot ──
          Positioned(
            bottom: size.height * 0.22,
            right: size.width * 0.08,
            child: _Dot(radius: 6, color: const Color(0xFFB8CADF)),
          ),

          // ── Bottom dark navy wave ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _WaveClipper(),
              child: Container(
                height: size.height * 0.26,
                color: const Color(0xFF1B2A4A),
              ),
            ),
          ),

          // ── Centered logo + text ──
          FadeTransition(
            opacity: _fadeAnim,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo image
                  Image.asset(
                    'assets/Gemini_Generated_Image_10710u10710u1071.png',
                    width: size.width * 0.42,
                  ),
                  const SizedBox(height: 18),
                  // "skinner" wordmark
                  const Text(
                    'skinner',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: 1.5,
                      fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Subtitle
                  const Text(
                    'AI-POWERED HEALTHCARE PLATFORM',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Organic blob shape ─────────────────────────────────────────────────────
class _Blob extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _Blob({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _BlobClipper(),
      child: Container(width: width, height: height, color: color),
    );
  }
}

class _BlobClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.cubicTo(
      size.width * 0.85, 0,
      size.width, size.height * 0.30,
      size.width * 0.95, size.height * 0.55,
    );
    path.cubicTo(
      size.width * 0.90, size.height * 0.85,
      size.width * 0.65, size.height,
      size.width * 0.40, size.height * 0.95,
    );
    path.cubicTo(
      size.width * 0.15, size.height * 0.90,
      0, size.height * 0.70,
      0, size.height * 0.45,
    );
    path.cubicTo(
      0, size.height * 0.20,
      size.width * 0.15, 0,
      size.width * 0.5, 0,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_BlobClipper oldClipper) => false;
}

// ── Simple filled circle ───────────────────────────────────────────────────
class _Dot extends StatelessWidget {
  final double radius;
  final Color color;

  const _Dot({required this.radius, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ── Wave clipper for the bottom navy section ───────────────────────────────
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.38);
    path.cubicTo(
      size.width * 0.25, 0,
      size.width * 0.55, size.height * 0.15,
      size.width, size.height * 0.10,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => false;
}
