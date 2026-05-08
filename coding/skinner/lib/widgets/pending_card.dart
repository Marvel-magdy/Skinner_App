import 'package:flutter/material.dart';

class PendingCard extends StatelessWidget {

  const PendingCard({super.key});

  @override
  Widget build(BuildContext context) {

    double width =
        MediaQuery.of(context)
            .size
            .width;

    return Container(

      padding:
          EdgeInsets.all(
              width * 0.04),

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
                BorderRadius.circular(
                    14),

            child: Image.asset(

              "assets/Container.png",

              height:
                  width * 0.40,

              width:
                  double.infinity,

              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 10),

          Row(

            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [

              Flexible(

                child: Text(

                  "John D. • 34 yrs • Male",

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w600,
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

                child:
                    const Text(
                        "pending"),
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

              onPressed: () {},

              child: const Text(
                "Review Case",
                style: TextStyle(
                    color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}