
import 'package:flutter/material.dart';
import 'package:skinner/splashScreen.dart';
void main()
{
  runApp(const Skinner());

}
class Skinner extends StatelessWidget {
  const Skinner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splashscreen(),
    );
  }
}