import 'package:flutter/material.dart';

class CustomTab extends StatelessWidget {

  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const CustomTab({
    super.key,
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        decoration: BoxDecoration(

          color: isActive
              ? Colors.black
              : Colors.white,

          borderRadius:
              BorderRadius.circular(20),

          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),

        child: Text(

          title,

          style: TextStyle(

            color: isActive
                ? Colors.white
                : Colors.black,

            fontWeight:
                FontWeight.w500,
          ),
        ),
      ),
    );
  }
}