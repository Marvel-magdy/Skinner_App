import 'package:flutter/material.dart';
import 'package:skinner/screens/Payment_Success_Screen.dart';
import 'package:skinner/services/payment_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String appointmentId;
  final String doctorName;
  final double consultationFee;
  final String cardHolderName;
  final String cardLast4;
  final String appointmentDate;

  const OtpVerificationScreen({
    super.key,
    required this.appointmentId,
    required this.doctorName,
    required this.consultationFee,
    required this.cardHolderName,
    required this.cardLast4,
    required this.appointmentDate,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends State<OtpVerificationScreen> {
  final otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [

              /// Back Button

              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                      ),
                    ),
                    const Text(
                      "Back to Appointment Selection",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Main Card

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    /// Header

                    const Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: Colors.green,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Secure Payment",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Your payment information is encrypted and secure",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// OTP SENT BOX

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFF0FDF4),
                        borderRadius:
                            BorderRadius.circular(
                                14),
                        border: Border.all(
                          color: const Color(
                              0xFF86EFAC),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [

                          Row(
                            children: [
                              Icon(
                                Icons
                                    .check_circle_outline,
                                color:
                                    Colors.green,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "OTP Sent!",
                                style:
                                    TextStyle(
                                  color: Colors
                                      .green,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 8),

                          Text(
                            "A 6-digit verification code has been sent to +1 (***) ***-3235",
                            style: TextStyle(
                              color:
                                  Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// OTP TITLE

                    const Row(
                      children: [
                        Icon(
                          Icons.phone_android,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Enter OTP Code",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// OTP FIELD

                    TextField(
                      controller:
                          otpController,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          InputDecoration(
                        hintText: "122233",
                        filled: true,
                        fillColor:
                            const Color(
                                0xFFF3F4F6),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      12),
                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    /// TIMER

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [

                        RichText(
                          text:
                              const TextSpan(
                            style: TextStyle(
                              color:
                                  Colors.grey,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    "Code expires in: ",
                              ),
                              TextSpan(
                                text: "0:28",
                                style:
                                    TextStyle(
                                  color: Colors
                                      .blue,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Resend OTP",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// DEMO BOX

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFFFFBEB),
                        borderRadius:
                            BorderRadius.circular(
                                14),
                        border: Border.all(
                          color: const Color(
                              0xFFFCD34D),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [

                          Row(
                            children: [
                              Icon(
                                Icons
                                    .info_outline,
                                color: Colors
                                    .orange,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Demo Mode:",
                                style:
                                    TextStyle(
                                  color: Colors
                                      .orange,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 8),

                          Text(
                            "Check browser console for OTP code or use:",
                            style: TextStyle(
                              color: Colors
                                  .orange,
                            ),
                          ),

                          SizedBox(height: 8),

                          Text(
                            "859040",
                            style:
                                TextStyle(
                              color: Colors
                                  .orange,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Divider(),

                    const SizedBox(height: 20),

                    /// BUTTON

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child:
                          ElevatedButton.icon(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          try {
                            final paymentService = PaymentService();
                            final payResp = await paymentService.payAppointment(
                              appointmentId: widget.appointmentId,
                              method: 'card',
                              cardHolderName: widget.cardHolderName,
                              cardLast4: widget.cardLast4,
                            );

                            Navigator.pop(context); // dismiss loading

                            final data = payResp['data'] ?? payResp;
                            final chatId = data['chat_id']?.toString() ?? payResp['chat_id']?.toString();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentSuccessScreen(
                                  chatId: chatId,
                                  doctorName: widget.doctorName,
                                  appointmentId: widget.appointmentId,
                                  cardLast4: widget.cardLast4,
                                  amount: widget.consultationFee,
                                  appointmentDate: widget.appointmentDate,
                                ),
                              ),
                            );
                          } catch (e) {
                            Navigator.pop(context); // dismiss loading
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Payment confirmation failed: $e")),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons
                              .check_circle_outline,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Final Payment Confirmation",
                          style: TextStyle(
                            color:
                                Colors.white,
                          ),
                        ),
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                                  0xFF020617),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Center(
                      child: Text(
                        "By confirming this payment, you agree to our Terms of Service and Privacy Policy.",
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// CARDS

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        const Color(0xFFE5E7EB),
                  ),
                ),
                child: const Row(
                  children: [

                    Text(
                      "We accept:",
                    ),

                    SizedBox(width: 12),

                    Chip(
                      label: Text("VISA"),
                    ),

                    SizedBox(width: 8),

                    Chip(
                      label:
                          Text("MASTERCARD"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}