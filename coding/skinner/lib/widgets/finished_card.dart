import 'package:flutter/material.dart';

class FinishedCard extends StatelessWidget {

  final Map caseData;

  const FinishedCard({
    super.key,
    required this.caseData,
  });

  @override
  Widget build(BuildContext context) {

    double width =
        MediaQuery.of(context)
            .size
            .width;

    double imageSize =
        width * 0.20;

    return Container(

      padding:
          EdgeInsets.all(
              width * 0.04),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
                16),

        border: Border.all(
          color:
              const Color(0xFFE9ECEF),
        ),
      ),

      child: Row(

        children: [

          Container(

            height: imageSize,
            width: imageSize,

            decoration:
                BoxDecoration(

              color:
                  const Color(
                      0xFFEBE3D5),

              borderRadius:
                  BorderRadius.circular(
                      12),
            ),

            child: const Icon(
              Icons
                  .medical_services_outlined,
              color: Colors.brown,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(
                  caseData[
                          "patient_name"] ??
                      "Unknown Patient",

                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Text(
                  caseData[
                          "diagnosis"] ??
                      "Reviewed Case",

                  style:
                      const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(
                    height: 10),

                Row(

                  children: [

                    Container(

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),

                      decoration:
                          BoxDecoration(

                        color:
                            const Color(
                                0xFFD1FAE5),

                        borderRadius:
                            BorderRadius.circular(
                                6),
                      ),

                      child:
                          const Text(
                        'Reviewed',

                        style:
                            TextStyle(
                          color: Color(
                              0xFF059669),

                          fontSize:
                              12,

                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),

                    const SizedBox(
                        width: 8),

                    Text(
                      caseData[
                              "reviewed_at"] ??
                          "",

                      style:
                          TextStyle(
                        color: Colors
                            .grey[600],

                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}