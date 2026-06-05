import 'package:flutter/material.dart';
import 'package:skinner/screens/otp_verification_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String appointmentId;
  final String doctorName;
  final double consultationFee;
  final String appointmentDate;

  const PaymentScreen({
    super.key,
    required this.appointmentId,
    required this.doctorName,
    required this.consultationFee,
    required this.appointmentDate,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final cardNumberController = TextEditingController();
  final cardHolderController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();

  bool saveCard = false;

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
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Text(
                      "Back to Appointment Selection",
                      style: TextStyle(
                        fontSize: 15,
                      ),
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
                  borderRadius: BorderRadius.circular(20),
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

                    const SizedBox(height: 10),

                    const Text(
                      "Your payment information is encrypted and secure",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// PCI Box

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(
                            0xFFF0FDF4),
                        borderRadius:
                            BorderRadius.circular(
                                16),
                        border: Border.all(
                          color: const Color(
                              0xFF86EFAC),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: Colors.green,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  "PCI DSS Compliant",
                                  style: TextStyle(
                                    color:
                                        Colors.green,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "All transactions are encrypted using industry-standard 256-bit SSL encryption. Your card details are never stored on our servers.",
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Card Number

                    const Text(
                      "Card Number",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller:
                          cardNumberController,
                      decoration:
                          InputDecoration(
                        hintText:
                            "1234 5678 9012 3456",
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

                    const SizedBox(height: 18),

                    /// Card Holder

                    const Text(
                      "Cardholder Name",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller:
                          cardHolderController,
                      decoration:
                          InputDecoration(
                        hintText:
                            "JOHN DOE",
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

                    const SizedBox(height: 18),

                    Row(
                      children: [

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [

                              const Text(
                                  "Expiry Date"),

                              const SizedBox(
                                  height: 8),

                              TextField(
                                controller:
                                    expiryController,
                                decoration:
                                    InputDecoration(
                                  hintText:
                                      "MM/YY",
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
                                        BorderSide
                                            .none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [

                              const Text("CVV"),

                              const SizedBox(
                                  height: 8),

                              TextField(
                                controller:
                                    cvvController,
                                decoration:
                                    InputDecoration(
                                  hintText: "123",
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
                                        BorderSide
                                            .none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    CheckboxListTile(
                      value: saveCard,
                      contentPadding:
                          EdgeInsets.zero,
                      title: const Text(
                        "Securely save this card for future appointments",
                      ),
                      onChanged: (value) {
                        setState(() {
                          saveCard =
                              value ?? false;
                        });
                      },
                    ),

                    const Divider(height: 35),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final cardNum = cardNumberController.text.replaceAll(' ', '').trim();
                          final cardHolder = cardHolderController.text.trim();
                          if (cardNum.isEmpty || cardHolder.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please fill in card details.")),
                            );
                            return;
                          }
                          final cardLast4 = cardNum.length >= 4 ? cardNum.substring(cardNum.length - 4) : cardNum;
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OtpVerificationScreen(
                                appointmentId: widget.appointmentId,
                                doctorName: widget.doctorName,
                                consultationFee: widget.consultationFee,
                                cardHolderName: cardHolder,
                                cardLast4: cardLast4,
                                appointmentDate: widget.appointmentDate,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.lock,
                          color: Colors.white,
                        ),
                        label: Text(
                          "Confirm Payment - EGP ${widget.consultationFee}",
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        style:
                            ElevatedButton.styleFrom(
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Cards

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