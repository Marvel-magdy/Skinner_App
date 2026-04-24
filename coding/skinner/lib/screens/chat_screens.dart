import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {

  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
            const Text("AI Health Assistant"),
      ),

      body: Column(
        children: [

          const Expanded(
            child: Center(
              child: Text(
                "Hello! How can I help you?",
              ),
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.all(12),

            child: Row(
              children: [

                Expanded(
                  child: TextField(

                    decoration:
                        InputDecoration(

                      hintText:
                          "Type message...",

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                                12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  onPressed: () {},

                  icon: const Icon(
                      Icons.send),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}