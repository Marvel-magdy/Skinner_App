import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {

  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        leading:
            const BackButton(),

        title: const Text(
            "Karim Ali"),

        actions: [

          Container(

            margin:
                const EdgeInsets
                    .only(
                        right: 12),

            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 10,
              vertical: 6,
            ),

            decoration: BoxDecoration(
              color:
                  Colors.green.shade100,

              borderRadius:
                  BorderRadius.circular(
                      12),
            ),

            child: const Text(
              "Secure",
              style:
                  TextStyle(
                      color:
                          Colors.green),
            ),
          )
        ],
      ),

      body: Column(

        children: [

          Container(
            width:
                double.infinity,

            padding:
                const EdgeInsets.all(
                    8),

            color:
                Colors.blue.shade50,

            child: const Text(
              "End-to-end encrypted conversation. Your privacy is protected.",
            ),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {},

            child:
                const Text("Write Report"),
          ),

          const Spacer(),

          Padding(
            padding:
                const EdgeInsets.all(
                    12),

            child: Row(

              children: [

                Expanded(

                  child:
                      TextField(

                    decoration:
                        InputDecoration(

                      hintText:
                          "Type your message...",

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                                12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                    width: 8),

                Container(

                  decoration:
                      BoxDecoration(
                    color: const Color(
                        0xFF2C67FF),

                    borderRadius:
                        BorderRadius.circular(
                            12),
                  ),

                  child: IconButton(
                    icon: const Icon(
                        Icons.send,
                        color: Colors.white),

                    onPressed: () {},
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}