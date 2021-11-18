import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app_delivery/controllers/firebaseController.dart';
import 'package:grocery_app_delivery/providers/authProvider.dart';
import 'package:grocery_app_delivery/screens/registerScreen.dart';
import 'package:provider/provider.dart';

import 'homeScreen.dart';
import 'resetPasswordScreen.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login-screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseController _controller = FirebaseController();
  final _formKey = GlobalKey<FormState>();
  Icon icon;
  bool _visible = false;
  var _emailTextController = TextEditingController();
  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);

    return SafeArea(
      child: Scaffold(
          body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Center(
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/logo.png',
                              height: 80,
                            ),
                            FittedBox(
                              child: Text(
                                'DELIVERY APP - LOGIN',
                                style: TextStyle(
                                    fontFamily: 'Anton',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                          ]),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _emailTextController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter Email';
                        }
                        final bool _isValid =
                            EmailValidator.validate(_emailTextController.text);
                        if (!_isValid) {
                          return 'Invalid Email';
                        }
                        setState(() {
                          email = value;
                        });
                        return null;
                      },
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(),
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Email',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 2,
                                color: Theme.of(context).primaryColor)),
                        focusColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter Password';
                        }
                        if (value.length < 6) {
                          return 'Minimum 6 characters';
                        }
                        setState(() {
                          password = value;
                        });
                        return null;
                      },
                      obscureText: _visible == false ? true : false,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: _visible
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            setState(() {
                              _visible = !_visible;
                            });
                          },
                        ),
                        enabledBorder: OutlineInputBorder(),
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Password',
                        prefixIcon: Icon(
                          Icons.vpn_key_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 2,
                                color: Theme.of(context).primaryColor)),
                        focusColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    //   Expanded(
                    //     child: InkWell(
                    //       onTap: () {
                    //         Navigator.pushNamed(context, ResetPassword.id);
                    //       },
                    //       child: Text(
                    //         'Forgot Password ? ',
                    //         textAlign: TextAlign.end,
                    //         style: TextStyle(
                    //             color: Colors.blue,
                    //             fontWeight: FontWeight.bold),
                    //       ),
                    //     ),
                    //   ),
                    // ]),
                    SizedBox(
                      height: 20,
                    ),
                    Row(children: [
                      Expanded(
                        // ignore: deprecated_member_use
                        child: FlatButton(
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            'Login',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              EasyLoading.show(status: 'Please wait...');
                              _controller.validateUser(email).then((value) {
                                if (value.exists) {
                                  if (value.data()['password'] == password) {
                                    _authData
                                        .loginBoys(email, password)
                                        .then((credential) {
                                      if (credential != null) {
                                        EasyLoading.showSuccess(
                                                'Logged in successfully')
                                            .then((value) {
                                          Navigator.pushReplacementNamed(
                                              context, HomeScreen.id);
                                        });
                                      } else {
                                        EasyLoading.showInfo(
                                                'Need to complete Registration')
                                            .then((value) {
                                          _authData.getEmail(email);
                                          Navigator.pushNamed(
                                              context, RegisterSceen.id);
                                        });
                                      }
                                    });
                                  } else {
                                    EasyLoading.showError('Incorrect Password');
                                  }
                                } else {
                                  EasyLoading.showError(
                                      '$email does not registered as our Delivery Person');
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      )),
    );
  }
}
