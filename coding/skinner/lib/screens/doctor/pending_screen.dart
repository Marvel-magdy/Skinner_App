import 'package:flutter/material.dart';
import 'package:skinner/widgets/pending_card.dart';

class PendingScreen extends StatelessWidget {

  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return ListView.builder(

      padding: const EdgeInsets.all(16),

      itemCount: 2,

      itemBuilder: (context, index) {

        return const Padding(

          padding:
              EdgeInsets.only(
                  bottom: 16),

          child: PendingCard(),
        );
      },
    );
  }
}