import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:skinner/authuntication/signin.dart';
import 'package:skinner/screens/chat_list_screen.dart';
import 'package:skinner/screens/chatbot.dart';
import 'package:skinner/screens/profile_screen.dart';
import 'package:skinner/services/auth_service.dart';
import 'package:skinner/services/chat_service.dart';
import 'package:skinner/widgets/analysis_screen.dart';
import 'package:skinner/screens/appointment_screen.dart';
import 'package:skinner/screens/doctors_screenp.dart';
import 'package:skinner/screens/map_screen.dart';
import 'package:dio/dio.dart';
import 'package:skinner/services/analysis_adapter.dart';
import 'package:skinner/models/analysis_result.dart';
import 'package:skinner/services/image_upload_helper.dart';

class DashboardUser extends StatefulWidget {
  const DashboardUser({super.key});

  @override
  State<DashboardUser> createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser> {
  int _currentTabIndex = 0;
  File? _selectedImage;
  bool showAppointmentScreen = false;
  bool showMapScreen = false;
  bool _isAnalyzing = false;
  AnalysisResult? analysisResult;
  List<AnalysisResult> analysisHistory = [];
  Map? selectedDoctor;
  final AuthService authService = AuthService();
  int _unreadCount = 0;
  Timer? _unreadTimer; // polls badge every 10 s

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
    debugPrint('\n ===== ANALYZE IMAGE START =====');
    
    // STEP 1: Check if image is selected
    if (_selectedImage == null) {
      debugPrint(' No image selected');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image first')),
        );
      }
      return;
    }

    // STEP 2: Check if token exists
    if (adminToken == null || adminToken!.isEmpty) {
      debugPrint(' No authentication token found');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication error. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    debugPrint(' Auth token exists: ${adminToken!.substring(0, 20)}...');

    // STEP 3: Validate image file
    final validation = await ImageUploadHelper.validateImage(_selectedImage!);
    if (!validation['isValid']) {
      debugPrint(' Image validation failed');
      final errors = validation['errors'] as List<String>;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image validation failed: ${errors.join(", ")}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }
    debugPrint(' Image validation passed');

    // STEP 4: Set loading state
    setState(() {
      _isAnalyzing = true;
    });

    try {
      // STEP 5: Prepare FormData with unique filename
      final uniqueFilename = ImageUploadHelper.generateUniqueFilename(_selectedImage!.path);
      debugPrint(' Generated unique filename: $uniqueFilename');

      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: uniqueFilename,
        ),
      });

      // STEP 6: Prepare request details
      final url = "${authService.dio.options.baseUrl}/api/analysis/upload-and-analyze";
      final headers = {
        "Authorization": "Bearer $adminToken",
        "Content-Type": "multipart/form-data",
      };

      // STEP 7: Log request details
      ImageUploadHelper.logRequest(
        url: url,
        method: 'POST',
        headers: headers,
        formData: formData,
      );

      // STEP 8: Send request with timeout
      debugPrint(' Sending request...');
      final response = await authService.dio.post(
        "/api/analysis/upload-and-analyze",
        data: formData,
        options: Options(
          headers: headers,
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      // STEP 9: Log response
      debugPrint(' Response received');
      ImageUploadHelper.logResponse(response);

      // STEP 10: Validate response structure
      if (response.data == null) {
        throw Exception('Response data is null');
      }

      debugPrint(' Response data type: ${response.data.runtimeType}');

      // Convert dynamic Map to Map<String, dynamic>
      Map<String, dynamic> responseMap;
      if (response.data is Map) {
        responseMap = Map<String, dynamic>.from(response.data as Map);
        debugPrint(' Converted Map to Map<String, dynamic>');
      } else {
        throw Exception('Response is not a Map: ${response.data.runtimeType}');
      }
      
      if (!responseMap.containsKey('data')) {
        throw Exception('Response missing "data" field. Available keys: ${responseMap.keys.join(", ")}');
      }

      debugPrint(' Response["data"] type: ${responseMap["data"].runtimeType}');

      // Convert nested data Map to Map<String, dynamic>
      Map<String, dynamic> rawData;
      if (responseMap['data'] is Map) {
        rawData = Map<String, dynamic>.from(responseMap['data'] as Map);
        debugPrint(' Converted nested data to Map<String, dynamic>');
      } else {
        throw Exception('Response["data"] is not a Map: ${responseMap["data"].runtimeType}');
      }

      // STEP 11: Adapt the raw API response to AnalysisResult
      debugPrint(' Adapting response to AnalysisResult...');
      final adaptedResult = AnalysisAdapter.adaptAnalysis(rawData);
      debugPrint(' Adaptation successful');

      // STEP 12: Update UI
      if (mounted) {
        setState(() {
          analysisResult = adaptedResult;
          _currentTabIndex = 1;
          _isAnalyzing = false;
        });
        debugPrint(' UI updated successfully');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analysis completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } on DioException catch (e) {
      debugPrint(' DioException caught');
      ImageUploadHelper.logDioError(e);
      
      String errorMessage = 'Analysis failed';
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Upload timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Cannot connect to server. Please check your internet.';
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'Authentication failed. Please login again.';
      } else if (e.response?.statusCode == 413) {
        errorMessage = 'Image file too large. Please use a smaller image.';
      } else if (e.response?.statusCode == 400) {
        errorMessage = 'Invalid request. Please try a different image.';
      } else if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        errorMessage = 'Server error. Please try again later.';
      } else if (e.response?.data != null) {
        // Try to extract error message from response
        try {
          final responseData = e.response!.data;
          if (responseData is Map && responseData.containsKey('message')) {
            errorMessage = responseData['message'].toString();
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }

    } catch (e, stackTrace) {
      debugPrint(' General exception caught');
      debugPrint('Exception: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }

    debugPrint('🎯 ===== ANALYZE IMAGE END =====\n');
  }

  Future<void> getAnalysisHistory() async {
    try {
      final response = await authService.dio.get(
        "/api/analysis/history",
        options: Options(headers: {"Authorization": "Bearer $adminToken"}),
      );

      debugPrint('📜 History response type: ${response.data.runtimeType}');

      // Safely convert response data
      if (response.data == null) {
        debugPrint('⚠️ History response is null');
        setState(() {
          analysisHistory = [];
        });
        return;
      }

      Map<String, dynamic> responseMap;
      if (response.data is Map) {
        responseMap = Map<String, dynamic>.from(response.data as Map);
      } else {
        debugPrint('❌ Unexpected history response type: ${response.data.runtimeType}');
        return;
      }

      // Extract history array
      if (!responseMap.containsKey('data')) {
        debugPrint('⚠️ History response missing "data" field');
        setState(() {
          analysisHistory = [];
        });
        return;
      }

      final rawHistory = responseMap['data'];
      if (rawHistory is! List) {
        debugPrint('❌ History data is not a List: ${rawHistory.runtimeType}');
        setState(() {
          analysisHistory = [];
        });
        return;
      }

      // Convert each item to Map<String, dynamic>
      final List<Map<String, dynamic>> convertedHistory = [];
      for (var item in rawHistory) {
        if (item is Map) {
          convertedHistory.add(Map<String, dynamic>.from(item as Map));
        }
      }

      // Adapt each history item through the adapter
      final adaptedHistory = AnalysisAdapter.adaptAnalysisList(convertedHistory);

      setState(() {
        analysisHistory = adaptedHistory;
      });

      debugPrint("✅ HISTORY LOADED: ${analysisHistory.length} items");
    } catch (e, stackTrace) {
      debugPrint("❌ HISTORY ERROR: $e");
      debugPrint("Stack trace: $stackTrace");
    }
  }

  @override
  void initState() {
    super.initState();
    getAnalysisHistory();
    _fetchUnreadCount();
    // Keep the badge live — re-poll every 10 seconds
    _unreadTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) {
        // Only poll when the Chat tab is NOT already open
        if (_currentTabIndex != 3) _fetchUnreadCount();
      },
    );
  }

  @override
  void dispose() {
    _unreadTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final response = await ChatService().getMyChats();
      if (!mounted) return;
      final data = response.data;
      List<dynamic> chats = [];
      if (data is Map && data['data'] is List) {
        chats = data['data'] as List;
      } else if (data is List) {
        chats = data;
      }
      int count = 0;
      for (final chat in chats) {
        if (chat is Map) {
          final unread = chat['unread_count'] ?? chat['unreadCount'] ?? 0;
          count += (unread as num).toInt();
        }
      }
      setState(() => _unreadCount = count);
    } catch (_) {
      // badge stays at 0 if fetch fails — silent
    }
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
                    onFindDoctors: () => setState(() => _currentTabIndex = 2),
                  )
                : _currentTabIndex == 2
                ? (showAppointmentScreen
                      ? AppointmentScreen(
                          doctor: selectedDoctor!,
                          onBack: () {
                            setState(() {
                              showAppointmentScreen = false;
                              selectedDoctor = null;
                            });
                          },
                        )
                      : showMapScreen
                          ? MapScreen(
                              doctor: selectedDoctor!,
                              onBack: () {
                                setState(() {
                                  showMapScreen = false;
                                  selectedDoctor = null;
                                });
                              },
                              onBook: () {
                                setState(() {
                                  showMapScreen = false;
                                  showAppointmentScreen = true;
                                });
                              },
                            )
                          : DoctorsScreen(
                              onBookAppointment: (doctor) {
                                setState(() {
                                  selectedDoctor = doctor;
                                  showAppointmentScreen = true;
                                });
                              },
                              onViewMap: (doctor) {
                                setState(() {
                                  selectedDoctor = doctor;
                                  showMapScreen = true;
                                });
                              },
                            ))
                : _currentTabIndex == 3
                ? const ChatListScreen()
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
              MaterialPageRoute(builder: (_) => const ChatBotScreen()),
            );
          },
          child: ClipOval(
            child: Image.asset("assets/download.png", fit: BoxFit.cover),
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
                Text(
                  'Logout',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
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
            _buildChatTab(3),
            _buildSegmentedTab(Icons.person_outline, 'Patient', 4),
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
              Icon(
                icon,
                size: 16,
                color: isActive ? Colors.black87 : Colors.grey,
              ),
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

  /// Chat tab — identical to _buildSegmentedTab but with an unread badge
  Widget _buildChatTab(int index) {
    final bool isActive = _currentTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentTabIndex = index;
            _unreadCount = 0; // clear badge when user opens chat
          });
        },
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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 16,
                    color: isActive ? Colors.black87 : Colors.grey,
                  ),
                  if (_unreadCount > 0)
                    Positioned(
                      top: -5,
                      right: -7,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _unreadCount > 99 ? '99+' : '$_unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 6),
              Text(
                'Chat',
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
        border: Border.all(color: const Color(0xFFD1D5F0)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Color(0xFF3730A3)),
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(
            _selectedImage == null
                ? 'Take a clear photo or upload an image'
                : 'Your image has been securely saved and is ready for AI analysis',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
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
                style: TextStyle(color: Colors.grey, fontSize: 11),
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
                onPressed: _isAnalyzing ? null : analyzeImage,
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.auto_awesome, color: Colors.white),
                label: Text(
                  _isAnalyzing ? 'Analyzing...' : 'Analyze Image with AI',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
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
                child: const Text('Choose Another Image'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectionCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
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
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
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
              Text(
                'Previous Analyses',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          analysisHistory.isEmpty
              ? const Center(child: Text("No analyses found"))
              : Column(
                  children: analysisHistory.take(3).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildAnalysisResultCard(item),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResultCard(AnalysisResult item) {
    const String baseUrl = 'http://187.127.227.63';
    final String fullImageUrl = item.imageUrl.isNotEmpty ? '$baseUrl${item.imageUrl}' : '';
    final String dateStr = item.analyzedAt.toString().substring(0, 10);

    return GestureDetector(
      onTap: () {
        // Load this history item into the analysis screen and navigate to it
        setState(() {
          analysisResult = item;
          _selectedImage = null; // no local file for history items
          _currentTabIndex = 1;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: fullImageUrl.isNotEmpty
                  ? Image.network(
                      fullImageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _imagePlaceholder();
                      },
                    )
                  : _imagePlaceholder(),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.predictedClass,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'completed',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow hint
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFD4C4B8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_outlined, color: Colors.grey, size: 24),
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            Text(
              "Analysis completed successfully",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
