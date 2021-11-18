import 'package:flutter/material.dart';
import 'package:grocery_app/providers/vendor/authVendorProvider.dart';
import 'package:grocery_app/screens/vendor/homeVendorScreen.dart';
import 'package:grocery_app/screens/vendor/registerVendorSceen.dart';
import 'package:grocery_app/screens/vendor/resetPasswordScreen.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';

class LoginVendorScreen extends StatefulWidget {
  static const String id = 'login-vendor-screen';
  @override
  _LoginVendorScreenState createState() => _LoginVendorScreenState();
}

class _LoginVendorScreenState extends State<LoginVendorScreen> {
  final _formKey = GlobalKey<FormState>();
  FocusNode _focusEmail, _focusPassword;
  Icon icon;
  bool _visible = false;
  var _emailTextController = TextEditingController();
  String email;
  String password;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _focusEmail = FocusNode();
    _focusPassword = FocusNode();
  }

  @override
  void dispose() {
    _focusEmail.dispose();
    _focusPassword.dispose();
    super.dispose();
  }

  void _requestFocusEmail() {
    setState(() {
      FocusScope.of(context).requestFocus(_focusEmail);
    });
  }

  void _requestFocusPassword() {
    setState(() {
      FocusScope.of(context).requestFocus(_focusPassword);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthVendorProvider>(context);
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
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'LOGIN',
                            style: TextStyle(fontFamily: 'Anton', fontSize: 30),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Image.asset(
                            'images/logo.png',
                            height: 80,
                          ),
                        ]),
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
                      focusNode: _focusEmail,
                      onTap: _requestFocusEmail,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(),
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Email',
                        prefixIcon: _focusEmail.hasFocus
                            ? Icon(
                                Icons.email_outlined,
                                color: Theme.of(context).primaryColor,
                              )
                            : Icon(
                                Icons.email_outlined,
                                color: Colors.grey,
                              ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 2, color: Theme.of(context).primaryColor)),
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
                      focusNode: _focusPassword,
                      onTap: _requestFocusPassword,
                      obscureText: _visible == false ? true : false,
                      decoration: InputDecoration(
                        suffixIcon: _focusPassword.hasFocus
                            ? IconButton(
                                icon: _visible
                                    ? Icon(Icons.visibility)
                                    : Icon(Icons.visibility_off),
                                color: Theme.of(context).primaryColor,
                                onPressed: () {
                                  setState(() {
                                    _visible = !_visible;
                                  });
                                },
                              )
                            : Icon(
                                Icons.remove_red_eye_outlined,
                                color: Colors.grey,
                              ),
                        enabledBorder: OutlineInputBorder(),
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Password',
                        prefixIcon: _focusPassword.hasFocus
                            ? Icon(
                                Icons.vpn_key_outlined,
                                color: Theme.of(context).primaryColor,
                              )
                            : Icon(
                                Icons.vpn_key_outlined,
                                color: Colors.grey,
                              ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 2, color: Theme.of(context).primaryColor)),
                        focusColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, ResetPassword.id);
                          },
                          child: Text(
                            'Forgot Password ? ',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ]),
                    SizedBox(
                      height: 20,
                    ),
                    Row(children: [
                      Expanded(
                        // ignore: deprecated_member_use
                        child: FlatButton(
                          color: Theme.of(context).primaryColor,
                          child: _loading
                              ? LinearProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                  backgroundColor: Colors.transparent,
                                )
                              : Text(
                                  'Login',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                _loading = true;
                              });
                              _authData
                                  .loginVendor(email, password)
                                  .then((credential) {
                                if (credential != null) {
                                  setState(() {
                                    _loading = false;
                                  });
                                  Navigator.pushReplacementNamed(
                                      context, HomeVendorScreen.id);
                                } else {
                                  setState(() {
                                    _loading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(_authData.error)));
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ]),
                    Row(children: [
                      // ignore: deprecated_member_use
                      FlatButton(
                        padding: EdgeInsets.zero,
                        child: RichText(
                            text: TextSpan(text: '', children: [
                          TextSpan(
                              text: 'Don\'t have an account? ',
                              style: TextStyle(color: Colors.black)),
                          TextSpan(
                              text: 'Register',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.red))
                        ])),
                        onPressed: () {
                          Navigator.pushNamed(context, RegisterVendorSceen.id);
                        },
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
