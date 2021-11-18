import 'package:flutter/material.dart';
import 'package:grocery_app_admin/screens/adminUsersScreen.dart';
import 'package:grocery_app_admin/screens/categoryScreen.dart';
import 'package:grocery_app_admin/screens/deliveryBoyScreen.dart';
import 'package:grocery_app_admin/screens/homeScreen.dart';
import 'package:grocery_app_admin/screens/loginScreen.dart';
import 'package:grocery_app_admin/screens/manageBannersScreen.dart';
import 'package:grocery_app_admin/screens/notificationScreen.dart';
import 'package:grocery_app_admin/screens/orderScreen.dart';
import 'package:grocery_app_admin/screens/settingsScreen.dart';
import 'package:grocery_app_admin/screens/splashScreen.dart';
import 'package:grocery_app_admin/screens/vendorScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grocery App Admin Dashboard',
      theme: ThemeData(
        primaryColor: Color(0xFF84c225),
      ),
      home: SplashScreen(),
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
        SplashScreen.id: (context) => SplashScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        BannerScreen.id: (context) => BannerScreen(),
        CategoryScreen.id: (context) => CategoryScreen(),
        OrderScreen.id: (context) => OrderScreen(),
        NotificationScreen.id: (context) => NotificationScreen(),
        AdminUsers.id: (context) => AdminUsers(),
        SettingScreen.id: (context) => SettingScreen(),
        VendorScreen.id: (context) => VendorScreen(),
        DeliveryBoyScreen.id: (context) => DeliveryBoyScreen(),
      },
    );
  }
}

