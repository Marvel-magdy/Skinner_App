import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skinner/theme/theme_provider.dart';
import 'package:skinner/authuntication/create_account.dart';

//import 'package:skinner/authuntication/register.dart';
import 'package:skinner/authuntication/forgot_password.dart';

import 'package:skinner/users/dashboard_admin.dart';
import 'package:skinner/users/dashboard_doctor.dart';
import 'package:skinner/users/dashboard_user.dart';
import 'package:skinner/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  /// Role
  String _selectedRole = 'Patient';
  final List<String> _roles = ['Patient', 'Doctor', 'Administrator'];

  /// Password visibility
  bool _obscurePassword = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService authService = AuthService();

  bool isLoading = false;

  /// رسالة الخطأ عند إدخال بيانات خاطئة
  String? _errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Navigation حسب الـ Role
  void _navigateBasedOnRole() {
    if (_selectedRole == 'Administrator') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const dashboard_admin()),
            (route) => false,
      );
    } else if (_selectedRole == 'Doctor') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DoctorPortalScreen()),
            (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardUser()),
            (route) => false,
      );
    }
  }

  /// تحويل الـ Role للـ API
  String getApiRole() {
    switch (_selectedRole) {
      case 'Doctor':
        return 'doctor';

      case 'Administrator':
        return 'admin';

      default:
        return 'patient';
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final inputFill = isDark ? const Color(0xFF334155) : const Color(0xFFF5F5F5);
    final labelColor = isDark ? const Color(0xFFE2E8F0) : Colors.black87;
    final hintColor = isDark ? const Color(0xFF94A3B8) : Colors.grey;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// Logo
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: Row(
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
                        tooltip: themeProvider.isDark ? 'Light mode' : 'Dark mode',
                      ),
                    ),
                  ],
                ),
              ),

              /// Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Title
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: labelColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Enter your credentials to access your account',
                        style: TextStyle(fontSize: 14, color: hintColor),
                      ),
                      const SizedBox(height: 24),

                      /// Role Dropdown
                      Text(
                        'I am a',
                        style: TextStyle(fontWeight: FontWeight.w500, color: labelColor),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: inputFill,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: cardColor,
                          style: TextStyle(color: labelColor, fontSize: 14),
                          iconEnabledColor: hintColor,
                          items: _roles.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Email
                      Text('Email', style: TextStyle(color: labelColor)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        style: TextStyle(color: labelColor),
                        onChanged: (value) {
                          if (_errorMessage != null) {
                            setState(() {
                              _errorMessage = null;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'name@example.com',
                          hintStyle: TextStyle(color: hintColor),
                          filled: true,
                          fillColor: inputFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: _errorMessage != null
                                ? const BorderSide(color: Colors.red, width: 1)
                                : BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: _errorMessage != null
                                ? const BorderSide(color: Colors.red, width: 1)
                                : BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: _errorMessage != null
                                  ? Colors.red
                                  : const Color(0xFF2C67FF),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Password
                      Text('Password', style: TextStyle(color: labelColor)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: labelColor),
                        onChanged: (value) {
                          if (_errorMessage != null) {
                            setState(() {
                              _errorMessage = null;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: inputFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: _errorMessage != null
                                ? const BorderSide(color: Colors.red, width: 1)
                                : BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: _errorMessage != null
                                ? const BorderSide(color: Colors.red, width: 1)
                                : BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: _errorMessage != null
                                  ? Colors.red
                                  : const Color(0xFF2C67FF),
                              width: 1.5,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: hintColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      /// رسالة الخطأ الحمراء أسفل حقل الباسورد (تظهر فقط عند حدوث خطأ)
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      /// Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            setState(() {
                              _errorMessage = null; // إعادة ضبط حالة الخطأ عند محاولة تسجيل دخول جديدة
                              isLoading = true;
                            });

                            try {
                              final response = await authService.login(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                                role: getApiRole(),
                              );

                              // Persist session so the app survives restarts
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setString('token', adminToken ?? '');
                              await prefs.setString('role', _selectedRole);
                              // Also save the API-style role (lowercase) for chat message ownership
                              await prefs.setString('api_role', getApiRole());

                              print(response.data);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Login Success'),
                                ),
                              );

                              _navigateBasedOnRole();
                            } catch (e) {
                              setState(() {
                                _errorMessage = 'Incorrect email or password';
                                emailController.clear();
                                passwordController.clear();
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Login Failed: $e'),
                                ),
                              );
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          child: isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(color: labelColor),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Register(),
                                ),
                              );
                            },
                            child: const Text(
                              'Register here',
                              style: TextStyle(
                                color: Color(0xFF2C67FF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// Forgot Password
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ForgotPassword(),
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(color: Color(0xFF2C67FF)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
