import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'homeScreen.dart';
import 'loginScreen.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'splash-screen';
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(
        Duration(
          seconds: 3,
        ),(){
      FirebaseAuth.instance.authStateChanges().listen((User user) {
        if(user == null){
          Navigator.pushReplacementNamed(context, LoginScreen.id);
        }else {
          Navigator.pushReplacementNamed(context, HomeScreen.id);
        }
      });
    }
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Image.asset('images/logo.png'),
        Text('Grocery Store - Delivery App',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))
      ]),
    ));
  }
}
