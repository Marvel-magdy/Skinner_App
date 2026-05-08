import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
// تأكد من صحة هذه المسارات في مشروعك
import 'package:skinner/screens/chat_screens.dart'; 
import 'package:skinner/widgets/appoitment_item.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusedDay = DateTime(2026, 2, 10);
  DateTime? _selectedDay = DateTime(2026, 2, 10);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // الخلفية الرمادية الفاتحة جداً
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          /// --- 1. Doctor Information Card ---
          _buildCustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Doctor Information",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    IconButton(
                      onPressed: () => _showEditDoctorDialog(context),
                      icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _buildInfoRow("Name", "Dr.John Doe"),
                _buildInfoRow("Doctor ID", "MD123456"),
                _buildInfoRow("Email", "Drjohn.doe@email.com"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// --- 2. Available Times Card ---
          _buildCustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Available Times", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 15),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Day", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    Text("Time", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                _buildAvailableTimeRow("Sun : Wed", "7 Am : 10 Am"),
                const Divider(height: 25, color: Color(0xFFF0F0F0)),
                _buildAvailableTimeRow("Thu :", "3 pm : 6 pm\n9 Am : 10 Am"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// --- 3. Appointment Schedule Card ---
          _buildCustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Appointment Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 10),
                
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: false,
                    titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: const Color(0xFF2C67FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    todayDecoration: BoxDecoration(
                      color: const Color(0xFFEBF1FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    todayTextStyle: const TextStyle(color: Color(0xFF2C67FF), fontWeight: FontWeight.bold),
                  ),
                ),
                
                const SizedBox(height: 15),
                Row(
                  children: [
                    _buildLegendItem(const Color(0xFF2C67FF), "Appointment Day"),
                    const SizedBox(width: 20),
                    _buildLegendItem(const Color(0xFFEBF1FF), "Today"),
                  ],
                ),
                
                const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),

                const Text("Appointments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),

                // المواعيد (تأكد من وجود Widgets الخاصة بك)
                const AppointmentItem(title: "Follow-up Consultation", time: "February 10, 2026 • 10:00 AM"),
                const AppointmentItem(title: "Skin Check", time: "February 15, 2026 • 2:30 PM"),
                const AppointmentItem(title: "Treatment Review", time: "February 20, 2026 • 11:00 AM"),

                const SizedBox(height: 30),

                /// --- Chat Button ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                    label: const Text("Chat with This Patient", style: TextStyle(color: Colors.white, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C67FF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildCustomCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildAvailableTimeRow(String day, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: const TextStyle(fontSize: 15)),
        Text(time, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, height: 1.4)),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  // --- Edit Dialog Function ---
  void _showEditDoctorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 8),
                        Text("Doctor Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.red, size: 20)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),
                _buildDialogField("Full Name", "Dr John Doe"),
                _buildDialogField("Email", "name@example.com"),
                _buildDialogField("Phone Number", "+1 (555) 000-0000"),
                _buildDialogField("clinic addres", "add"),
                _buildDialogField("Consultation Fee", "150", isPrice: true),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C67FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text("Save Change", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField(String label, String hint, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 5),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              suffixText: isPrice ? "\$" : null,
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}