import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:skinner/authuntication/signin.dart';
import 'dart:io';


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
  bool _cameraInitialized = false;

  // Store the captured image
  XFile? _capturedImage;
  final TextEditingController _scanIdController = TextEditingController();
  final TextEditingController nameController =
    TextEditingController();

final TextEditingController emailController =
    TextEditingController();

final TextEditingController phoneController =
    TextEditingController();

final TextEditingController passwordController =
    TextEditingController();

final TextEditingController experienceController =
    TextEditingController();

final TextEditingController specializationController =
    TextEditingController();

final TextEditingController clinicAddressController =
    TextEditingController();

  final List<String> _roles = ['Patient', 'Doctor', 'Admin'];

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
      // First tap: take the photo
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        final XFile image = await _cameraController!.takePicture();
        setState(() {
          _capturedImage = image;
          _photoCaptured = true;
        });
      }
    } else {
      // Second tap (green checkmark): confirm and close
      if (_capturedImage != null) {
        setState(() {
          // Show the file name in the Scan ID field
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
  void dispose() {
    _cameraController?.dispose();
    _scanIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF9),
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

                  // White card
                  Padding(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create an Account',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Register as a patient, healthcare provider, or admin',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),

                          // Role toggle
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
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
                                            ? Colors.white
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
                                              ? Colors.black
                                              : Colors.grey,
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

                          // Scan ID (Doctor only) — shows thumbnail if photo captured
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
                            else
                              TextField(
                                controller: _scanIdController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: 'Take a photo of your ID',
                                  hintStyle:
                                  const TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: const Color(0xFFF5F5F5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.camera_alt_outlined,
                                        color: Colors.grey),
                                    onPressed: _openCamera,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                          ],

                          // Full Name
                          _buildLabel('Full Name'),
                          _buildTextField(
                            controller: nameController,
                              hintText: _selectedRole == 'Patient'
                                  ? 'John Doe'
                                  : 'Dr. Jane Smith'),
                          const SizedBox(height: 16),

                          // Email
                          _buildLabel('Email'),
                          _buildTextField(
                            controller: emailController,
                              hintText: _selectedRole == 'Patient'
                                  ? 'name@example.com'
                                  : 'doctor@hospital.com'),
                          const SizedBox(height: 16),

                          // Phone
                          _buildLabel('Phone Number'),
                          _buildTextField(
                            controller: phoneController,
                            hintText: '+1 (555) 000-0000'),
                          const SizedBox(height: 16),

                          // Age
                          _buildLabel('Age'),
                          _buildTextField(
                              hintText:
                              _selectedRole == 'Patient' ? '25' : '35'),
                          const SizedBox(height: 16),

                          // Gender
                          _buildLabel('Gender'),
                          _buildDropdownField(hint: 'Select gender'),
                          const SizedBox(height: 16),

                          // Doctor extra fields
                          if (_selectedRole == 'Doctor') ...[
                            _buildLabel('Clinic Address'),
                            _buildDropdownField(hint: 'Select address'),
                            const SizedBox(height: 16),
                            _buildLabel('Specialization'),
                            _buildDropdownField(hint: 'Select specialization'),
                            const SizedBox(height: 16),
                            _buildLabel('Years of Experience'),
                            
                            _buildTextField(
                              controller: experienceController,
                              hintText: 'like : 2 years'),
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
                                hintText:
                                'Enter your admin authorization code'),
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
                            _buildTextField(hintText: 'Enter your address'),
                            const SizedBox(height: 16),
                          ],

                          // Password
                          _buildLabel('Password'),
                          _buildPasswordField(
                            controller: passwordController,
                            obscure: _obscurePassword,
                            onToggle: () => setState(
                                    () => _obscurePassword = 
                                       !_obscurePassword),
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password
                          _buildLabel('Confirm Password'),
                          _buildPasswordField(
                            obscure: _obscureConfirmPassword,
                            onToggle: () => setState(() =>
                            _obscureConfirmPassword =
                            !_obscureConfirmPassword),
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
                              onPressed: () {},
                              child: Text(
                                'Register as $_selectedRole',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
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
                                  onTap: () => {Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => SignIn(),
                                    ),(route) => false,)},
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
                    // Real camera preview
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

                    // Show captured image preview after photo is taken
                    if (_photoCaptured && _capturedImage != null)
                      Positioned.fill(
                        child: Image.file(
                          File(_capturedImage!.path),
                          fit: BoxFit.cover,
                        ),
                      ),

                    // Dark overlay (top and bottom)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                              stops: const [0.0, 0.25, 0.75, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Top bar
                    Positioned(
                      top: 24,
                      left: 20,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _photoCaptured ? 'Photo Captured!' : 'Scan ID',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _photoCaptured
                                    ? 'Tap ✓ to confirm or retake.'
                                    : 'Point your camera at your ID\nand tap the button to capture.',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _closeCamera,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Corner bracket frame
                    if (!_photoCaptured)
                      Center(
                        child: SizedBox(
                          width: 260,
                          height: 180,
                          child: CustomPaint(
                            painter: QRCornerPainter(
                              color: const Color(0xFFFFAA00),
                            ),
                          ),
                        ),
                      ),

                    // Bottom buttons
                    Positioned(
                      bottom: 60,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Retake button (only after capture)
                          if (_photoCaptured)
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                  _photoCaptured = false;
                                  _capturedImage = null;
                                });
                              },
                              child: Container(
                                width: 56,
                                height: 56,
                                margin: const EdgeInsets.only(right: 30),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white54, width: 2),
                                ),
                                child: const Icon(Icons.refresh,
                                    color: Colors.white, size: 28),
                              ),
                            ),

                          // Capture / Confirm button
                          GestureDetector(
                            onTap: _capturePhoto,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: _photoCaptured
                                    ? const Color(0xFF00CC44)
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _photoCaptured
                                      ? const Color(0xFF00CC44)
                                      : Colors.white54,
                                  width: 3,
                                ),
                              ),
                              child: _photoCaptured
                                  ? const Icon(Icons.check,
                                  color: Colors.white, size: 34)
                                  : null,
                            ),
                          ),
                        ],
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField({

  required String hintText,

  TextEditingController? controller,

}) {

  return TextField(

    controller: controller,

    decoration: InputDecoration(

      hintText: hintText,

      filled: true,

      fillColor: const Color(0xFFF5F5F5),

      border: OutlineInputBorder(

        borderRadius: BorderRadius.circular(10),

        borderSide: BorderSide.none,
      ),
    ),
  );
}

  Widget _buildDropdownField({required String hint}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButton<String>(
        value: null,
        hint: Text(hint, style: const TextStyle(color: Colors.grey)),
        isExpanded: true,
        underline: const SizedBox(),
        items: const [],
        onChanged: (_) {},
      ),
    );
  }

  Widget _buildPasswordField(
      {required bool obscure,
       required VoidCallback onToggle,
       TextEditingController? controller,
      }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(obscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

// Custom painter for corner brackets
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
