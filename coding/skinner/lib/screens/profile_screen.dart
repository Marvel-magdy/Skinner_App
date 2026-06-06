import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart' show adminToken;
import 'package:skinner/l10n/app_translations.dart';

class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});

  @override
  State<PatientScreen> createState() => _PatientScreenState(
    
  );
  
}

class _PatientScreenState extends State<PatientScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool isEditing = false;
  bool isLoading = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.skinnerai.site'));
  List<dynamic> _appointments = [];
  bool isLoadingAppointments = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _fetchAppointments();
  }

  Future<void> _fetchProfile() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? adminToken ?? '';

      final response = await _dio.get(
        '/api/profile/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        setState(() {
          nameController.text = data['name'] ?? "";
          emailController.text = data['email'] ?? "";
          addressController.text = data['address'] ?? "";
          phoneController.text = data['phone'] ?? "";
        });
      } else {
        _setFallbackData();
      }
    } catch (e) {
      _setFallbackData();
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchAppointments() async {
    setState(() => isLoadingAppointments = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? adminToken ?? '';

      final response = await _dio.get(
        '/api/appointment/my',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data ?? [];
        if (data is List) {
          setState(() {
            _appointments = data;
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to fetch appointments: $e");
    } finally {
      setState(() => isLoadingAppointments = false);
    }
  }

  void _setFallbackData() {
    nameController.text = "John Doe";
    emailController.text = "john.doe@email.com";
    addressController.text = "Downtown";
    phoneController.text = "+1 (555) 000-0000";
  }

  Future<void> _saveProfileChanges() async {
    // Show a loading indicator dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? adminToken ?? '';

      final response = await _dio.put(
        '/api/profile/update',
        data: {
          'name': nameController.text,
          'phone': phoneController.text,
          'address': addressController.text,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {}); // Refresh UI with new controller values
        Navigator.pop(context); // Close edit dialog
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update profile")),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving profile: $e")),
      );
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return Dialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppL10n.of(context, AppStrings.patientInfo),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xFF2C67FF)),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppL10n.of(context, AppStrings.fullName), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppL10n.of(context, AppStrings.email), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailController,
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppL10n.of(context, AppStrings.phoneNumber), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      hintText: "+1 (555) 000-0000",
                      filled: true,
                      fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppL10n.of(context, AppStrings.address), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2C67FF),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _saveProfileChanges,
                            child: Text(AppL10n.of(context, AppStrings.saveChanges), style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF2C67FF)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(AppL10n.of(context, AppStrings.cancel), style: const TextStyle(color: Color(0xFF2C67FF))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final borderColor = theme.dividerColor;

    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(50.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          /// Patient Information
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [

                    Text(
                      AppL10n.of(context, AppStrings.patientInfo),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    ElevatedButton.icon(
  onPressed: () {
    _showEditProfileDialog(context);
  },
  icon: const Icon(
    Icons.edit,
    size: 18,
  ),
  label: Text(AppL10n.of(context, AppStrings.edit)),
),
                  ],
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Name",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    nameController.text,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Address",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    addressController.text,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    emailController.text,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Phone Number",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    phoneController.text.isNotEmpty ? phoneController.text : "Not provided",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// Calendar
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Appointment Schedule",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 20),
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2035, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: Icon(Icons.chevron_left, color: theme.iconTheme.color),
                    rightChevronIcon: Icon(Icons.chevron_right, color: theme.iconTheme.color),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                    weekendStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                  ),
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    weekendTextStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    outsideTextStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
                    todayDecoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF2C67FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// Appointments
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                const Text(
                  "Upcoming Appointments",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                if (isLoadingAppointments && _appointments.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (_appointments.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("No upcoming appointments found", style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ..._appointments.take(5).map((appt) {
                    final dateStr = appt['date']?.toString() ?? '';
                    String displayDate = "Date not set";
                    String displayTime = "";
                    if (dateStr.isNotEmpty) {
                      try {
                        final dt = DateTime.parse(dateStr).toLocal();
                        final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                        final month = months[dt.month - 1];
                        final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
                        final ampm = dt.hour >= 12 ? "PM" : "AM";
                        final minute = dt.minute.toString().padLeft(2, '0');
                        displayDate = "$month ${dt.day}, ${dt.year}";
                        displayTime = "${hour.toString().padLeft(2, '0')}:$minute $ampm";
                      } catch (_) {
                        displayDate = dateStr;
                      }
                    }
                    final doctorName = appt['doctor_name']?.toString() ?? appt['doctor']?['name']?.toString() ?? "Doctor";
                    final status = appt['status']?.toString() ?? '';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _appointmentCard(
                        title: status.toUpperCase().replaceAll('_', ' '),
                        date: displayDate,
                        time: displayTime,
                        doctor: doctorName,
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _appointmentCard({
    required String title,
    required String date,
    required String time,
    required String doctor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE8F1FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month, color: Color(0xFF2C67FF)),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "$date • $time",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  doctor,
                  style: const TextStyle(
                    color: Color(0xFF2C67FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}