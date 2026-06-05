import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skinner/authuntication/signin.dart';


class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  Timer? _timer;
  
  @override
  void initState(){
    super.initState();
    Future.delayed(Duration(seconds: 2), (){
      if(!mounted) return;
      Navigator.pushReplacement(context,
       MaterialPageRoute(builder: (_)=> const SignIn()));
    });
  }
  
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset("assets/AI Skin Disease Identification App.png",fit: BoxFit.cover,),
        
      )
      
      
    );
  }
}