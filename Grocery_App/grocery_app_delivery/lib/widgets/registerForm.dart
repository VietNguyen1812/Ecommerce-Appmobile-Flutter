import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_delivery/providers/authProvider.dart';
import 'package:grocery_app_delivery/screens/homeScreen.dart';
import 'package:grocery_app_delivery/screens/loginScreen.dart';
import 'package:provider/provider.dart';

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  var _emailTextController = TextEditingController();
  var _passwordTextController = TextEditingController();
  var _cPasswordTextController = TextEditingController();
  var _addressTextController = TextEditingController();
  var _nameTextController = TextEditingController();
  String email;
  String password;
  String name;
  String mobile;
  bool _isLoading = false;

  Future<String> uploadFile(filePath) async {
    File file =
        File(filePath); //need file to upload, we already have inside provider

    FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      await _storage
          .ref('boyProfilePic/${_nameTextController.text}')
          .putFile(file);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print(e.code);
    }
    //now after upload file we need to file url path to save in database
    String downloadURL = await _storage
        .ref('boyProfilePic/${_nameTextController.text}')
        .getDownloadURL();
    return downloadURL;
  }

  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    setState(() {
      _emailTextController.text = _authData.email;
      email = _authData.email;
    });
    scaffordMessage(message) {
      return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    return _isLoading
        ? CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          )
        : Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Name';
                      }
                      setState(() {
                        _nameTextController.text = value;
                      });
                      setState(() {
                        name = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                      labelText: 'Name',
                      labelStyle:
                          TextStyle(color: Theme.of(context).primaryColor),
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    maxLength: 9,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Mobile Number';
                      }
                      setState(() {
                        mobile = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixText: '+84',
                      prefixIcon: Icon(
                        Icons.phone_android,
                        color: Theme.of(context).primaryColor,
                      ),
                      labelText: 'Mobile Number',
                      labelStyle:
                          TextStyle(color: Theme.of(context).primaryColor),
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    enabled: false,
                    controller: _emailTextController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      labelText: 'Email',
                      labelStyle:
                          TextStyle(color: Theme.of(context).primaryColor),
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    obscureText: true,
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
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.vpn_key_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      labelText: 'New Password',
                      labelStyle:
                          TextStyle(color: Theme.of(context).primaryColor),
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    obscureText: true,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Confirm Password';
                      }
                      if (value.length < 6) {
                        return 'Minimum 6 characters';
                      }
                      if (_passwordTextController.text !=
                          _cPasswordTextController.text) {
                        return 'Password doesn\'t match';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.vpn_key_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      labelText: 'Confirm Password',
                      labelStyle:
                          TextStyle(color: Theme.of(context).primaryColor),
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    maxLines: 4,
                    controller: _addressTextController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please press Navigation Button';
                      }
                      if (_authData.shopLatitude == null) {
                        return 'Please press Navigation Button';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.contact_mail_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      labelText: 'Business Location',
                      labelStyle:
                          TextStyle(color: Theme.of(context).primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.location_searching,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          _addressTextController.text =
                              'Locating...\n Please wait...';
                          _authData.getCurrentAdress().then((address) {
                            if (address != null) {
                              setState(() {
                                _addressTextController.text =
                                    '${_authData.placeName}\n${_authData.shopAdress}';
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Couldn not find location... Try again')),
                              );
                            }
                          });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(children: [
                  Expanded(
                    // ignore: deprecated_member_use
                    child: FlatButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        if (_authData.isPickAvail == true) {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            _authData
                                .registerBoys(email, password)
                                .then((credential) {
                              if (credential.user.uid != null) {
                                //user is registered
                                //now will upload profile pic to fire storage
                                uploadFile(_authData.image.path).then((url) {
                                  if (url != null) {
                                    //save shipper details to databse
                                    _authData.saveBoysDataToDb(
                                        url: url,
                                        mobile: mobile,
                                        name: name,
                                        password: password,
                                        context: context);
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  } else {
                                    scaffordMessage(
                                        'Failed to upload Personal Profile Pic');
                                  }
                                });
                              } else {
                                //register failed
                                scaffordMessage(_authData.error);
                              }
                            });
                          }
                        } else {
                          scaffordMessage(
                              'Shop profile picture need to be added');
                        }
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(color: Colors.white),
                      ),
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
                          text: 'Already have an account? ',
                          style: TextStyle(color: Colors.black)),
                      TextSpan(
                          text: 'Login',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red))
                    ])),
                    onPressed: () {
                      Navigator.pushNamed(context, LoginScreen.id);
                    },
                  ),
                ]),
              ],
            ),
          );
  }
}
