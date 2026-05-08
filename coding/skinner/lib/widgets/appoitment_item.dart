import 'package:flutter/material.dart';

class AppointmentItem extends StatelessWidget {

  final String title;
  final String time;
  final bool isActive;

  const AppointmentItem({
    super.key,
    required this.title,
    required this.time,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      margin:
          const EdgeInsets.only(
              bottom: 10),

      padding:
          const EdgeInsets.all(12),

      decoration: BoxDecoration(

        color: isActive
            ? Colors.green.shade50
            : Colors.grey.shade200,

        borderRadius:
            BorderRadius.circular(12),

        border: isActive
            ? Border.all(
                color: Colors.green)
            : null,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(title),

          const SizedBox(height: 4),

          Text(
            time,
            style: const TextStyle(
                color: Colors.grey),
          ),
        ],
      ),
    );
  }
}