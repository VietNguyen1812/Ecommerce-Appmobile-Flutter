import 'package:flutter/material.dart';
import 'package:grocery_app/widgets/vendor/imagePicker.dart';
import 'package:grocery_app/widgets/vendor/registerForm.dart';

class RegisterVendorSceen extends StatelessWidget {
  static const String id = 'register-vendor-screen';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  ShopPicCard(),
                  RegisterForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
