import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:skinner/authuntication/signin.dart';
import 'package:skinner/screens/chatbot.dart';
import 'package:skinner/screens/patient_screen.dart';
import 'package:skinner/services/auth_service.dart'; 
import 'package:skinner/widgets/analysis_screen.dart';
import 'package:skinner/screens/appointment_screen.dart';
import 'package:skinner/screens/doctors_screenp.dart';
import 'package:dio/dio.dart';

class DashboardUser extends StatefulWidget {
  const DashboardUser({super.key});

  @override
  State<DashboardUser> createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser> {
  int _currentTabIndex = 0;
  File? _selectedImage;
  bool showAppointmentScreen = false;
Map<String, dynamic>? analysisResult;
List<dynamic> analysisHistory = [];
Map? selectedDoctor;
final AuthService authService = AuthService();

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      print("Image selected: ${image.path}");
    }
  }

  
  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
      });
      print("Photo taken: ${photo.path}");
    }
  }
Future<void> analyzeImage() async {
  if (_selectedImage == null) return;

  try {
    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(
        _selectedImage!.path,
        filename: "skin_image.jpg",
      ),
    });

    final response = await authService.dio.post(
      "/api/analysis/upload-and-analyze",
      data: formData,
      options: Options(
        headers: {
          "Authorization": "Bearer $adminToken",
        },
      ),
    );

    print("ANALYSIS RESPONSE:");
    print(response.data);

    setState(() {
      analysisResult = response.data["data"];
      _currentTabIndex = 1;
    });
  } catch (e) {
    print("ANALYSIS ERROR:");
    print(e);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Analysis failed"),
      ),
    );
  }
}
Future<void> getAnalysisHistory() async {
  try {
    final response = await authService.dio.get(
      "/api/analysis/history",
      options: Options(
        headers: {
          "Authorization": "Bearer $adminToken",
        },
      ),
    );

    setState(() {
      analysisHistory = response.data["data"];
    });

    print("HISTORY LOADED");
    print(response.data);
    print(analysisHistory.length);

  } catch (e) {
    print("HISTORY ERROR");
    print(e);
  }
}
@override
void initState() {
  super.initState();
  getAnalysisHistory();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Header
          _buildHeader(context),

          // Tab bar
          _buildTabBar(),

          // Content Area
          Expanded(
  child: _currentTabIndex == 0
      ? SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Column(
            children: [
              _buildMainContentCard(),
              const SizedBox(height: 24),
              _buildPreviousAnalysesSection(),
              const SizedBox(height: 100),
            ],
          ),
        )
      : _currentTabIndex == 1
          ? AnalysisScreen(
            analysisResult: analysisResult,
              selectedImage: _selectedImage,
            )
      : _currentTabIndex == 2
          ? (
              showAppointmentScreen
                  ? AppointmentScreen(
                      doctor: selectedDoctor!,
                    )
                  : DoctorsScreen(
                      onBookAppointment: (doctor) {
                        setState(() {
                          selectedDoctor = doctor;
                          showAppointmentScreen = true;
                        });
                      },
                    )
            )
          : const PatientScreen(),
),
        ],
      ),

      floatingActionButton: SizedBox(
  width: 70,
  height: 70,
  child: FloatingActionButton(
    elevation: 6,
    backgroundColor: Colors.transparent,
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ChatBotScreen(),
        ),
      );
    },
    child: ClipOval(
      child: Image.asset(
        "assets/download.png",
        fit: BoxFit.cover,
      ),
    ),
  ),
),

    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 16), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              
              Image.asset(
                'assets/images/Group 1000002806.png',
                width: 36,
                height: 36,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.cruelty_free, color: Colors.blue),
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
                      color: Color(0xFF2C67FF),
                    ),
                  ),
                  Text(
                    'Patient Portal',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SignIn()),
                (route) => false,
              );
            },
            child: const Row(
              children: [
                Icon(Icons.logout_outlined, size: 18, color: Colors.grey),
                SizedBox(width: 4),
                Text('Logout', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _buildSegmentedTab(Icons.cloud_upload_outlined, 'Upload', 0),
            _buildSegmentedTab(Icons.analytics_outlined, 'Analysis', 1),
            _buildSegmentedTab(Icons.calendar_today_outlined, 'Doctors', 2),
            _buildSegmentedTab(Icons.person_outline, 'Patient', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedTab(IconData icon, String label, int index) {
    bool isActive = _currentTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: isActive
              ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                )
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isActive ? Colors.black87 : Colors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? Colors.black87 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildInstructionBox() {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFEEF2FF),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFFD1D5F0),
      ),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: Color(0xFF3730A3),
            ),
            SizedBox(width: 8),
            Text(
              'For best results:',
              style: TextStyle(
                color: Color(0xFF3730A3),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.only(left: 24),
          child: Text(
            '• Ensure good lighting\n'
            '• Take photo perpendicular\n'
            '• Avoid using flash',
            style: TextStyle(
              color: Color(0xFF3730A3),
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ),
      ],
    ),
  );
}

 Widget _buildMainContentCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          _selectedImage == null
              ? 'Upload Skin Image'
              : 'Saved Image - Ready for Analysis',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          _selectedImage == null
              ? 'Take a clear photo or upload an image'
              : 'Your image has been securely saved and is ready for AI analysis',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 16),

        if (_selectedImage == null) ...[

          _buildInstructionBox(),

          const SizedBox(height: 16),

          _buildSelectionCard(
            Icons.cloud_upload_outlined,
            'Upload from Device',
            'Click to browse files',
            Colors.blue,
            _pickImageFromGallery,
          ),

          const SizedBox(height: 12),

          _buildSelectionCard(
            Icons.camera_alt_outlined,
            'Take Photo',
            'Use your camera',
            Colors.green,
            _takePhoto,
          ),

          const SizedBox(height: 12),

          const Center(
            child: Text(
              'Supported formats: JPG, PNG • Max size: 10MB',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ),

        ] else ...[

          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              _selectedImage!,
              height: 320,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: analyzeImage,
              icon: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
              ),
              label: const Text(
                'Analyze Image with AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: TextButton(
              onPressed: () {

                setState(() {

                  _selectedImage = null;

                });

              },
              child: const Text(
                'Choose Another Image',
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

  Widget _buildSelectionCard(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousAnalysesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_edu, size: 20),
              SizedBox(width: 10),
              Text('Previous Analyses', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          analysisHistory.isEmpty
    ? const Center(
        child: Text("No analyses found"),
      )
    : Column(
        children: analysisHistory.take(3).map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildAnalysisResultCard(
              item["skin_disease_classification"] ?? "Unknown",
              item["created_at"]
                  .toString()
                  .substring(0, 10),
              "completed",
              Colors.green,
                item["skin_image_upload"] ?? "",

            ),
          );
        }).toList(),
      ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResultCard(String title, String date, String risk, Color riskColor,String imageUrl,) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          ClipRRect(
  borderRadius: BorderRadius.circular(8),
  child: Image.network(
    "http://187.127.227.63$imageUrl",
    width: 56,
    height: 56,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFD4C4B8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.image,
          color: Colors.grey,
          size: 24,
        ),
      );
    },
  ),
),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: riskColor.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                  child: Text(risk, style: TextStyle(color: riskColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAnalysisScreen() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "AI Analysis Results",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 20),

          Text(
            "Analysis completed successfully",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ),
  );
}
}