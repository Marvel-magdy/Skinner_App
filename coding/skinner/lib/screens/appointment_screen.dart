import 'package:flutter/material.dart';
import 'package:skinner/screens/payment_screen.dart';
import 'package:skinner/services/auth_service.dart';
class AppointmentScreen extends StatefulWidget {
  final Map doctor;
  final VoidCallback onBack;

  const AppointmentScreen({
    super.key,
    required this.doctor,
        required this.onBack,

  });

  @override
  State<AppointmentScreen> createState() =>
      _AppointmentScreenState();
}

class _AppointmentScreenState
    extends State<AppointmentScreen> {
  int selectedDateIndex = 0;
  int selectedTimeIndex = 0;
  List dates = [];

bool isLoadingDates = true;

  List times = [];
  bool isLoadingSlots = false;
@override
void initState() {

  super.initState();

  getDates();
}
Future<void> getDates() async {


  try {

    final response =
        await AuthService()
            .getAvailableDates(

      token: adminToken!,

      doctorId: widget.doctor[
          "medical_syndicate_id_card"],

    );

    setState(()  {

      dates =
          response.data["data"];
          
          
          print(dates);

      isLoadingDates = false;

    });
    if (dates.isNotEmpty) {
      print("CALLING GET SLOTS");
  await getSlots(
    dates[0]["date"],
  );
}

  } catch (e) {

    print(e);

    setState(() {

      isLoadingDates = false;

    });
  }
}
Future<void> getSlots(String date) async {
print("GET SLOTS STARTED");
  try {

    setState(() {
      isLoadingSlots = true;
    });

    final response =
        await AuthService()
            .getAvailableSlots(

      token: adminToken!,

      doctorId: widget.doctor[
          "medical_syndicate_id_card"],

      date: date,
    );
    print("SLOTS RESPONSE:");
print(response.data);

print("TIMES:");
print(response.data["slots"]);

    setState(() {

      times =
          response.data["slots"];

      isLoadingSlots = false;

      selectedTimeIndex = 0;

    });

  } catch (e) {

    print(e);

    setState(() {

      isLoadingSlots = false;

    });
  }
}
  @override
  Widget build(BuildContext context) {
    print(times);
    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Back
          Align(
  alignment: Alignment.centerLeft,
  child: GestureDetector(
    onTap: widget.onBack,
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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

                   CircleAvatar(
  radius: 28,
  backgroundColor: const Color(0xFFDDEAFE),
  child: Text(
    widget.doctor["name"]
        .toString()
        .split(" ")
        .take(2)
        .map((e) => e[0])
        .join()
        .toUpperCase(),
    style: const TextStyle(
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
                        '\$${widget.doctor["consultation_fee"]}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                       Text(
                       ' \$${widget.doctor["consultation_fee"]}',
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

getSlots(
  dates[index]["date"],
);
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
    dates[index]["day_name"] ?? "",
    style: const TextStyle(
      color: Colors.grey,
    ),
  ),

  const SizedBox(height: 6),

  Text(
    dates[index]["date"]
        .toString()
        .substring(8, 10),
    style: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  ),

  Text(
    dates[index]["date"]
        .toString()
        .substring(5, 7),
    style: const TextStyle(
      color: Colors.grey,
    ),
  ),
],)
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
    times[index]["status"] ==
        "available";

          return GestureDetector(
           onTap: () {

  if (times[index]["status"] !=
      "available") {
    return;
  }

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
  times[index]["time"]?.toString() ?? "",
  style: TextStyle(
    color: available
        ? Colors.black
        : Colors.grey,
  ),
),

      const SizedBox(height: 4),
Text(
  times[index]["status"]?.toString() ?? "",
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
  times.isNotEmpty
      ? times[selectedTimeIndex]["time"]
            ?.toString() ??
          ""
      : "No Time Selected",
),
        ],
      ),

      const SizedBox(height: 12),

      Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 18,
            color: Color(0xFF2C67FF),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
             widget.doctor["clinic_address"] ?? "No Address"
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      Text(
        ' \$${widget.doctor["consultation_fee"]}',
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

