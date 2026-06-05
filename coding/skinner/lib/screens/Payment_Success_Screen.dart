import 'package:flutter/material.dart';
import 'chat_screens.dart';
import 'chat_list_screen.dart';
class PaymentSuccessScreen extends StatelessWidget {
  final String? chatId;
  final String? doctorName;
  final String? appointmentId;
  final String? cardLast4;
  final double? amount;
  final String? appointmentDate;

  const PaymentSuccessScreen({
    super.key,
    this.chatId,
    this.doctorName,
    this.appointmentId,
    this.cardLast4,
    this.amount,
    this.appointmentDate,
  });
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
                  border: Border.all(color: const Color(0xFF22C55E)),
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
                  border: Border.all(color: const Color(0xFFE5E7EB)),
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
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F6FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFC7DAFF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
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
                          const SizedBox(height: 12),
                          Text(
                            appointmentId ?? "TXN17702678630469443",
                            style: const TextStyle(
                              color: Color(0xFF2C67FF),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text("Doctor", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 6),
                    Text(
                      doctorName ?? "Doctor",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Appointment Date & Time", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 6),
                    Text(
                      appointmentDate ?? "Saturday, February 7, 2026 at 09:00 AM",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 20),
                    const Text(
                      "Payment Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text("Card: **** ${cardLast4 ?? '6942'}"),
                    const SizedBox(height: 8),
                    Text(
                      "Amount Paid: EGP ${amount ?? 150}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text("Transaction ID: ${appointmentId ?? 'TXN17702678630469443'}"),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.calendar_month),
                        label: const Text("Add to Calendar"),
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
                  border: Border.all(color: const Color(0xFFE5E7EB)),
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
                        child: Icon(Icons.calendar_today, color: Colors.green),
                      ),
                      title: Text("Calendar Reminder"),
                      subtitle: Text("Add this appointment to your calendar."),
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFFFFFBEB),
                        child: Icon(Icons.access_time, color: Colors.orange),
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
                      subtitle: Text("Bring any relevant medical records."),
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
                  border: Border.all(color: const Color(0xFFE5E7EB)),
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
                      style: TextStyle(color: Colors.grey),
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
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF020617),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Return To Dashboard",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {

                    if (chatId != null && chatId!.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chatId!,
                            title: doctorName ?? 'Doctor',
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatListScreen(),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text("Chat With This Doctor"),
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
