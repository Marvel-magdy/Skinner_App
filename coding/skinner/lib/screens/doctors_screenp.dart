import 'package:flutter/material.dart';
import 'package:skinner/screens/appointment_screen.dart';
import 'package:skinner/services/auth_service.dart';

class DoctorsScreen extends StatefulWidget {
  final Function(Map doctor) onBookAppointment;

  const DoctorsScreen({
    super.key,
    required this.onBookAppointment,
  });

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  List doctors = [];
bool isLoading = true;
@override
void initState() {
  super.initState();
  getDoctors();
}

Future<void> getDoctors() async {

  try {

    final response =
        await AuthService()
            .getDoctors(

      token: adminToken!,
    );

    setState(() {

      doctors =
          response.data["data"];

      isLoading = false;

    });

  } catch (e) {

    print(e);

    setState(() {

      isLoading = false;

    });
  }
}
  @override
  Widget build(BuildContext context) {
if (isLoading) {

  return const Center(
    child: CircularProgressIndicator(),
  );
}   

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recommended Specialists",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

         /* const Text(
            'Based on your diagnosis of "Eczema (Atopic Dermatitis)", we recommend these verified dermatology specialists',
            style: TextStyle(
              color: Colors.grey,
              height: 1.5,
            ),
          ),*/

          const SizedBox(height: 20),

          ...doctors.map(
            (doctor) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
child: DoctorCard(
  doctor: doctor,
  onBookAppointment: widget.onBookAppointment,
),            ),
          ),
        ],
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Map doctor;
  final Function(Map doctor) onBookAppointment;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onBookAppointment,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
         
         Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
   CircleAvatar(
  radius: 38,
  backgroundColor: const Color(0xFFDDEAFE),
  child: Text(
    doctor["name"] != null &&
            doctor["name"].toString().isNotEmpty
        ? doctor["name"]
            .toString()[0]
            .toUpperCase()
        : "D",
    style: const TextStyle(
      color: Color(0xFF2563EB),
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
  ),
),
    const SizedBox(width: 12),

    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            doctor["name"],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            doctor["specialization"],
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ),

    const SizedBox(width: 8),

    Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "Verified",
        style: TextStyle(
          color: Colors.green,
          fontSize: 12,
        ),
      ),
    ),
  ],
),

          const SizedBox(height: 16),

          Row(
  children: [
    const Icon(
      Icons.star,
      color: Colors.amber,
      size: 18,
    ),
    const SizedBox(width: 6),
    Expanded(
      child: Text(
        'no rated yet',
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.work_outline,
                size: 18,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
  '${doctor["year_of_experience"] ?? 0} years experience',
),
            ],
          ),

          const SizedBox(height: 12),

         Row(
  children: [
    const Icon(
      Icons.location_on_outlined,
      size: 18,
      color: Colors.grey,
    ),
    const SizedBox(width: 6),
    Expanded(
      child: Text(
        doctor["clinic_address"] ?? "No Address",
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
),

          const SizedBox(height: 12),

          const Row(
            children: [
              Icon(
                Icons.access_time,
                size: 18,
                color: Colors.grey,
              ),
              SizedBox(width: 6),
              Text("Available today"),
            ],
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              DoctorChip(text: "MD"),
              DoctorChip(text: "Harvard Medical School"),
              DoctorChip(text: "English"),
              DoctorChip(text: "Spanish"),
            ],
          ),

          const SizedBox(height: 20),

          Text(
  '\$${doctor["consultation_fee"] ?? "0"}',
  style: const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Color(0xFF2563EB),
  ),
),

          const SizedBox(height: 6),

      

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
  onBookAppointment(doctor);
},
              icon: const Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 18,
              ),
              label: const Text(
                "Book Appointment",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF020617),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorChip extends StatelessWidget {
  final String text;

  const DoctorChip({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
        ),
      ),
    );
  }
}