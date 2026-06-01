import 'package:flutter/material.dart';
import 'package:skinner/services/auth_service.dart';

class ReviewCaseScreen extends StatefulWidget {

  final Map caseData;

  const ReviewCaseScreen({

    super.key,
    required this.caseData,

  });

  @override
  State<ReviewCaseScreen> createState() =>
      _ReviewCaseScreenState();
}

class _ReviewCaseScreenState
    extends State<ReviewCaseScreen> {

  final diagnosisController =
      TextEditingController();

  final prescriptionController =
      TextEditingController();

  final notesController =
      TextEditingController();

  bool isLoading = false;

  Future<void> submitReview() async {

    setState(() {
      isLoading = true;
    });

    try {

      await AuthService().reviewCase(

        token: adminToken!,

        appointmentId:
            widget.caseData["appointment_id"],

        diagnosis:
            diagnosisController.text,

        prescription:
            prescriptionController.text,

        notes:
            notesController.text,

      );

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
              Text("Case reviewed successfully"),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(e.toString()),
        ),
      );

    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF8F9FA),

      appBar: AppBar(

        backgroundColor: Colors.white,

        elevation: 0,

        title: const Text(

          "Review Case",

          style: TextStyle(
            color: Colors.black,
          ),
        ),

        iconTheme:
            const IconThemeData(
          color: Colors.black,
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Container(

              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  ClipRRect(

                    borderRadius:
                        BorderRadius.circular(12),

                    child: Image.asset(

                      "assets/Container.png",

                      height: 200,

                      width: double.infinity,

                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(

                    widget.caseData["patient_name"]
                        .toString(),

                    style: const TextStyle(

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.caseData.toString(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Diagnosis",
            ),

            const SizedBox(height: 8),

            TextField(

              controller:
                  diagnosisController,

              maxLines: 3,

              decoration: InputDecoration(

                filled: true,

                fillColor: Colors.white,

                border: OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(12),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Prescription",
            ),

            const SizedBox(height: 8),

            TextField(

              controller:
                  prescriptionController,

              maxLines: 3,

              decoration: InputDecoration(

                filled: true,

                fillColor: Colors.white,

                border: OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(12),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Notes",
            ),

            const SizedBox(height: 8),

            TextField(

              controller:
                  notesController,

              maxLines: 4,

              decoration: InputDecoration(

                filled: true,

                fillColor: Colors.white,

                border: OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(12),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(

              width: double.infinity,

              height: 55,

              child: ElevatedButton(

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      Colors.black,

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),

                onPressed:
                    isLoading
                        ? null
                        : submitReview,

                child:
                    isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(

                            "Submit Review",

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