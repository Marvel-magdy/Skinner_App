import 'package:flutter/material.dart';
import 'package:skinner/widgets/finished_card.dart';

class FinishedScreen extends StatelessWidget {

  const FinishedScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return ListView.builder(

      padding: const EdgeInsets.all(16),

      itemCount: 4,

      itemBuilder: (context, index) {

        return const Padding(

          padding:
              EdgeInsets.only(
                  bottom: 12),

          child: FinishedCard(),
        );
      },
    );
  }
}