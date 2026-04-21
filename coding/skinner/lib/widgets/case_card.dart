import 'package:flutter/material.dart';
import '../models/case_model.dart';

class CaseCard extends StatelessWidget {

  final CaseModel caseModel;

  const CaseCard({
    super.key,
    required this.caseModel,
  });

  @override
  Widget build(BuildContext context) {

    final width =
        MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(width * 0.04),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          )
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          /// Image
          ClipRRect(
            borderRadius:
                BorderRadius.circular(14),

            child: Image.network(
              caseModel.image,
              height: width * 0.35,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 12),

          /// Name
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [

              Expanded(
                child: Text(
                  "${caseModel.name} • ${caseModel.age} yrs • ${caseModel.gender}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4),

                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius:
                      BorderRadius.circular(12),
                ),

                child:
                    Text(caseModel.status),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
              "AI Diagnosis: ${caseModel.diagnosis}"),

          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            children: [

              Chip(
                  label: Text(
                      caseModel.level)),

              Chip(
                label: Text(
                    "${caseModel.confidence}% confidence"),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.black,

                padding:
                    const EdgeInsets.symmetric(
                        vertical: 14),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                          14),
                ),
              ),

              onPressed: () {},

              child: const Text(
                  "Review Case"),
            ),
          )
        ],
      ),
    );
  }
}