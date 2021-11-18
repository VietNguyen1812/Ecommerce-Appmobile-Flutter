import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/screens/chat/vendor/chatScreenVendor.dart';
import 'package:grocery_app/screens/vendor/bannerVendorScreen.dart';
import 'package:grocery_app/screens/vendor/couponScreen.dart';
import 'package:grocery_app/screens/vendor/dashboardVendorScreen.dart';
import 'package:grocery_app/screens/vendor/loginVendorScreen.dart';
import 'package:grocery_app/screens/vendor/orderVendorScreen.dart';
import 'package:grocery_app/screens/vendor/productVendorScreen.dart';

class DrawerVendorController {
  Widget drawerScreen(title, context) {
    if (title == 'Dashboard') {
      return MainVendorScreen();
    }

    if (title == 'Messages') {
      return ChatScreenVendor();
    }

    if (title == 'Product') {
      return ProductVendorScreen();
    }

    if (title == 'Banner') {
      return BannerVendorScreen();
    }

    if (title == 'Coupons') {
      return CouponScreen();
    }

    if (title == 'Orders') {
      return OrderVendorScreen();
    }

    if (title == 'LogOut') {
      FirebaseAuth.instance.signOut();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginVendorScreen()));
      });
    }

    return MainVendorScreen();
  }
}
