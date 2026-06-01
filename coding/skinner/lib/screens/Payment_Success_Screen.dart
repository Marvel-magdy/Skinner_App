import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// SUCCESS CARD

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: const Color(0xFFF0FDF4),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: const Color(0xFF22C55E),
    ),
  ),
  child: Column(
    children: [

      Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle,
          color: Color(0xFF16A34A),
          size: 55,
        ),
      ),

      const SizedBox(height: 24),

      const Text(
        "Payment Successful!",
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF166534),
        ),
      ),

      const SizedBox(height: 16),

      const Text(
        "Your appointment has been confirmed and a confirmation email has been sent.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF166534),
          height: 1.5,
        ),
      ),
    ],
  ),
),

const SizedBox(height: 24),

/// APPOINTMENT CONFIRMATION

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
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Text(
        "Appointment Confirmation",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 8),

      const Text(
        "Please save this information for your records",
        style: TextStyle(
          color: Colors.grey,
        ),
      ),

      const SizedBox(height: 20),

      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F6FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFC7DAFF),
          ),
        ),
        child: const Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  color: Color(0xFF2C67FF),
                ),
                SizedBox(width: 8),
                Text(
                  "Confirmation Number:",
                  style: TextStyle(
                    color: Color(0xFF2C67FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            Text(
              "TXN17702678630469443",
              style: TextStyle(
                color: Color(0xFF2C67FF),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 24),

      const Text(
        "Doctor",
        style: TextStyle(
          color: Colors.grey,
        ),
      ),

      SizedBox(height: 6),

      Text(
        "Dr. Sarah Johnson",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      SizedBox(height: 20),

      Text(
        "Date",
        style: TextStyle(
          color: Colors.grey,
        ),
      ),

      SizedBox(height: 6),

      Text(
        "Saturday, February 7, 2026",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      SizedBox(height: 20),

      Text(
        "Time",
        style: TextStyle(
          color: Colors.grey,
        ),
      ),

      SizedBox(height: 6),

      Text(
        "09:00 AM",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      SizedBox(height: 24),

      Divider(),

      SizedBox(height: 20),

      Text(
        "Payment Details",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),

      SizedBox(height: 12),

      Text("Card: **** 6942"),

      SizedBox(height: 8),

      Text(
        "Amount Paid: \$150",
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),

      SizedBox(height: 8),

      Text(
        "Transaction ID: TXN17702678630469443",
      ),

      SizedBox(height: 24),

      Divider(),

      SizedBox(height: 20),

      SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.calendar_month),
          label: Text("Add to Calendar"),
        ),
      ),
    ],
  ),
),
const SizedBox(height: 24),

/// WHAT'S NEXT

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
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Text(
        "What's Next?",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      SizedBox(height: 20),

      ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFEFF6FF),
          child: Icon(
            Icons.email_outlined,
            color: Color(0xFF2563EB),
          ),
        ),
        title: Text("Confirmation Email"),
        subtitle: Text(
          "You'll receive appointment details via email shortly.",
        ),
      ),

      ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFF0FDF4),
          child: Icon(
            Icons.calendar_today,
            color: Colors.green,
          ),
        ),
        title: Text("Calendar Reminder"),
        subtitle: Text(
          "Add this appointment to your calendar.",
        ),
      ),

      ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFFFFBEB),
          child: Icon(
            Icons.access_time,
            color: Colors.orange,
          ),
        ),
        title: Text("Arrive 15 Minutes Early"),
        subtitle: Text(
          "Please arrive early to complete check-in.",
        ),
      ),

      ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFF5F3FF),
          child: Icon(
            Icons.description_outlined,
            color: Colors.deepPurple,
          ),
        ),
        title: Text("Prepare Your Information"),
        subtitle: Text(
          "Bring any relevant medical records.",
        ),
      ),
    ],
  ),
),

const SizedBox(height: 24),

/// NEED HELP

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
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Text(
        "Need To Make Changes?",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      SizedBox(height: 10),

      Text(
        "Contact us if you need to reschedule or cancel your appointment.",
        style: TextStyle(
          color: Colors.grey,
        ),
      ),

      SizedBox(height: 20),

      Row(
        children: [
          Icon(Icons.phone_outlined),
          SizedBox(width: 10),
          Text("+1 (555) 123-4567"),
        ],
      ),

      SizedBox(height: 12),

      Row(
        children: [
          Icon(Icons.email_outlined),
          SizedBox(width: 10),
          Text("support@skinner.com"),
        ],
      ),
    ],
  ),
),

const SizedBox(height: 24),

/// BUTTONS

SizedBox(
  width: double.infinity,
  height: 55,
  child: ElevatedButton(
    onPressed: () {},
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF020617),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: const Text(
      "Return To Dashboard",
      style: TextStyle(
        color: Colors.white,
      ),
    ),
  ),
),

const SizedBox(height: 12),

SizedBox(
  width: double.infinity,
  height: 55,
  child: OutlinedButton.icon(
    onPressed: () {},
    icon: const Icon(Icons.chat_bubble_outline),
    label: const Text(
      "Chat With This Doctor",
    ),
  ),
),

const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}