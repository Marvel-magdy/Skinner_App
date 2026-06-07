import 'dart:async';
import 'package:flutter/material.dart';
import 'package:skinner/authuntication/signin.dart';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:skinner/screens/admin_invite_code.dart';
import 'package:skinner/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class dashboard_admin extends StatefulWidget {
  const dashboard_admin({super.key});

  @override
  State<dashboard_admin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<dashboard_admin> {
  Timer? refreshTimer;
  int _step = 0;
  String searchText = "";
  int _selectedIndex = 0;
  int selectedTab = 0;
  List patients = [];
  List doctors = [];
  int selectedFilter = 0;

  List analysesList = [];
  bool isAnalysesLoading = true;

  // متغيرات جلب الإحصائيات من الـ API الجديد
  Map<String, dynamic> statsData = {};
  bool isStatsLoading = true;

  Widget _buildTab(String title, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    bool selected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? (isDark ? const Color(0xFF1E293B) : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))] : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? (isDark ? Colors.white : Colors.black87) : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildFilter(
    String title,
    int index,
  ) {
    bool selected = selectedFilter == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0A1E3F) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  bool isLoading = true;
  List<dynamic> _doctors = [];

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://187.127.227.63',
    ),
  );

  final TextEditingController _notesController = TextEditingController();
  final TextEditingController
    verificationController =
        TextEditingController();

  @override
  void initState() {
    super.initState();

    getPendingDoctors();
    getUsers();
    getAnalyses(); 
    getStats(); 

    refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        await getPendingDoctors();
        await getUsers();
        await getAnalyses(); 
        await getStats();
      }
    );
  }

  Future<void> getStats() async {
    try {
      Response response = await dio.get(
        '/api/admin/stats',
        options: Options(
          headers: {
            'Authorization': 'Bearer $adminToken',
          },
        ),
      );

      if (response.data != null && response.data['success'] == true) {
        setState(() {
          statsData = response.data['data'] ?? {};
          isStatsLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching stats: $e");
      setState(() {
        isStatsLoading = false;
      });
    }
  }

  Future<void> getAnalyses() async {
    try {
      Response response = await dio.get(
        '/api/admin/analyses',
        options: Options(
          headers: {
            'Authorization': 'Bearer $adminToken',
          },
        ),
      );

      if (response.data != null && response.data['success'] == true) {
        setState(() {
          analysesList = response.data['data'] ?? [];
          isAnalysesLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching analyses: $e");
      setState(() {
        isAnalysesLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      DateTime dt = DateTime.parse(dateStr).toLocal();
      List<String> months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
      return "${months[dt.month - 1]} ${dt.day}, ${dt.year}";
    } catch (e) {
      return dateStr;
    }
  }

  String _getConfidenceScore(String? analysisText) {
    if (analysisText == null) return "100%";
    try {
      final regExp = RegExp(r'Confidence:\s*([0-9.]+)');
      final match = regExp.firstMatch(analysisText);
      if (match != null) {
        double val = double.parse(match.group(1)!);
        int percent = (val * 100).round();
        return "$percent%";
      }
    } catch (e) {
      print(e);
    }
    return "100%";
  }

  String _getSeverity(String? disease) {
    if (disease == null) return "MEDIUM";
    String cleanDisease = disease.toLowerCase().trim();
    
    if (cleanDisease.contains("normal")) {
      return "MEDIUM";
    }
    
    List<String> highSeverity = [
      "skincancer", "vasculitis", "rosacea", 
      "eczema", "vitiligo", "bullous", 
      "lupus", "drugeruption"
    ];
    
    if (highSeverity.any((d) => cleanDisease.contains(d))) {
      return "HIGH";
    }
    
    return "MEDIUM";
  }

  Future<void> getPendingDoctors() async {
    try {
      Response response = await dio.get(
        '/api/admin/pending-doctors',
        options: Options(
          headers: {
            'Authorization': 'Bearer $adminToken',
          },
        ),
      );

      setState(() {
        _doctors = response.data['data'];
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getUsers() async {
    try {
      Response response = await dio.get(
        '/api/admin/users',
        options: Options(
          headers: {
            'Authorization': 'Bearer $adminToken',
          },
        ),
      );

      setState(() {
        patients = response.data["data"]["patients"];
        doctors = response.data["data"]["doctors"];
      });

      print("DOCTORS:");
      if (doctors.isNotEmpty) {
      }
      print("FILTER TEST");
      print("Total Users count: ${patients.length + doctors.length}");
      print("PATIENTS = ${patients.length}");
      print("DOCTORS = ${doctors.length}");
    } catch (e) {
      print(e);
    }
  }

  void _showDoneDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 28,
            horizontal: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF3B5BFF),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CustomPaint(
                size: const Size(80, 80),
                painter: _BadgePainter(
                  color: const Color(0xFF22C55E),
                ),
                child: const SizedBox(
                  width: 80,
                  height: 80,
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Done !',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B5BFF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFailedDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 28,
            horizontal: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF3B5BFF),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE5E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFFCC3300),
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Failed !',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCC3300),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = selectedFilter == 0
        ? [...patients, ...doctors]
        : selectedFilter == 1
            ? patients
            : doctors;

    final filteredUsers = users.where((user) {
      if (user == null) return false;
      final query = searchText.trim().toLowerCase();
      if (query.isEmpty) return true;
      final name = (user["name"] ?? "").toString().toLowerCase();
      final email = (user["email"] ?? "").toString().toLowerCase();
      final phone = (user["phone"] ?? "").toString().toLowerCase();
      return name.contains(query) ||
          email.contains(query) ||
          phone.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
  width: double.infinity,

  padding: const EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  ),

  decoration: BoxDecoration(
    color: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).cardColor,
    border: Border(
      bottom: BorderSide(color: Theme.of(context).dividerColor),
    ),
  ),

              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                    ),
                    child: ClipRRect(
  borderRadius: BorderRadius.circular(50),
  child: Image.asset(
    'assets/photo_2026-05-13_23-13-00 (1).jpg (1).jpeg',
    width: 40,
    height: 40,
    fit: BoxFit.cover,
  ),
),
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
                        ),
                      ),
                      Text(
                        'Admin Portal',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () async {
                      // Clear persisted session on logout
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('token');
                      await prefs.remove('role');
                      adminToken = null;
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => SignIn(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(
                      Icons.logout,
                      size: 16,
                      color: Colors.black87,
                    ),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.black26,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTab(
                      "Doctor Verification (${statsData['pendingApprovals'] ?? _doctors.length})",
                      0,
                    ),
                    const SizedBox(width: 8),
                    _buildTab(
                      "User Management",
                      1,
                    ),
                    const SizedBox(width: 8),
                    _buildTab(
                      "Analytics",
                      2,
                    ),
                    _buildTab(
                     "Invite Codes",
                        3,
),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: selectedTab == 0
                  ? (_step == 0 ? _buildListStep() : _buildReviewStep())
                  : selectedTab == 1
                      ? ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            /// Search
                            Builder(builder: (context) {
                              final theme = Theme.of(context);
                              final isDark = theme.brightness == Brightness.dark;
                              return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF8F8FC),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: theme.dividerColor),
                                    ),
                                    child: TextField(
                                      onChanged: (value) => setState(() => searchText = value.toLowerCase()),
                                      decoration: const InputDecoration(
                                        hintText: "Search by name, email, or phone...",
                                        prefixIcon: Icon(Icons.search, color: Color(0xFF7E7E94)),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFEFF1F7),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        _buildFilter("All (${patients.length + doctors.length})", 0),
                                        _buildFilter("Patients (${patients.length})", 1),
                                        _buildFilter("Doctors (${doctors.length})", 2),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                            }),
                                  
                            const SizedBox(height: 16),

                            ...filteredUsers.map((user) {
                              final isDoctor = doctors.any((d) => d["email"] == user["email"]);
                              final theme = Theme.of(context);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: theme.dividerColor),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundColor: isDoctor
                                              ? const Color(0xFFD1FAE5)
                                              : const Color(0xFFDDE8FF),
                                          child: Text(
                                            (user["name"] != null && user["name"].toString().isNotEmpty)
                                                ? user["name"].toString().substring(0, 1).toUpperCase()
                                                : "?",
                                            style: TextStyle(
                                              color: isDoctor
                                                  ? const Color(0xFF065F46)
                                                  : const Color(0xFF3B5BFF),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            user["name"] ?? "",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDoctor
                                                ? const Color(0xFFD1FAE5)
                                                : const Color(0xFFE7E5FF),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            isDoctor ? "DOCTOR" : "PATIENT",
                                            style: TextStyle(
                                              color: isDoctor
                                                  ? const Color(0xFF065F46)
                                                  : const Color(0xFF4F46E5),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(user["email"] ?? ""),
                                    const SizedBox(height: 6),
                                    Text(user["phone"] ?? ""),
                                    const SizedBox(height: 12),
                                    const SizedBox(height: 12),

                                    Divider(
                                      color: Color(0xFFE5E7EB),
                                    ),

                                    const SizedBox(height: 12),
                                    if (isDoctor) ...[
                                      Text("Specialization: ${user["specialization"] ?? ''}"),
                                      Text("Gender: ${user["gender"] ?? ''}"),
                                      Text("Experience: ${user["year_of_experience"] ?? ''} years"),
                                      Text("Clinic Address: ${user["clinic_address"] ?? ''}"),
                                    ] else ...[
                                      Text("Age: ${user["age"] ?? ''}"),
                                      Text("Gender: ${user["gender"] ?? ''}"),
                                      Text("Address: ${user["address"] ?? ''}"),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        )
                          : selectedTab == 2
                          ? _buildAnalyticsTab()
                          : const InviteCodesScreen(),            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    if (isAnalysesLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (analysesList.isEmpty) {
      return const Center(
        child: Text(
          "No analysis records found",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    List<Map<String, dynamic>> calculatedBreakdown = [];
    Map<String, int> counts = {};
    for (var item in analysesList) {
      String classification = item["skin_disease_classification"] ?? "Unknown";
      counts[classification] = (counts[classification] ?? 0) + 1;
    }

    var sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedEntries) {
      calculatedBreakdown.add({
        "condition": entry.key,
        "count": entry.value,
        "percentage": entry.value / analysesList.length,
      });
    }

    final recentList = analysesList.length > 15 
        ? analysesList.sublist(0, 15) 
        : analysesList;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Condition Breakdown Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Condition Breakdown",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...calculatedBreakdown.map((item) {
                final condition = item["condition"] ?? "";
                final count = item["count"] ?? 0;
                final percentage = (item["percentage"] as double? ?? 0.0);
                final percentageText = "${(percentage * 100).toInt()}%";

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            condition,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                          Text(
                            "$count ($percentageText)",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: const Color(0xFFEFF1F7),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6366F1), 
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 2. Recent Analyses Title
        Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF047857), 
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Recent Analyses",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 3. Recent Analyses List
        ...recentList.map((analysis) {
          final condition = analysis["skin_disease_classification"] ?? "Unknown";
          final date = _formatDate(analysis["created_at"]);
          final severity = _getSeverity(condition);
          final score = _getConfidenceScore(analysis["analysis"]);

          Color severityBg = const Color(0xFFFFEBEB);
          Color severityText = const Color(0xFFCC3300);
          if (severity == "MEDIUM") {
            severityBg = const Color(0xFFFEF3C7);
            severityText = const Color(0xFFD97706);
          } else if (severity == "LOW") {
            severityBg = const Color(0xFFD1FAE5);
            severityText = const Color(0xFF059669);
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFEFF1F7),
              ),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      condition,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    severity,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: severityText,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  score,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildListStep() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      itemCount: _doctors.length,
      itemBuilder: (context, index) {
        final doc = _doctors[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    doc['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Pending',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(doc['email'] ?? ''),
              const SizedBox(height: 10),
              Text(doc['phone'] ?? ''),
              const SizedBox(height: 10),
              Text('Specialization: ${doc['specialization'] ?? ''}'),
              const SizedBox(height: 10),
              Text('Gender: ${doc['gender'] ?? ''}'),
              const SizedBox(height: 10),
              Text('Experience: ${doc['year_of_experience'] ?? ''} years'),
              const SizedBox(height: 10),
              Text('Clinic Address: ${doc['clinic_address'] ?? ''}'),
              const SizedBox(height: 10),
              Text(
                'Medical ID: ${doc['medical_syndicate_id_card'] ?? ''}',
              ),
              const SizedBox(height: 20),
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'http://187.127.227.63${doc['syndicate_card_image']}',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (
                      context,
                      child,
                      loadingProgress,
                    ) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      print(error);

                      return Container(
                        height: 250,
                        color: Colors.red.shade100,
                        child: const Center(
                          child: Text(
                            'Image Error',
                          ),
                        ),
                      );
                    },
                  )),
              const SizedBox(height: 20),
              const Text(
                'Pending Doctor',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    verificationController.clear();
                    setState(() {
                      
                      _selectedIndex = index;
                      _step = 1;
                    });
                  },
                  child: const Text(
                    'Review Application',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewStep() {
if (_doctors.isEmpty) {
  return const Center(
    child: CircularProgressIndicator(),
  );
}

if (_selectedIndex >= _doctors.length) {
  return const Center(
    child: Text("No doctor selected"),
  );
}

final doc = _doctors[_selectedIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doc['name'] ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              doc['email'] ?? '',
            ),
            const SizedBox(height: 10),
            Text(
              doc['phone'] ?? '',
            ),
            const SizedBox(height: 10),
            Text(
              doc['specialization'] ?? '',
            ),
            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Verification Notes",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: verificationController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    "Enter verification notes and comments...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                    ),
                    onPressed: () async {
                      try {
                        await AuthService().approveDoctor(
                          token: adminToken!,
                          medicalId: doc['medical_syndicate_id_card'],
                            notes: verificationController.text,

                        );

                        await getPendingDoctors();
                        await getUsers();
                        print("REFRESH DONE");
                        verificationController.clear();
                        setState(() {
                          _step = 0;
                        });

                        _showDoneDialog();
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: const Text(
                      'Approve',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                    ),
                    onPressed: () async {
                      try {
                        await AuthService().rejectDoctor(
                          token: adminToken!,
                          medicalId: doc['medical_syndicate_id_card'],
                            notes: verificationController.text,

                        );

                        await getPendingDoctors();
                        await getUsers();
                        verificationController.clear();

                        setState(() {
                          _step = 0;
                        });

                        _showFailedDialog();
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: const Text(
                      'Reject',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    _notesController.dispose();
    super.dispose();
  }
}

class _BadgePainter extends CustomPainter {
  final Color color;

  const _BadgePainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final cx = size.width / 2;
    final cy = size.height / 2;

    const points = 8;
    const outerR = 40.0;
    const innerR = 30.0;

    final path = Path();

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi / points) - pi / 2;

      final r = i.isEven ? outerR : innerR;

      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

