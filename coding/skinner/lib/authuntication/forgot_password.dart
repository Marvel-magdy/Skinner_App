import 'package:flutter/material.dart';
import 'dart:async';

import 'package:provider/provider.dart';
import 'package:skinner/theme/theme_provider.dart';
import 'package:skinner/services/auth_service.dart';

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
  final AuthService authService = AuthService();

  bool isLoading = false;

  String? _newPasswordError;
  String? _confirmPasswordError;

  int _timerSeconds = 554;
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

  bool _isPasswordValid(String password) {
    if (password.length < 8) return false;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial =
        RegExp(r'[!@#\$%^&*()_+={}\[\]|\\:;"<>,.?/~`-]').hasMatch(password) ||
            RegExp(r'[^\w\s]').hasMatch(password);
    return hasUppercase && hasLowercase && hasNumber && hasSpecial;
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Logo + theme toggle
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 40.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/Untitled-1-01 1.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
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
                  const Spacer(),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) => IconButton(
                      onPressed: themeProvider.toggleTheme,
                      icon: Icon(
                        themeProvider.isDark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        size: 22,
                        color: Colors.grey,
                      ),
                      tooltip:
                          themeProvider.isDark ? 'Light mode' : 'Dark mode',
                    ),
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
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: _step == 0
                      ? _buildForgotPasswordStep(isDark)
                      : _step == 1
                          ? _buildVerifyCodeStep(isDark)
                          : _buildResetPasswordStep(isDark),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  Color _labelColor(bool isDark) =>
      isDark ? const Color(0xFFE2E8F0) : Colors.black87;
  Color _hintColor(bool isDark) =>
      isDark ? const Color(0xFF94A3B8) : Colors.grey;
  Color _inputFill(bool isDark) =>
      isDark ? const Color(0xFF334155) : const Color(0xFFF5F5F5);
  Color _infoBg(bool isDark) =>
      isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEEF3FF);
  Color _infoText(bool isDark) =>
      isDark ? const Color(0xFF93C5FD) : const Color(0xFF2C67FF);

  InputDecoration _fieldDecoration({
    required bool isDark,
    String? hint,
    Widget? suffix,
    bool hasError = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _hintColor(isDark)),
      filled: true,
      fillColor: _inputFill(isDark),
      counterText: '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: hasError
            ? const BorderSide(color: Colors.red, width: 1)
            : BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: hasError
            ? const BorderSide(color: Colors.red, width: 1)
            : BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: hasError ? Colors.red : const Color(0xFF2C67FF),
          width: 1.5,
        ),
      ),
      suffixIcon: suffix,
    );
  }

  // ── Step 0: Forgot Password ───────────────────────────────────────────────

  Widget _buildForgotPasswordStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back, size: 22, color: _labelColor(isDark)),
            ),
            const SizedBox(width: 12),
            Text(
              'Forgot Password',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _labelColor(isDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "Enter your email address and we'll send you a verification code to reset your password",
          style: TextStyle(fontSize: 14, color: _hintColor(isDark)),
        ),
        const SizedBox(height: 24),

        // Info box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _infoBg(isDark),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.mail_outline, color: _infoText(isDark), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'A 6-digit verification code will be sent to your registered email address. The code will be valid for 10 minutes.',
                  style: TextStyle(fontSize: 13, color: _infoText(isDark)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text('Email Address',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _labelColor(isDark))),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: _labelColor(isDark)),
          decoration: _fieldDecoration(isDark: isDark, hint: 'name@example.com'),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.mail_outline, color: Colors.white, size: 20),
            label: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Send Verification Code',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
            onPressed: () async {
              setState(() => isLoading = true);
              try {
                await authService.forgotPassword(
                    email: _emailController.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Verification code sent successfully')));
                setState(() => _step = 1);
                _startTimer();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')));
              } finally {
                setState(() => isLoading = false);
              }
            },
          ),
        ),
        const SizedBox(height: 16),

        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Remember your password?',
                  style: TextStyle(fontSize: 13, color: _labelColor(isDark))),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  ' Sign in here',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2C67FF),
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 1: Verify Code ───────────────────────────────────────────────────

  Widget _buildVerifyCodeStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _step = 0),
              child: Icon(Icons.arrow_back, size: 22, color: _labelColor(isDark)),
            ),
            const SizedBox(width: 12),
            Text(
              'Verify Code',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _labelColor(isDark)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Enter the 6-digit verification code sent to ${_emailController.text.isEmpty ? 'your email' : _emailController.text}',
          style: TextStyle(fontSize: 14, color: _hintColor(isDark)),
        ),
        const SizedBox(height: 24),

        // Timer box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _infoBg(isDark),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, color: _infoText(isDark), size: 18),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Code expires in:',
                      style:
                          TextStyle(fontSize: 13, color: _infoText(isDark))),
                  const SizedBox(height: 2),
                  Text(
                    _timerDisplay,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _infoText(isDark)),
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
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _labelColor(isDark)),
                decoration: _fieldDecoration(isDark: isDark),
                onChanged: (val) {
                  if (val.isNotEmpty && i < 5) {
                    FocusScope.of(context).requestFocus(_otpFocusNodes[i + 1]);
                  } else if (val.isEmpty && i > 0) {
                    FocusScope.of(context).requestFocus(_otpFocusNodes[i - 1]);
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

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

        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Didn't receive the code? ",
                  style: TextStyle(fontSize: 13, color: _labelColor(isDark))),
              GestureDetector(
                onTap: () {
                  for (final c in _otpControllers) {
                    c.clear();
                  }
                  _startTimer();
                },
                child: Row(
                  children: const [
                    Icon(Icons.refresh, size: 14, color: Color(0xFF2C67FF)),
                    SizedBox(width: 2),
                    Text(
                      'Resend Code',
                      style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2C67FF),
                          fontWeight: FontWeight.w600),
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

  // ── Step 2: Reset Password ────────────────────────────────────────────────

  Widget _buildResetPasswordStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _step = 1),
              child: Icon(Icons.arrow_back, size: 22, color: _labelColor(isDark)),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.lock_outline,
                color: Color(0xFF00AA55), size: 24),
            const SizedBox(width: 8),
            Text(
              'Reset Password',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _labelColor(isDark)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Create a new strong password for ${_emailController.text.isEmpty ? 'your account' : _emailController.text}',
          style: TextStyle(fontSize: 14, color: _hintColor(isDark)),
        ),
        const SizedBox(height: 20),

        // Identity verified box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF052E16).withOpacity(0.6)
                : const Color(0xFFE8F8EE),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isDark
                    ? const Color(0xFF16A34A).withOpacity(0.5)
                    : const Color(0xFF00CC66),
                width: 1),
          ),
          child: Row(
            children: const [
              Icon(Icons.check_circle_outline,
                  color: Color(0xFF00AA55), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your identity has been verified. Please create a new password.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF00AA55)),
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
            color: _infoBg(isDark),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined,
                      color: _infoText(isDark), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Password Requirements:',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _infoText(isDark)),
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
                      Icon(Icons.circle_outlined,
                          size: 8, color: _infoText(isDark)),
                      const SizedBox(width: 8),
                      Text(req,
                          style: TextStyle(
                              fontSize: 12, color: _infoText(isDark))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // New Password
        Text('New Password',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _labelColor(isDark))),
        const SizedBox(height: 8),
        TextField(
          controller: _newPasswordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: _labelColor(isDark)),
          onChanged: (_) {
            if (_newPasswordError != null) {
              setState(() => _newPasswordError = null);
            }
          },
          decoration: _fieldDecoration(
            isDark: isDark,
            hint: 'Enter new password',
            hasError: _newPasswordError != null,
            suffix: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _hintColor(isDark),
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        if (_newPasswordError != null) ...[
          const SizedBox(height: 6),
          Text(_newPasswordError!,
              style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
        const SizedBox(height: 16),

        // Confirm New Password
        Text('Confirm New Password',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _labelColor(isDark))),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          style: TextStyle(color: _labelColor(isDark)),
          onChanged: (_) {
            if (_confirmPasswordError != null) {
              setState(() => _confirmPasswordError = null);
            }
          },
          decoration: _fieldDecoration(
            isDark: isDark,
            hint: 'Confirm new password',
            hasError: _confirmPasswordError != null,
            suffix: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _hintColor(isDark),
              ),
              onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
        ),
        if (_confirmPasswordError != null) ...[
          const SizedBox(height: 6),
          Text(_confirmPasswordError!,
              style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.lock_outline, color: Colors.white, size: 20),
            label: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Reset Password',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
            onPressed: () async {
              setState(() {
                _newPasswordError = null;
                _confirmPasswordError = null;
              });

              final password = _newPasswordController.text;
              final confirm = _confirmPasswordController.text;
              bool isValid = true;

              if (!_isPasswordValid(password)) {
                setState(() {
                  _newPasswordError =
                      'Password must be at least 8 characters, and contain uppercase, lowercase, numbers, and symbols';
                });
                isValid = false;
              }
              if (password != confirm) {
                setState(() {
                  _confirmPasswordError = 'Passwords do not match';
                });
                isValid = false;
              }
              if (!isValid) return;

              setState(() => isLoading = true);
              try {
                final otpCode =
                    _otpControllers.map((e) => e.text).join();
                await authService.resetPassword(
                  email: _emailController.text.trim(),
                  otp: otpCode,
                  newPassword: password.trim(),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Password reset successful')));
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reset failed: $e')));
              } finally {
                setState(() => isLoading = false);
              }
            },
          ),
        ),
        const SizedBox(height: 16),

        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Changed your mind? ",
                  style: TextStyle(
                      fontSize: 13, color: _labelColor(isDark))),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Return to login',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2C67FF),
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
