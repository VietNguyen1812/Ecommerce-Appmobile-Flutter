import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/providers/vendor/authVendorProvider.dart';
import 'package:grocery_app/screens/vendor/homeVendorScreen.dart';
import 'package:grocery_app/screens/vendor/loginVendorScreen.dart';
import 'package:provider/provider.dart';

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  FocusNode _focusNodeBusinessName,
      _focusPhoneNumber,
      _focusEmail,
      _focusPassword,
      _focusConfirmPassword,
      _focusLocation,
      _focusDialog;
  final _formKey = GlobalKey<FormState>();
  var _emailTextController = TextEditingController();
  var _passwordTextController = TextEditingController();
  var _cPasswordTextController = TextEditingController();
  var _addressTextController = TextEditingController();
  var _nameTextController = TextEditingController();
  var _dialogTextController = TextEditingController();
  String email;
  String password;
  String shopName;
  String mobile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusNodeBusinessName = FocusNode();
    _focusPhoneNumber = FocusNode();
    _focusEmail = FocusNode();
    _focusPassword = FocusNode();
    _focusConfirmPassword = FocusNode();
    _focusLocation = FocusNode();
    _focusDialog = FocusNode();
  }

  @override
  void dispose() {
    _focusNodeBusinessName.dispose();
    _focusPhoneNumber.dispose();
    _focusEmail.dispose();
    _focusPassword.dispose();
    _focusConfirmPassword.dispose();
    _focusLocation.dispose();
    _focusDialog.dispose();
    super.dispose();
  }

  void _requestFocusBusinessName() {
    setState(() {
      FocusScope.of(context).requestFocus(_focusNodeBusinessName);
    });
  }

  void _requestFocusPhoneNumber() {
    setState(() {
      FocusScope.of(context).requestFocus(_focusPhoneNumber);
    });
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

  void _requestFocusConfirmPassword() {
    setState(() {
      FocusScope.of(context).requestFocus(_focusConfirmPassword);
    });
  }

  void _requestFocusLocation() {
    setState(() {
      FocusScope.of(context).requestFocus(_focusLocation);
    });
  }

  void _requestFocusDialog() {
    setState(() {
      FocusScope.of(context).requestFocus(_focusDialog);
    });
  }

  Future<String> uploadFile(filePath) async {
    File file =
        File(filePath); //need file to upload, we already have inside provider

    FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      await _storage
          .ref('uploads/shopProfilePic/${_nameTextController.text}')
          .putFile(file);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print(e.code);
    }
    //now after upload file we need to file url path to save in database
    String downloadURL = await _storage
        .ref('uploads/shopProfilePic/${_nameTextController.text}')
        .getDownloadURL();
    return downloadURL;
  }

  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthVendorProvider>(context);
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
                    focusNode: _focusNodeBusinessName,
                    onTap: _requestFocusBusinessName,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Shop Name';
                      }
                      setState(() {
                        _nameTextController.text = value;
                      });
                      setState(() {
                        shopName = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: _focusNodeBusinessName.hasFocus
                          ? Icon(
                              Icons.add_business,
                              color: Theme.of(context).primaryColor,
                            )
                          : Icon(
                              Icons.add_business,
                              color: Colors.grey,
                            ),
                      labelText: 'Business Name',
                      labelStyle: TextStyle(
                          color: _focusNodeBusinessName.hasFocus
                              ? Theme.of(context).primaryColor
                              : Colors.black),
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
                    focusNode: _focusPhoneNumber,
                    onTap: _requestFocusPhoneNumber,
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
                      prefixIcon: _focusPhoneNumber.hasFocus
                          ? Icon(
                              Icons.phone_android,
                              color: Theme.of(context).primaryColor,
                            )
                          : Icon(
                              Icons.phone_android,
                              color: Colors.grey,
                            ),
                      labelText: 'Mobile Number',
                      labelStyle: TextStyle(
                          color: _focusPhoneNumber.hasFocus
                              ? Theme.of(context).primaryColor
                              : Colors.black),
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
                    controller: _emailTextController,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _focusEmail,
                    onTap: _requestFocusEmail,
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
                      prefixIcon: _focusEmail.hasFocus
                          ? Icon(
                              Icons.email_outlined,
                              color: Theme.of(context).primaryColor,
                            )
                          : Icon(
                              Icons.email_outlined,
                              color: Colors.grey,
                            ),
                      labelText: 'Email',
                      labelStyle: TextStyle(
                          color: _focusEmail.hasFocus
                              ? Theme.of(context).primaryColor
                              : Colors.black),
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
                    focusNode: _focusPassword,
                    onTap: _requestFocusPassword,
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
                      prefixIcon: _focusPassword.hasFocus
                          ? Icon(
                              Icons.vpn_key_outlined,
                              color: Theme.of(context).primaryColor,
                            )
                          : Icon(
                              Icons.vpn_key_outlined,
                              color: Colors.grey,
                            ),
                      labelText: 'Password',
                      labelStyle: TextStyle(
                          color: _focusPassword.hasFocus
                              ? Theme.of(context).primaryColor
                              : Colors.black),
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
                    focusNode: _focusConfirmPassword,
                    onTap: _requestFocusConfirmPassword,
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
                      prefixIcon: _focusConfirmPassword.hasFocus
                          ? Icon(
                              Icons.vpn_key_outlined,
                              color: Theme.of(context).primaryColor,
                            )
                          : Icon(
                              Icons.vpn_key_outlined,
                              color: Colors.grey,
                            ),
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(
                          color: _focusConfirmPassword.hasFocus
                              ? Theme.of(context).primaryColor
                              : Colors.black),
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
                    focusNode: _focusLocation,
                    onTap: _requestFocusLocation,
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
                      prefixIcon: _focusLocation.hasFocus
                          ? Icon(
                              Icons.contact_mail_outlined,
                              color: Theme.of(context).primaryColor,
                            )
                          : Icon(
                              Icons.add_business,
                              color: Colors.grey,
                            ),
                      labelText: 'Business Location',
                      labelStyle: TextStyle(
                          color: _focusLocation.hasFocus
                              ? Theme.of(context).primaryColor
                              : Colors.black),
                      suffixIcon: IconButton(
                        icon: _focusLocation.hasFocus
                            ? Icon(
                                Icons.location_searching,
                                color: Theme.of(context).primaryColor,
                              )
                            : Icon(Icons.location_searching,
                                color: Colors.grey),
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
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    onChanged: (value) {
                      _dialogTextController.text = value;
                    },
                    focusNode: _focusDialog,
                    onTap: _requestFocusDialog,
                    decoration: InputDecoration(
                      prefixIcon: _focusDialog.hasFocus
                          ? Icon(
                              Icons.comment,
                              color: Theme.of(context).primaryColor,
                            )
                          : Icon(
                              Icons.add_business,
                              color: Colors.grey,
                            ),
                      labelText: 'Shop dialog',
                      labelStyle: TextStyle(
                          color: _focusDialog.hasFocus
                              ? Theme.of(context).primaryColor
                              : Colors.black),
                      contentPadding: EdgeInsets.zero,
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
                                .registerVendor(email, password)
                                .then((credential) {
                              if (credential != null) {
                                //user is registered
                                //now will upload profile pic to fire storage
                                uploadFile(_authData.image.path).then((url) {
                                  if (url != null) {
                                    //save vendor details to databse
                                    _authData.saveVendorDataToDb(
                                      url: url,
                                      mobile: mobile,
                                      shopName: shopName,
                                      dialog: _dialogTextController.text,
                                    );
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    Navigator.pushReplacementNamed(
                                        context, HomeVendorScreen.id);
                                  } else {
                                    scaffordMessage(
                                        'Failed to upload Shop Profile Pic');
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
                      Navigator.pushNamed(context, LoginVendorScreen.id);
                    },
                  ),
                ]),
              ],
            ),
          );
  }
}
