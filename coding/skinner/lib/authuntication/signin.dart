import 'package:flutter/material.dart';
import 'package:skinner/l10n/app_translations.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final fieldFill = isDark ? const Color(0xFF334155) : const Color(0xFFF5F5F5);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// Logo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset('assets/Untitled-1-01 1.png',
                          width: 80, height: 80, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppL10n.of(context, AppStrings.appName),
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C67FF))),
                        Text(AppL10n.of(context, AppStrings.skinDetectionSys),
                            style: const TextStyle(fontSize: 14, color: Color(0xFF2C67FF))),
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
                      Text(AppL10n.of(context, AppStrings.signIn),
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color)),
                      const SizedBox(height: 6),
                      Text(AppL10n.of(context, AppStrings.signInSubtitle),
                          style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 24),

                      /// Role Dropdown
                      Text(AppL10n.of(context, AppStrings.iAmA),
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: theme.textTheme.bodyLarge?.color)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: fieldFill,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: cardColor,
                          style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 14),
                          items: _roles.map((role) {
                            String label;
                            switch (role) {
                              case 'Doctor': label = AppL10n.of(context, AppStrings.doctor); break;
                              case 'Administrator': label = AppL10n.of(context, AppStrings.administrator); break;
                              default: label = AppL10n.of(context, AppStrings.patient);
                            }
                            return DropdownMenuItem(value: role, child: Text(label));
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedRole = value!),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Email
                      Text(AppL10n.of(context, AppStrings.email),
                          style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                        decoration: InputDecoration(
                          hintText: 'name@example.com',
                          filled: true,
                          fillColor: fieldFill,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Password
                      Text(AppL10n.of(context, AppStrings.password),
                          style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: fieldFill,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none),
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
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDark ? const Color(0xFF2C67FF) : Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            setState(() => isLoading = true);
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppL10n.of(context, AppStrings.loginSuccess))));
                              _navigateBasedOnRole();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${AppL10n.of(context, AppStrings.loginFailed)}: $e')));
                            } finally {
                              setState(() => isLoading = false);
                            }
                          },
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(AppL10n.of(context, AppStrings.signIn),
                                  style: const TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Text(AppL10n.of(context, AppStrings.noAccount),
                              style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context, MaterialPageRoute(builder: (_) => Register())),
                            child: Text(AppL10n.of(context, AppStrings.registerHere),
                                style: const TextStyle(
                                    color: Color(0xFF2C67FF),
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => ForgotPassword())),
                          child: Text(AppL10n.of(context, AppStrings.forgotPassword),
                              style: const TextStyle(color: Color(0xFF2C67FF))),
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