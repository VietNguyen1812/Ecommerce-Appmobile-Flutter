import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/controllers/userController.dart';
import 'package:grocery_app/screens/customer/landingScreen.dart';
import 'package:grocery_app/screens/customer/mainScreen.dart';
import 'package:grocery_app/screens/welcomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'splash-screen';
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  User user = FirebaseAuth.instance.currentUser;
  StreamSubscription<User> _listener;

  @override
  void initState() {
    Timer(
        Duration(
          seconds: 3,
        ),(){
      _listener = FirebaseAuth.instance.authStateChanges().listen((User user) {
        if(user == null){
          Navigator.pushReplacementNamed(context, WelcomeScreen.id);
        }else {
          getUserData();
        }
      });
    }
    );
    super.initState();
  }
  
  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }

  getUserData() async{
    UserController _userController = UserController();
    _userController.getUserById(user.uid).then((result) {
      //check location details has exist or not
      if(result.data()['address'] != null) {
        updatePrefs(result);
      }
      Navigator.pushReplacementNamed(context, LandingScreen.id);
    });
  }

  Future<void> updatePrefs(result) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('latitude', result['latitude']);
    prefs.setDouble('longitude', result['longitude']);
    prefs.setString('address', result['address']);
    prefs.setString('location', result['location']);
    Navigator.pushReplacementNamed(context, MainScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('images/logo.png'),
                Text('Grocery Store', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))
              ]
          ),
        )
    );
  }
}