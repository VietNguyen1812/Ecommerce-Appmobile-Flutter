import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app_delivery/screens/homeScreen.dart';
import 'package:grocery_app_delivery/screens/loginScreen.dart';
import 'package:grocery_app_delivery/screens/registerScreen.dart';
import 'package:grocery_app_delivery/screens/resetPasswordScreen.dart';
import 'package:provider/provider.dart';

import 'providers/authProvider.dart';
import 'screens/splashScreen.dart';

void main() async{
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grocery Store Delivery App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      builder: EasyLoading.init(),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        ResetPassword.id: (context) => ResetPassword(),
        RegisterSceen.id: (context) => RegisterSceen(),
      },
    );
  }
}

