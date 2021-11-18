import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_delivery/providers/authProvider.dart';
import 'package:provider/provider.dart';

import 'loginScreen.dart';

class ResetPassword extends StatefulWidget {
  static const String id = 'reset-password-screen';
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  var _emailTextController = TextEditingController();
  FocusNode _focusEmail;
  String email;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _focusEmail = FocusNode();
  }

  @override
  void dispose() {
    _focusEmail.dispose();
    super.dispose();
  }

  void _requestFocusEmail() {
    setState(() {
      FocusScope.of(context).requestFocus(_focusEmail);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'images/forgot.png',
                  height: 250,
                ),
                SizedBox(
                  height: 20,
                ),
                RichText(
                    text: TextSpan(text: '', children: [
                  TextSpan(
                      text: 'Forgot Password ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red)),
                  TextSpan(
                      text:
                          'Just enter the email address you\'ve used to register with us and we\'ll send you an email to reset your password',
                      style: TextStyle(color: Colors.red)),
                ])),
                SizedBox(
                  height: 10,
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
                Row(children: [
                  Expanded(
                    // ignore: deprecated_member_use
                    child: FlatButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            _loading = true;
                          });
                          _authData.resetPassword(email);
                          ScaffoldMessenger
                                  .of(context)
                                  .showSnackBar(SnackBar(content: Text('Check your Email ${_emailTextController.text} for reset link')));
                        }
                        Navigator.pushNamed(context, LoginScreen.id);
                      },
                      color: Theme.of(context).primaryColor,
                      child: _loading
                          ? LinearProgressIndicator()
                          : Text(
                              'Reset Password',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}
