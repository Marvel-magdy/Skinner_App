import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../widgets/case_card.dart';

class DoctorPortalScreen extends StatelessWidget {

  const DoctorPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Doctor Portal"),
      ),

      body: Column(
        children: [

          /// Tabs
          Padding(
            padding:
                const EdgeInsets.all(12),

            child: SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal,

              child: Row(
                children: const [

                  Chip(
                      label: Text(
                          "Pending Cases")),

                  SizedBox(width: 8),

                  Chip(
                      label: Text(
                          "Reviewed Cases")),

                  SizedBox(width: 8),

                  Chip(
                      label: Text(
                          "Schedule")),
                ],
              ),
            ),
          ),

          /// List
          Expanded(
            child: ListView.builder(

              padding:
                  const EdgeInsets.all(12),

              itemCount:
                  dummyCases.length,

              itemBuilder:
                  (context, index) {

                final caseItem =
                    dummyCases[index];

                return Padding(
                  padding:
                      const EdgeInsets.only(
                          bottom: 16),

                  child: CaseCard(
                    caseModel:
                        caseItem,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}