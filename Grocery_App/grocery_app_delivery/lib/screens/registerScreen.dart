import 'package:flutter/material.dart';
import 'package:grocery_app_delivery/providers/authProvider.dart';
import 'package:grocery_app_delivery/widgets/imagePicker.dart';
import 'package:grocery_app_delivery/widgets/registerForm.dart';
import 'package:provider/provider.dart';

class RegisterSceen extends StatelessWidget {
  static const String id = 'register-screen';

  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);

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
