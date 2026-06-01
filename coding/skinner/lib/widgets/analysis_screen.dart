import 'dart:io';
import 'package:flutter/material.dart';
import 'package:skinner/screens/doctors_screenp.dart';

class AnalysisScreen extends StatelessWidget {
  final File? selectedImage;
  final Map<String, dynamic>? analysisResult;

  const AnalysisScreen({
    super.key,
    required this.selectedImage,
    required this.analysisResult,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final disease =
    analysisResult?["predicted_class"] ??
    "No Result";

final confidence =
    (analysisResult?["confidence"] ?? 0.0)
        .toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
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
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.description_outlined),
                    SizedBox(width: 8),
                    Text(
                      "AI Analysis Results",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "AI-Powered",
                    style: TextStyle(
                      color: Color(0xFF2C67FF),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Analysis completed on",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 4),

            const Text(
              "1/28/2026 at 2:15:05 AM",
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            /// Disclaimer
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFAEE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.orange.shade300,
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Medical Disclaimer: This AI analysis is for informational purposes only and should not replace professional medical advice.",
                      style: TextStyle(
                        color: Colors.orange,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Analyzed Image",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: selectedImage != null
                  ? Image.file(
                      selectedImage!,
                      height: width * 0.6,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: width * 0.6,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 60,
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            /// Primary Detection
            const Text(
              "Primary Detection",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                          disease,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Confidence Score",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                               value: confidence,
                      minHeight: 10,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                       "${(confidence * 100).toStringAsFixed(2)}%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "High Confidence",
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Description",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Eczema is a common inflammatory skin condition characterized by dry, itchy, and inflamed skin.",
                    style: TextStyle(height: 1.6),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "AI Recommendations",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text("Keep the affected area moisturized regularly."),
                  ),
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text("Avoid harsh soaps and irritating products."),
                  ),
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text("Consult a dermatologist if symptoms worsen."),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Alternative Detections",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  ListTile(
                    title: Text("Contact Dermatitis"),
                    trailing: Text("72%"),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Psoriasis"),
                    trailing: Text("58%"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F6FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Next Step: Consult a Specialist",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C67FF),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Based on your analysis results, we recommend consulting with a dermatologist specialist for a comprehensive evaluation and personalized treatment plan.",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C67FF),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  "Find Recommended Doctors",
                  style: TextStyle(
                    color: Colors.white,
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