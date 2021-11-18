import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/controllers/userController.dart';
import 'package:grocery_app/providers/authProvider.dart';
import 'package:grocery_app/widgets/customer/avatarImagePicker.dart';
import 'package:provider/provider.dart';

class UpdateProfile extends StatefulWidget {
  static const String id = 'update-profile';

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  FocusNode _focusNodeFirstName,
      _focusNodeLastName,
      _focusNodeEmail,
      _focusNodeMobile;
  User user = FirebaseAuth.instance.currentUser;
  UserController _user = UserController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  var firstName = TextEditingController();
  var lastName = TextEditingController();
  var mobile = TextEditingController();
  var email = TextEditingController();

  updateProfile(String url) {
    return FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'firstName': firstName.text,
      'lastName': lastName.text,
      'email': email.text,
      'avatarImage': url
    });
  }

  updateAvatarMessage(String id, String url) {
    return FirebaseFirestore.instance.collection('messages').doc(id).update({
      'customer.avatarImage': url,
    });
  }

  Future<String> uploadFile(filePath) async {
    File file =
        File(filePath); //need file to upload, we already have inside provider

    FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      await _storage.ref('uploads/cusProfilePic/${email.text}').putFile(file);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print(e.code);
    }
    //now after upload file we need to file url path to save in database
    String downloadURL = await _storage
        .ref('uploads/cusProfilePic/${email.text}')
        .getDownloadURL();
    return downloadURL;
  }

  Future<void> getMessages(String url) async {
    await FirebaseFirestore.instance
        .collection("messages")
        .where('customer.cusId', isEqualTo: _auth.currentUser.uid)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        updateAvatarMessage(result.data()['chatRoomId'], url);
      });
    });
  }

  @override
  void initState() {
    _user.getUserById(user.uid).then((value) {
      if (mounted) {
        setState(() {
          firstName.text = value.data()['firstName'];
          lastName.text = value.data()['lastName'];
          email.text = value.data()['email'];
          mobile.text = user.phoneNumber;
        });
      }
    });
    super.initState();
    _focusNodeFirstName = FocusNode();
    _focusNodeLastName = FocusNode();
    _focusNodeEmail = FocusNode();
    _focusNodeMobile = FocusNode();
  }

  @override
  void dispose() {
    _focusNodeFirstName.dispose();
    _focusNodeLastName.dispose();
    _focusNodeEmail.dispose();
    _focusNodeMobile.dispose();
    super.dispose();
  }

  void _requestFocusFirstName() {
    setState(() {
      FocusScope.of(context).requestFocus(_focusNodeFirstName);
    });
  }

  void _requestFocusLastName() {
    setState(() {
      FocusScope.of(context).requestFocus(_focusNodeLastName);
    });
  }

  void _requestFocusMobile() {
    setState(() {
      FocusScope.of(context).requestFocus(_focusNodeMobile);
    });
  }

  void _requestFocusEmail() {
    setState(() {
      FocusScope.of(context).requestFocus(_focusNodeEmail);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Update Profile',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomSheet: InkWell(
        onTap: () {
          if (_formKey.currentState.validate()) {
            EasyLoading.show(status: 'Updating profile...');
            if (_authData.image != null) {
              uploadFile(_authData.image.path).then((url) => {
                    updateProfile(url).then((value) {
                      getMessages(url);
                      EasyLoading.showSuccess('Updated Successfully!');
                      Navigator.pop(context);
                    })
                  });
            } else {
              updateProfile(null).then((value) {
                getMessages(null);
                EasyLoading.showSuccess('Updated Successfully!');
                Navigator.pop(context);
              });
            }
          }
        },
        child: Container(
          width: double.infinity,
          height: 56,
          color: Colors.blueGrey[900],
          child: Center(
            child: Text(
              'Update',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                      controller: firstName,
                      focusNode: _focusNodeFirstName,
                      onTap: _requestFocusFirstName,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                            color: _focusNodeFirstName.hasFocus
                                ? Theme.of(context).primaryColor
                                : Colors.grey),
                        labelText: 'First Name',
                        contentPadding: EdgeInsets.zero,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 2,
                                color: Theme.of(context).primaryColor)),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter first name';
                        }
                        return null;
                      },
                    )),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: TextFormField(
                      controller: lastName,
                      focusNode: _focusNodeLastName,
                      onTap: _requestFocusLastName,
                      decoration: InputDecoration(
                          labelStyle: TextStyle(
                              color: _focusNodeLastName.hasFocus
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey),
                          labelText: 'Last Name',
                          contentPadding: EdgeInsets.zero,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Theme.of(context).primaryColor))),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter last name';
                        }
                        return null;
                      },
                    )),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: mobile,
                  enabled: false,
                  focusNode: _focusNodeMobile,
                  onTap: _requestFocusMobile,
                  decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: _focusNodeMobile.hasFocus
                              ? Theme.of(context).primaryColor
                              : Colors.grey),
                      labelText: 'Mobile',
                      contentPadding: EdgeInsets.zero,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2,
                              color: Theme.of(context).primaryColor))),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: email,
                  focusNode: _focusNodeEmail,
                  onTap: _requestFocusEmail,
                  decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: _focusNodeEmail.hasFocus
                              ? Theme.of(context).primaryColor
                              : Colors.grey),
                      labelText: 'Email',
                      contentPadding: EdgeInsets.zero,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2,
                              color: Theme.of(context).primaryColor))),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter Email address';
                    }
                    return null;
                  },
                ),
                AvatarPicCard()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
