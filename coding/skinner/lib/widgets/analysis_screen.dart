import 'dart:io';
import 'package:flutter/material.dart';
import 'package:skinner/models/analysis_result.dart';
import 'package:intl/intl.dart';

class AnalysisScreen extends StatelessWidget {
  final File? selectedImage;
  final AnalysisResult? analysisResult;
  final VoidCallback? onFindDoctors; // callback to switch to Doctors tab

  const AnalysisScreen({
    super.key,
    required this.selectedImage,
    required this.analysisResult,
    this.onFindDoctors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final borderColor = theme.dividerColor;
    final width = MediaQuery.of(context).size.width;
    
    if (analysisResult == null) {
      return const Center(child: Text('No analysis result available'));
    }
    
    final disease = analysisResult!.predictedClass;
    final confidence = analysisResult!.confidence;
    final confidenceLabel = analysisResult!.confidenceLabel;
    final description = analysisResult!.description;
    final recommendations = analysisResult!.recommendations;
    final alternatives = analysisResult!.alternatives;
    final formattedDate = DateFormat('M/d/yyyy \'at\' h:mm:ss a').format(analysisResult!.analyzedAt);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
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
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE8F1FF),
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

            Text(
              formattedDate,
              style: const TextStyle(
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
                  // Fresh analysis — show local file
                  ? Image.file(
                      selectedImage!,
                      height: width * 0.6,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : analysisResult!.imageUrl.isNotEmpty
                      // History item — load from network
                      ? Image.network(
                          'http://187.127.227.63${analysisResult!.imageUrl}',
                          height: width * 0.6,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: width * 0.6,
                              color: theme.dividerColor,
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                              errorBuilder: (context, error, stackTrace) =>
                              Container(height: width * 0.6, color: theme.dividerColor,
                                child: const Center(child: Icon(Icons.broken_image_outlined, size: 60, color: Colors.grey))),
                        )
                      : Container(height: width * 0.6, color: theme.dividerColor,
                          child: const Center(child: Icon(Icons.image_outlined, size: 60, color: Colors.grey))),
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
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(disease, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

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
                      color: _getConfidenceBgColor(confidenceLabel),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$confidenceLabel Confidence",
                      style: TextStyle(
                        color: _getConfidenceTextColor(confidenceLabel),
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

                  Text(
                    description,
                    style: const TextStyle(height: 1.6),
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
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: recommendations.map((recommendation) {
                  return ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(recommendation),
                  );
                }).toList(),
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
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(16),
              ),
              child: alternatives.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No alternative detections available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Column(
                      children: [
                        for (int i = 0; i < alternatives.length; i++) ...[
                          ListTile(
                            title: Text(alternatives[i].condition),
                            trailing: Text(
                              "${(alternatives[i].confidence * 100).toStringAsFixed(1)}%",
                            ),
                          ),
                          if (i < alternatives.length - 1) const Divider(),
                        ],
                      ],
                    ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onFindDoctors,
                icon: const Icon(Icons.search_rounded, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C67FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                label: const Text(
                  "Find Recommended Doctors",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get background color for confidence badge
  Color _getConfidenceBgColor(String label) {
    switch (label) {
      case 'High':
        return const Color(0xFFD1FAE5); // green
      case 'Medium':
        return const Color(0xFFFEF3C7); // amber
      case 'Low':
        return const Color(0xFFFEE2E2); // red
      default:
        return const Color(0xFFF3F4F6); // gray
    }
  }

  /// Get text color for confidence badge
  Color _getConfidenceTextColor(String label) {
    switch (label) {
      case 'High':
        return const Color(0xFF059669); // green
      case 'Medium':
        return const Color(0xFFD97706); // amber
      case 'Low':
        return const Color(0xFFDC2626); // red
      default:
        return const Color(0xFF6B7280); // gray
    }
  }
}