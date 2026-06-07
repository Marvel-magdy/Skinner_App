
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skinner/authuntication/signin.dart';
import 'package:skinner/theme/theme_provider.dart';
import 'dart:io';
import 'package:skinner/services/auth_service.dart';

import '../screens/onboarding_screen.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String _selectedRole = 'Doctor';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showQRScanner = false;
  bool _photoCaptured = false;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  final AuthService authService = AuthService();

  bool isLoading = false;
  bool _cameraInitialized = false;

  // تخزين الصورة الملتقطة
  XFile? _capturedImage;
  final TextEditingController _scanIdController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController clinicAddressController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController inviteCodeController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();

  String? selectedGender;
  String? selectedSpecialization;
  String? selectedAddress;

  // متغيرات نصوص الخطأ لكل حقل
  String? nameError;
  String? emailError;
  String? phoneError;
  String? ageError;
  String? genderError;
  String? nationalIdError;
  String? passwordError;
  String? confirmPasswordError;
  String? experienceError;
  String? inviteCodeError;
  String? idCardError;
  String? addressError;
  String? specializationError;
  String? clinicAddressError;

  final List<String> _roles = ['Patient', 'Doctor', 'Admin'];

  Map<String, dynamic>? _parseNationalId(String id) {
    if (id.length != 14) return null;
    final firstDigit = id[0];
    if (firstDigit != '2' && firstDigit != '3') return null;

    final yearStr = id.substring(1, 3);
    final monthStr = id.substring(3, 5);
    final dayStr = id.substring(5, 7);

    final century = firstDigit == '2' ? 1900 : 2000;
    final birthYear = century + int.parse(yearStr);
    final birthMonth = int.parse(monthStr);
    final birthDay = int.parse(dayStr);

    try {
      final birthDate = DateTime(birthYear, birthMonth, birthDay);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }

      // الرقم الـ 13 يحدد الجنس (فردي = ولد، زوجي = بنت)
      final genderDigit = int.parse(id[12]);
      final gender = genderDigit % 2 != 0 ? 'male' : 'female';

      return {
        'age': age,
        'gender': gender,
      };
    } catch (e) {
      return null;
    }
  }

  // التحقق من قوة كلمة المرور (أحرف + أرقام + رموز)
  bool _isPasswordValid(String password) {
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#\$&*~_=-]').hasMatch(password) || RegExp(r'[^\w\s]').hasMatch(password);
    return hasLetter && hasNumber && hasSpecial;
  }

  // التحقق من صحة المدخلات بالكامل
  bool _validateForm() {
    setState(() {
      nameError = null;
      emailError = null;
      phoneError = null;
      ageError = null;
      genderError = null;
      nationalIdError = null;
      passwordError = null;
      confirmPasswordError = null;
      experienceError = null;
      inviteCodeError = null;
      idCardError = null;
      addressError = null;
      specializationError = null;
      clinicAddressError = null;
    });

    bool isValid = true;

    // 1. التحقق من الرقم القومي
    final nid = nationalIdController.text.trim();

    if (nid.isEmpty) {
      setState(() => nationalIdError = "National ID is required");
      isValid = false;
    }
    else if (nid.length != 14) {
      setState(() => nationalIdError = "National ID must be exactly 14 digits");
      isValid = false;
    }
    else if (_selectedRole == 'Doctor') {

      final parsed = _parseNationalId(nid);

      if (parsed == null) {
        setState(() =>
        nationalIdError = "Invalid National ID format");
        isValid = false;
      } else {

        final calculatedAge = parsed['age'] as int;

        if (_selectedRole == 'Doctor' && calculatedAge < 23) {
          setState(() {
            ageError = "Doctor must be 23 years or older";
          });
          isValid = false;
        }  }
    }

    // 2. التحقق من الاسم
    if (nameController.text.trim().isEmpty) {
      setState(() => nameError = "Full name is required");
      isValid = false;
    }

    // 3. التحقق من البريد الإلكتروني
    final email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() => emailError = "Email is required");
      isValid = false;
    } else if (!email.toLowerCase().endsWith("@gmail.com")) {
      setState(() => emailError = "Email must end with @gmail.com");
      isValid = false;
    }

    // 4. التحقق من رقم الهاتف
    if (phoneController.text.trim().isEmpty) {
      setState(() => phoneError = "Phone number is required");
      isValid = false;
    }

    // 5. التحقق من العمر
    final ageStr = ageController.text.trim();
    if (ageStr.isEmpty) {
      setState(() => ageError = "Age is required");
      isValid = false;
    } else {
      final age = int.tryParse(ageStr);

      if (age == null) {
        setState(() => ageError = "Age must be a valid number");
        isValid = false;
      }
      else if (_selectedRole == 'Doctor' && age < 23) {
        setState(() {
          ageError = "Doctor must be 23 years or older";
        });
        isValid = false;
      }
    }

    // 6. التحقق من النوع
    if (selectedGender == null) {
      setState(() => genderError = "Gender is required");
      isValid = false;
    }

    // 7. التحقق من كلمة المرور
    final password = passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => passwordError = "Password is required");
      isValid = false;
    } else if (!_isPasswordValid(password)) {
      setState(() => passwordError = "Password must contain letters, numbers, and symbols");
      isValid = false;
    }

    // 8. تأكيد كلمة المرور
    final confirmPassword = confirmPasswordController.text.trim();
    if (confirmPassword != password) {
      setState(() => confirmPasswordError = "Passwords do not match");
      isValid = false;
    }

    // شروط مخصصة للطبيب
    if (_selectedRole == 'Doctor') {
      if (_capturedImage == null) {
        setState(() => idCardError = "Please scan/upload your ID image");
        isValid = false;
      }
      if (selectedSpecialization == null) {
        setState(() => specializationError = "Specialization is required");
        isValid = false;
      }
      if (selectedAddress == null) {
        setState(() => clinicAddressError = "Clinic address is required");
        isValid = false;
      }
      if (experienceController.text.trim().isEmpty) {
        setState(() => experienceError = "Years of experience is required");
        isValid = false;
      }
    }
    // شروط مخصصة للمشرف
    else if (_selectedRole == 'Admin') {
      if (inviteCodeController.text.trim().isEmpty) {
        setState(() => inviteCodeError = "Admin invite code is required");
        isValid = false;
      }
    }
    // شروط مخصصة للمريض
    else if (_selectedRole == 'Patient') {
      if (addressController.text.trim().isEmpty) {
        setState(() => addressError = "Address is required");
        isValid = false;
      }
    }

    return isValid;
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
      );
      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _cameraInitialized = true);
      }
    }
  }

  Future<void> _openCamera() async {
    setState(() {
      _showQRScanner = true;
      _photoCaptured = false;
      _cameraInitialized = false;
      _capturedImage = null;
    });
    await _initCamera();
  }

  Future<void> _capturePhoto() async {
    if (!_photoCaptured) {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        final XFile image = await _cameraController!.takePicture();
        setState(() {
          _capturedImage = image;
          _photoCaptured = true;
          idCardError = null; // إزالة الخطأ بمجرد التقاط الصورة
        });
      }
    } else {
      if (_capturedImage != null) {
        setState(() {
          _scanIdController.text = _capturedImage!.name;
        });
      }
      _closeCamera();
    }
  }

  void _closeCamera() {
    _cameraController?.dispose();
    _cameraController = null;
    setState(() {
      _showQRScanner = false;
      _photoCaptured = false;
      _cameraInitialized = false;
    });
  }

  @override
  void initState() {
    super.initState();

    // مراقبة كتابة الرقم القومي وتحديد السن والنوع فورا عند بلوغ 14 رقما
    nationalIdController.addListener(() {
      final text = nationalIdController.text.trim();
      if (_selectedRole == 'Doctor' && text.length == 14) {
        final parsed = _parseNationalId(text);
        if (parsed != null) {
          final calculatedAge = parsed['age'] as int;
          setState(() {
            selectedGender = parsed['gender'];
            ageController.text = calculatedAge.toString();

            // Clear validation errors since ID is now valid
            nationalIdError = null;
            ageError = null;
            genderError = null;
          });
        } else {
          // If parsing fails for a full 14-digit ID
          setState(() {
            nationalIdError = "Invalid National ID format or birth date";
          });
        }
      } else {
        // Clear errors and auto-filled values when length is not 14, without showing error messages while typing
        setState(() {
          nationalIdError = null;
          if (text.isEmpty) {
            ageController.clear();
            selectedGender = null;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _scanIdController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    experienceController.dispose();
    specializationController.dispose();
    clinicAddressController.dispose();
    ageController.dispose();
    addressController.dispose();
    inviteCodeController.dispose();
    nationalIdController.dispose();
    super.dispose();
  }

  Widget _buildLabel(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xFFE2E8F0) : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? hintText,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputFill = isDark ? const Color(0xFF334155) : const Color(0xFFF5F5F5);
    final labelColor = isDark ? const Color(0xFFE2E8F0) : Colors.black87;
    final hintColor = isDark ? const Color(0xFF94A3B8) : Colors.grey;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: TextStyle(color: labelColor),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: hintColor),
            filled: true,
            fillColor: inputFill,
            counterText: "", // Hide character counter
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: errorText != null
                  ? const BorderSide(color: Colors.red, width: 1)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: errorText != null
                  ? const BorderSide(color: Colors.red, width: 1)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : const Color(0xFF2C67FF),
                width: 1.5,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String? errorText,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputFill = isDark ? const Color(0xFF334155) : const Color(0xFFF5F5F5);
    final labelColor = isDark ? const Color(0xFFE2E8F0) : Colors.black87;
    final hintColor = isDark ? const Color(0xFF94A3B8) : Colors.grey;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(color: labelColor),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(color: hintColor),
            filled: true,
            fillColor: inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: errorText != null
                  ? const BorderSide(color: Colors.red, width: 1)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: errorText != null
                  ? const BorderSide(color: Colors.red, width: 1)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : const Color(0xFF2C67FF),
                width: 1.5,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
                color: hintColor,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final inputFill = isDark ? const Color(0xFF334155) : const Color(0xFFF5F5F5);
    final labelColor = isDark ? const Color(0xFFE2E8F0) : Colors.black87;
    final hintColor = isDark ? const Color(0xFF94A3B8) : Colors.grey;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Logo and title
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
                            tooltip: themeProvider.isDark ? 'Light mode' : 'Dark mode',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // White card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
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
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create an Account',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: labelColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Register as a patient, healthcare provider, or admin',
                            style: TextStyle(fontSize: 14, color: hintColor),
                          ),
                          const SizedBox(height: 20),

                          // Role toggle
                          Container(
                            decoration: BoxDecoration(
                              color: inputFill,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: _roles.map((role) {
                                final isSelected = _selectedRole == role;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedRole = role),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? cardColor
                                            : Colors.transparent,
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        boxShadow: isSelected
                                            ? [
                                          BoxShadow(
                                            color: Colors.black
                                                .withOpacity(0.08),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                            : [],
                                      ),
                                      child: Text(
                                        role,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? labelColor
                                              : hintColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Admin warning box
                          if (_selectedRole == 'Admin') ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFFFFCC02), width: 1),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.shield_outlined,
                                      color: Color(0xFFFFAA00), size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: RichText(
                                      text: const TextSpan(
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87),
                                        children: [
                                          TextSpan(
                                            text:
                                            'Administrator Registration: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text:
                                            'This account type has elevated system privileges. You will need an authorization code from your system administrator.',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Scan ID (Doctor only)
                          if (_selectedRole == 'Doctor') ...[
                            _buildLabel('Scan ID'),
                            if (_capturedImage != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFF00CC44),
                                      width: 1.5),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.file(
                                        File(_capturedImage!.path),
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'ID Photo Captured',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF00CC44),
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            _capturedImage!.name,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.camera_alt_outlined,
                                          color: Colors.grey, size: 20),
                                      onPressed: _openCamera,
                                      tooltip: 'Retake',
                                    ),
                                  ],
                                ),
                              )
                            else ...[
                              TextField(
                                controller: _scanIdController,
                                readOnly: true,
                                style: TextStyle(color: labelColor),
                                decoration: InputDecoration(
                                  hintText: 'Take a photo of your ID',
                                  hintStyle: TextStyle(color: hintColor),
                                  filled: true,
                                  fillColor: inputFill,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: idCardError != null
                                        ? const BorderSide(color: Colors.red, width: 1)
                                        : BorderSide.none,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.camera_alt_outlined,
                                        color: hintColor),
                                    onPressed: _openCamera,
                                  ),
                                ),
                              ),
                              if (idCardError != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  idCardError!,
                                  style: const TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              ],
                            ],
                            const SizedBox(height: 16),
                          ],

                          // National ID (للجميع)
                          _buildLabel('National ID'),
                          _buildTextField(
                            controller: nationalIdController,
                            hintText: '14-digit Egyptian National ID',
                            errorText: nationalIdError,
                            keyboardType: TextInputType.number,
                            maxLength: 14,
                          ),
                          const SizedBox(height: 16),

                          // Full Name
                          _buildLabel('Full Name'),
                          _buildTextField(
                            controller: nameController,
                            errorText: nameError,
                            hintText: _selectedRole == 'Patient'
                                ? 'John Doe'
                                : 'Dr. Jane Smith',
                          ),
                          const SizedBox(height: 16),

                          // Email
                          _buildLabel('Email'),
                          _buildTextField(
                            controller: emailController,
                            errorText: emailError,
                            hintText: _selectedRole == 'Patient'
                                ? 'name@example.com'
                                : 'doctor@hospital.com',
                          ),
                          const SizedBox(height: 16),

                          // Phone
                          _buildLabel('Phone Number'),
                          _buildTextField(
                            controller: phoneController,
                            errorText: phoneError,
                            hintText: '01XXXXXXXXX',
                            keyboardType: TextInputType.phone,
                            maxLength: 11,
                          ),
                          const SizedBox(height: 16),

                          // Age (يملأ تلقائياً من الرقم القومي)
                          _buildLabel('Age'),
                          _buildTextField(
                            controller: ageController,
                            errorText: ageError,
                            keyboardType: TextInputType.number,
                            hintText: _selectedRole == 'Patient' ? '25' : '35',
                          ),
                          const SizedBox(height: 16),

                          // Gender (يملأ تلقائياً من الرقم القومي)
                          _buildLabel('Gender'),
                          Container(
                            decoration: BoxDecoration(
                              color: inputFill,
                              borderRadius: BorderRadius.circular(10),
                              border: genderError != null
                                  ? Border.all(color: Colors.red, width: 1)
                                  : null,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: DropdownButton<String>(
                              value: selectedGender,
                              hint: Text('Select gender', style: TextStyle(color: hintColor)),
                              isExpanded: true,
                              underline: const SizedBox(),
                              dropdownColor: cardColor,
                              style: TextStyle(color: labelColor, fontSize: 14),
                              iconEnabledColor: hintColor,
                              items: const [
                                DropdownMenuItem(
                                  value: 'male',
                                  child: Text('Male'),
                                ),
                                DropdownMenuItem(
                                  value: 'female',
                                  child: Text('Female'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value;
                                  genderError = null;
                                });
                              },
                            ),
                          ),
                          if (genderError != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              genderError!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // Doctor extra fields
                          if (_selectedRole == 'Doctor') ...[
                            _buildLabel('Clinic Address'),
                            Container(
                              decoration: BoxDecoration(
                                color: inputFill,
                                borderRadius: BorderRadius.circular(10),
                                border: clinicAddressError != null
                                    ? Border.all(color: Colors.red, width: 1)
                                    : null,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: DropdownButton<String>(
                                value: selectedAddress,
                                hint: Text('Select address', style: TextStyle(color: hintColor)),
                                isExpanded: true,
                                underline: const SizedBox(),
                                dropdownColor: cardColor,
                                style: TextStyle(color: labelColor, fontSize: 14),
                                iconEnabledColor: hintColor,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Cairo',
                                    child: Text('Cairo'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Giza',
                                    child: Text('Giza'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Alexandria',
                                    child: Text('Alexandria'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedAddress = value;
                                    clinicAddressController.text = value ?? '';
                                    clinicAddressError = null;
                                  });
                                },
                              ),
                            ),
                            if (clinicAddressError != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                clinicAddressError!,
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ],
                            const SizedBox(height: 16),

                            _buildLabel('Specialization'),
                            Container(
                              decoration: BoxDecoration(
                                color: inputFill,
                                borderRadius: BorderRadius.circular(10),
                                border: specializationError != null
                                    ? Border.all(color: Colors.red, width: 1)
                                    : null,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: DropdownButton<String>(
                                value: selectedSpecialization,
                                hint: Text('Select specialization', style: TextStyle(color: hintColor)),
                                isExpanded: true,
                                underline: const SizedBox(),
                                dropdownColor: cardColor,
                                style: TextStyle(color: labelColor, fontSize: 14),
                                iconEnabledColor: hintColor,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Dermatology',
                                    child: Text('Dermatology'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Cosmetic Dermatology',
                                    child: Text('Cosmetic Dermatology'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedSpecialization = value;
                                    specializationController.text = value ?? '';
                                    specializationError = null;
                                  });
                                },
                              ),
                            ),
                            if (specializationError != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                specializationError!,
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ],
                            const SizedBox(height: 16),

                            _buildLabel('Years of Experience'),
                            _buildTextField(
                              controller: experienceController,
                              errorText: experienceError,
                              hintText: 'like : 2 years',
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Admin extra fields
                          if (_selectedRole == 'Admin') ...[
                            _buildLabel('Department'),
                            _buildTextField(
                                hintText: 'Operations Management'),
                            const SizedBox(height: 16),
                            _buildLabel('Admin Authorization Code'),
                            _buildTextField(
                              controller: inviteCodeController,
                              errorText: inviteCodeError,
                              hintText: 'Enter your admin authorization code',
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                'Contact your system administrator for the authorization code',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Patient address
                          if (_selectedRole == 'Patient') ...[
                            _buildLabel('Address'),
                            _buildTextField(
                              controller: addressController,
                              errorText: addressError,
                              hintText: 'Enter your address',
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Password
                          _buildLabel('Password'),
                          _buildPasswordField(
                            controller: passwordController,
                            errorText: passwordError,
                            obscure: _obscurePassword,
                            onToggle: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password
                          _buildLabel('Confirm Password'),
                          _buildPasswordField(
                            controller: confirmPasswordController,
                            errorText: confirmPasswordError,
                            obscure: _obscureConfirmPassword,
                            onToggle: () => setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                          const SizedBox(height: 20),

                          // Notice box
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF3FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    color: Color(0xFF2C67FF), size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _selectedRole == 'Patient'
                                        ? 'By registering, you agree to our Terms of Service and Privacy Policy. Your health data will be handled in compliance with HIPAA regulations.'
                                        : 'Your registration will be reviewed by our admin team. Account activation typically takes 24-48 hours after credential verification.',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF2C67FF)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Register button
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
                                if (!_validateForm()) {
                                  return;
                                }

                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  /// Doctor
                                  if (_selectedRole == 'Doctor') {
                                    await authService.registerDoctor(
                                      name: nameController.text.trim(),
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                      phone: phoneController.text.trim(),
                                      specialization: specializationController.text.trim(),
                                      clinicAddress: clinicAddressController.text.trim(),
                                      yearsOfExperience: experienceController.text.trim(),
                                      syndicateCardImage: File(_capturedImage!.path),
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Doctor Registered Successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                  /// Patient
                                  else if (_selectedRole == 'Patient') {
                                    await authService.registerPatient(
                                      name: nameController.text.trim(),
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                      phone: phoneController.text.trim(),
                                      address: addressController.text.trim(),
                                      age: ageController.text.trim(),
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Patient Registered Successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const OnboardingScreen(),
                                      ),
                                    );
                                  }
                                  /// Admin
                                  else {
                                    await authService.registerAdmin(
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                      inviteCode: inviteCodeController.text.trim(),
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Admin Registered Successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  final errMsg = e.toString().toLowerCase();
                                  if (errMsg.contains("email")) {
                                    setState(() {
                                      emailError = "This email is already registered under another role";
                                    });
                                  } else if (errMsg.contains("phone")) {
                                    setState(() {
                                      phoneError = "This phone number is already registered under another role";
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('$e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
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
                                  : Text(
                                'Register as $_selectedRole',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Sign in link
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Already have an account? ',
                                    style: TextStyle(fontSize: 13)),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) => const SignIn(),
                                      ),
                                          (route) => false,
                                    );
                                  },
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            // Camera Overlay
            if (_showQRScanner)
              Positioned.fill(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _cameraInitialized && _cameraController != null
                          ? CameraPreview(_cameraController!)
                          : Container(
                        color: Colors.black,
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: Colors.white),
                        ),
                      ),
                    ),
                    if (_photoCaptured && _capturedImage != null)
                      Positioned.fill(
                        child: Image.file(
                          File(_capturedImage!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 300,
                        height: 200,
                        child: const CustomPaint(
                          painter: QRCornerPainter(),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: _closeCamera,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C67FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                          ),
                          onPressed: _capturePhoto,
                          child: Text(
                            _photoCaptured ? 'Confirm Photo' : 'Capture Photo',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class QRCornerPainter extends CustomPainter {
  final Color color;
  const QRCornerPainter({this.color = const Color(0xFFFFAA00)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double cornerLen = 30.0;
    const double radius = 10.0;
    final Path path = Path();

    path.moveTo(0, cornerLen);
    path.lineTo(0, radius);
    path.arcToPoint(const Offset(radius, 0),
        radius: const Radius.circular(radius), clockwise: true);
    path.lineTo(cornerLen, 0);

    path.moveTo(size.width - cornerLen, 0);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(Offset(size.width, radius),
        radius: const Radius.circular(radius), clockwise: true);
    path.lineTo(size.width, cornerLen);

    path.moveTo(size.width, size.height - cornerLen);
    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(Offset(size.width - radius, size.height),
        radius: const Radius.circular(radius), clockwise: true);
    path.lineTo(size.width - cornerLen, size.height);

    path.moveTo(cornerLen, size.height);
    path.lineTo(radius, size.height);
    path.arcToPoint(Offset(0, size.height - radius),
        radius: const Radius.circular(radius), clockwise: true);
    path.lineTo(0, size.height - cornerLen);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
