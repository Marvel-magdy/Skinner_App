import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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

final TextEditingController nameController =
    TextEditingController(text: "John Doe");

final TextEditingController addressController =
    TextEditingController(text: "Downtown");

final TextEditingController emailController =
    TextEditingController(
      text: "john.doe@email.com",
    );
    void _showEditProfileDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// Header
                Row(
                  children: [

                    const Icon(
                      Icons.edit_outlined,
                      size: 20,
                    ),

                    const SizedBox(width: 8),

                    const Expanded(
                      child: Text(
                        "Patient Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF2C67FF),
                      ),
                    ),
                  ],
                ),

                const Divider(),

                const SizedBox(height: 15),

                /// Full Name
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Full Name",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                /// Email
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                /// Phone
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Phone Number",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                TextField(
                  decoration: InputDecoration(
                    hintText: "+1 (555) 000-0000",
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                /// Address
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Address",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// Buttons
                Row(
                  children: [

                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(
                              0xFF2C67FF,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                          onPressed: () {
                            setState(() {});
                            Navigator.pop(
                              context,
                            );
                          },
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: OutlinedButton(
                          style:
                              OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color:
                                  Color(0xFF2C67FF),
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(
                              context,
                            );
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color:
                                  Color(0xFF2C67FF),
                            ),
                          ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          /// Patient Information
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
              ),
            ),
            child: Column(
              children: [

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [

                    const Text(
                      "Patient Information",
                      style: TextStyle(
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
  label: const Text("Edit"),
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

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "John Doe",
                    style: TextStyle(
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

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Downtown",
                    style: TextStyle(
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

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "john.doe@email.com",
                    style: TextStyle(
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                const Text(
                  "Appointment Schedule",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2035, 12, 31),
                  focusedDay: _focusedDay,

                  selectedDayPredicate: (day) {
                    return isSameDay(
                      _selectedDay,
                      day,
                    );
                  },

                  onDaySelected:
                      (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },

                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),

                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration:
                        const BoxDecoration(
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
              ),
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

                _appointmentCard(
                  title: "Follow-up Consultation",
                  date: "February 10, 2026",
                  time: "10:00 AM",
                  doctor: "Dr. Karim",
                ),

                const SizedBox(height: 12),

                _appointmentCard(
                  title: "Skin Check",
                  date: "February 15, 2026",
                  time: "2:30 PM",
                  doctor: "Dr. Ahmed",
                ),

                const SizedBox(height: 12),

                _appointmentCard(
                  title: "Treatment Review",
                  date: "February 20, 2026",
                  time: "11:00 AM",
                  doctor: "Dr. Samir",
                ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FF),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month,
              color: Color(0xFF2C67FF),
            ),
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