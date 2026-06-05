import 'package:flutter/material.dart';

import 'package:skinner/authuntication/create_account.dart';
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

  final TextEditingController emailController =
  TextEditingController();
  /// Controllers (مهمين للـ API بعدين)

  final TextEditingController passwordController = TextEditingController();

  final AuthService authService = AuthService();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }



  /// Navigation حسب الـ Role
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
//>>>>>>> 731f4660a57c1a1b8f5aa9434e4d5858e63fa344
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
                        child: Image.asset('assets/Untitled-1-01 1.png', width: 80, height: 80, fit: BoxFit.cover)),

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
                  ],
                ),
              ),

              /// Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),

                child: Container(
                  padding: const EdgeInsets.all(24),

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

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      /// Title
                      const Text(
                        'Sign In',

                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'Enter your credentials to access your account',

                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),

                      const SizedBox(height: 24),

                      /// Role Dropdown
                      const Text(
                        'I am a',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),

                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),

                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: DropdownButton<String>(
                          value: _selectedRole,

                          isExpanded: true,

                          underline: const SizedBox(),

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
                      const Text('Email'),

                      const SizedBox(height: 8),

                      TextField(
                        controller: emailController,

                        decoration: InputDecoration(
                          hintText: 'name@example.com',

                          filled: true,

                          fillColor: const Color(0xFFF5F5F5),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),

                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// Password
                      const Text('Password'),

                      const SizedBox(height: 8),

                      TextField(
                        controller: passwordController,

                        obscureText: _obscurePassword,

                        decoration: InputDecoration(
                          filled: true,

                          fillColor: const Color(0xFFF5F5F5),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),

                            borderSide: BorderSide.none,
                          ),

                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),

                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

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
                              isLoading = true;
                            });

                            try {
                              final response = await authService.login(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                                role: getApiRole(),
                              );

                              final token = response.data["token"];
                              if (token != null) {
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setString('token', token);
                              }

                              print(response.data);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Login Success'),
                                ),
                              );

                              _navigateBasedOnRole();
                            } catch (e) {
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
                          const Text("Don't have an account? "),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,

                                MaterialPageRoute(builder: (_) => Register()),
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
                        // GestureDetector
                      ), // Center
                    ],
                  ), // Column
                ), // Container
              ), // Padding
            ],
          ), // Column
        ), // SingleChildScrollView
      ), // SafeArea
    );
  }
}