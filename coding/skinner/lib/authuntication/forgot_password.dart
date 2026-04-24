import 'package:flutter/material.dart';
import 'dart:async';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  // 0 = Forgot Password, 1 = Verify Code, 2 = Reset Password
  int _step = 0;

  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  // Timer
  int _timerSeconds = 554; // 9:14
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    _timerSeconds = 554;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timerSeconds <= 0) {
        t.cancel();
      } else {
        setState(() => _timerSeconds--);
      }
    });
  }

  String get _timerDisplay {
    final m = _timerSeconds ~/ 60;
    final s = _timerSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF9),
      body: SafeArea(
        child: Column(
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 40.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/photo.png',
                    width: 55,
                    height: 55,
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Skinner',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C67FF),
                        ),
                      ),
                      Text(
                        'Skin disease detection system',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF2C67FF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: _step == 0
                      ? _buildForgotPasswordStep()
                      : _step == 1
                      ? _buildVerifyCodeStep()
                      : _buildResetPasswordStep(),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  Widget _buildForgotPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back + Title
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Forgot Password',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          "Enter your email address and we'll send you a verification code to reset your password",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // Info box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF3FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.mail_outline, color: Color(0xFF2C67FF), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'A 6-digit verification code will be sent to your registered email address. The code will be valid for 10 minutes.',
                  style:
                  TextStyle(fontSize: 13, color: Color(0xFF2C67FF)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Email
        const Text('Email Address',
            style:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'name@example.com',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.mail_outline,
                color: Colors.white, size: 20),
            label: const Text('Send Verification Code',
                style: TextStyle(fontSize: 16, color: Colors.white)),
            onPressed: () {
              setState(() => _step = 1);
              _startTimer();
            },
          ),
        ),
        const SizedBox(height: 16),

        // Sign in link
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Remember your password?',
                  style: TextStyle(fontSize: 13)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Sign in here',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2C67FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildVerifyCodeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back + Title
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _step = 0),
              child: const Icon(Icons.arrow_back, size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Verify Code',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Enter the 6-digit verification code sent to ${_emailController.text.isEmpty ? 'your email' : _emailController.text}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // Timer box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF3FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined,
                  color: Color(0xFF2C67FF), size: 18),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Code expires in:',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF2C67FF))),
                  const SizedBox(height: 2),
                  Text(
                    _timerDisplay,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C67FF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // OTP fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            return SizedBox(
              width: 46,
              height: 56,
              child: TextField(
                controller: _otpControllers[i],
                focusNode: _otpFocusNodes[i],
                textAlign: TextAlign.center,
                maxLength: 1,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  if (val.isNotEmpty && i < 5) {
                    FocusScope.of(context)
                        .requestFocus(_otpFocusNodes[i + 1]);
                  } else if (val.isEmpty && i > 0) {
                    FocusScope.of(context)
                        .requestFocus(_otpFocusNodes[i - 1]);
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        // Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.shield_outlined,
                color: Colors.white, size: 20),
            label: const Text('Verify Code',
                style: TextStyle(fontSize: 16, color: Colors.white)),
            onPressed: () {
              _timer?.cancel();
              setState(() => _step = 2);
            },
          ),
        ),
        const SizedBox(height: 16),

        // Resend
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Didn't receive the code? ",
                  style: TextStyle(fontSize: 13)),
              GestureDetector(
                onTap: () {
                  for (final c in _otpControllers) {
                    c.clear();
                  }
                  _startTimer();
                },
                child: Row(
                  children: const [
                    Icon(Icons.refresh,
                        size: 14, color: Color(0xFF2C67FF)),
                    SizedBox(width: 2),
                    Text(
                      'Resend Code',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2C67FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildResetPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back + Title
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _step = 1),
              child: const Icon(Icons.arrow_back, size: 22),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.lock_outline,
                color: Color(0xFF00AA55), size: 24),
            const SizedBox(width: 8),
            const Text(
              'Reset Password',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Create a new strong password for ${_emailController.text.isEmpty ? 'your account' : _emailController.text}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 20),

        // Identity verified box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F8EE),
            borderRadius: BorderRadius.circular(10),
            border:
            Border.all(color: const Color(0xFF00CC66), width: 1),
          ),
          child: Row(
            children: const [
              Icon(Icons.check_circle_outline,
                  color: Color(0xFF00AA55), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your identity has been verified. Please create a new password.',
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF00AA55)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Requirements box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF3FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.shield_outlined,
                      color: Color(0xFF2C67FF), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Password Requirements:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C67FF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...[
                'At least 8 characters',
                'Uppercase and lowercase letters',
                'At least one number',
                r'At least one special character (!@#$%^&*)',
              ].map(
                    (req) => Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.circle_outlined,
                          size: 8, color: Color(0xFF2C67FF)),
                      const SizedBox(width: 8),
                      Text(req,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2C67FF))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // New Password
        const Text('New Password',
            style:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _newPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Enter new password',
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Confirm New Password
        const Text('Confirm New Password',
            style:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            hintText: 'Confirm new password',
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: () => setState(() =>
              _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.lock_outline,
                color: Colors.white, size: 20),
            label: const Text('Reset Password',
                style: TextStyle(fontSize: 16, color: Colors.white)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        const SizedBox(height: 16),

        // Return to login
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Changed your mind? ",
                  style: TextStyle(fontSize: 13)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Return to login',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2C67FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
