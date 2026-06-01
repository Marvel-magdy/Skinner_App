import 'package:flutter/material.dart';
import 'package:skinner/screens/payment_screen.dart';
class AppointmentScreen extends StatefulWidget {
  final Map doctor;

  const AppointmentScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<AppointmentScreen> createState() =>
      _AppointmentScreenState();
}

class _AppointmentScreenState
    extends State<AppointmentScreen> {
  int selectedDateIndex = 3;
  int selectedTimeIndex = 1;

  final List<Map<String, String>> dates = [
    {"day": "Today", "date": "4", "month": "Feb"},
    {"day": "Thu", "date": "5", "month": "Feb"},
    {"day": "Fri", "date": "6", "month": "Feb"},
    {"day": "Sat", "date": "7", "month": "Feb"},
    {"day": "Sun", "date": "8", "month": "Feb"},
    {"day": "Mon", "date": "9", "month": "Feb"},
    {"day": "Tue", "date": "10", "month": "Feb"},
  ];

  final List<Map<String, dynamic>> times = [
  {"time": "09:00 AM", "available": true},
  {"time": "09:30 AM", "available": true},
  {"time": "10:00 AM", "available": false},
  {"time": "10:30 AM", "available": false},
  {"time": "11:00 AM", "available": true},
  {"time": "11:30 AM", "available": true},
  {"time": "02:00 PM", "available": true},
  {"time": "02:30 PM", "available": false},
  {"time": "03:00 PM", "available": true},
  {"time": "03:30 PM", "available": true},
];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Back
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: const [
                  Icon(Icons.arrow_back, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Back to Doctors",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Doctor Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                children: [

                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFDDEAFE),
                    child: Text(
                      "DSJ",
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          widget.doctor["name"] ?? "",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          widget.doctor["specialization"] ?? "",
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
  children: const [
    Icon(
      Icons.location_on_outlined,
      size: 16,
      color: Colors.grey,
    ),
    SizedBox(width: 4),
    Expanded(
      child: Text(
        "Medical Center Downtown",
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey,
        ),
      ),
    ),
  ],
)
                      ],
                    ),
                  ),

                  Column(
                    children: [

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Verified",
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        '\$${widget.doctor["fee"]}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const Text(
                        "consultation fee",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            /// Select Date
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: const Color(0xFFE5E7EB),
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Row(
        children: [
          Icon(Icons.calendar_today_outlined),
          SizedBox(width: 8),
          Text(
            "Select Date",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      const SizedBox(height: 8),

      const Text(
        "Choose an available date for your appointment",
        style: TextStyle(
          color: Colors.grey,
        ),
      ),

      const SizedBox(height: 20),

      GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: dates.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.8,
        ),
        itemBuilder: (context, index) {

          bool selected =
              selectedDateIndex == index;
              

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDateIndex = index;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF2C67FF)
                      : Colors.grey.shade300,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [

                  Text(
                    dates[index]["day"]!,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    dates[index]["date"]!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Text(
                    dates[index]["month"]!,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ],
  ),
),

const SizedBox(height: 20),

/// Time Slot
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: const Color(0xFFE5E7EB),
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Row(
        children: [
          Icon(Icons.access_time),
          SizedBox(width: 8),
          Text(
            "Select Time Slot",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      const SizedBox(height: 8),

      const Text(
        "Available time slots",
        style: TextStyle(
          color: Colors.grey,
        ),
      ),

      const SizedBox(height: 20),

      GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: times.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.4,
        ),
        itemBuilder: (context, index) {

          bool selected =
              selectedTimeIndex == index;
              bool available =
                   times[index]["available"];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedTimeIndex = index;
              });
            },
            child: Container(
  alignment: Alignment.center,
  decoration: BoxDecoration(
    color: available
        ? Colors.white
        : Colors.grey.shade100,
    borderRadius:
        BorderRadius.circular(12),
    border: Border.all(
      color: selected
          ? const Color(0xFF2C67FF)
          : Colors.grey.shade300,
    ),
  ),
  child: Column(
    mainAxisAlignment:
        MainAxisAlignment.center,
    children: [

      Text(
        times[index]["time"],
        style: TextStyle(
          color: available
              ? Colors.black
              : Colors.grey,
        ),
      ),

      const SizedBox(height: 4),

      Text(
        available
            ? "Available"
            : "Unavailable",
        style: TextStyle(
          fontSize: 11,
          color: available
              ? Colors.green
              : Colors.red,
        ),
      ),
    ],
  ),
),
          );
        },
      ),
    ],
  ),
),

const SizedBox(height: 20),
/// Appointment Summary
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: const Color(0xFFF1F6FF),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: const Color(0xFFC7DAFF),
    ),
  ),
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [

      const Text(
        "Appointment Summary",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C67FF),
        ),
      ),

      const SizedBox(height: 16),

      Row(
        children: const [
          Icon(
            Icons.calendar_today,
            size: 18,
            color: Color(0xFF2C67FF),
          ),
          SizedBox(width: 10),
          Text("Sat, Feb 7"),
        ],
      ),

      const SizedBox(height: 12),

      Row(
        children: [
          const Icon(
            Icons.access_time,
            size: 18,
            color: Color(0xFF2C67FF),
          ),
          const SizedBox(width: 10),
          Text(
  times[selectedTimeIndex]["time"],
),
        ],
      ),

      const SizedBox(height: 12),

      const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 18,
            color: Color(0xFF2C67FF),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "In-person at Medical Center Downtown",
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      Text(
        '\$${widget.doctor["fee"]} consultation fee',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 20),

      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFC7DAFF),
          ),
        ),
        child: const Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Icon(
              Icons.info_outline,
              color: Colors.black54,
            ),

            SizedBox(width: 10),

            Expanded(
              child: Text(
                "You'll be redirected to a secure payment page to complete your booking. No charges will be made until you confirm the payment.",
                style: TextStyle(
                  color: Color(0xFF2C67FF),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

const SizedBox(height: 20),

SizedBox(
  width: double.infinity,
  height: 55,
  child: ElevatedButton(
    onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const PaymentScreen(),
    ),
  );
},
    style: ElevatedButton.styleFrom(
      backgroundColor:
          const Color(0xFF020617),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),
    ),
    child: const Text(
      "Proceed to Payment",
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    ),
  ),
),

],
),
),
);
}

}

