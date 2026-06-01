import 'package:flutter/material.dart';

class PendingCard extends StatelessWidget {
  final Map caseData;

  const PendingCard({
    super.key,
    required this.caseData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

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
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [
              Expanded(
                child: Text(
                  "${caseData["patient_name"] ?? "Unknown"}"
                  " • ${caseData["age"] ?? "--"} yrs"
                  " • ${caseData["gender"] ?? "--"}",

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                    fontSize: 14,
                  ),

                  overflow:
                      TextOverflow
                          .ellipsis,
                ),
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.orange[100],

                  borderRadius:
                      BorderRadius
                          .circular(
                              12),
                ),

                child: const Text(
                  "pending",
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    Colors.black,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                          14),
                ),
              ),

              onPressed: () {
                print(caseData);
              },

              child: const Text(
                "Review Case",

                style: TextStyle(
                  color:
                      Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}