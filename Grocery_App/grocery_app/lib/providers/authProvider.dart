import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/controllers/userController.dart';
import 'package:grocery_app/providers/locationProvider.dart';
import 'package:grocery_app/screens/customer/landingScreen.dart';
import 'package:grocery_app/screens/customer/mainScreen.dart';
import 'package:image_picker/image_picker.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User user = FirebaseAuth.instance.currentUser;

  String smsOtp;
  String verificationId;
  String error = '';
  UserController _userController = UserController();
  bool loading = false;
  LocationProvider locationData = LocationProvider();
  String screen;
  double latitude;
  double longitude;
  String address;
  String location;
  File image;
  String pickError = '';
  bool isPickAvail = false;
  DocumentSnapshot snapshot;

  Future<void> verifyPhone({BuildContext context, String number}) async {
    this.loading = true;
    notifyListeners();
    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential credential) async {
      this.loading = false;
      notifyListeners();
      await _auth.signInWithCredential(credential);
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
      this.loading = false;
      print(e.code);
      this.error = e.toString();
      notifyListeners();
    };

    final PhoneCodeSent smsOtpSend = (String verId, int resendToken) async {
      this.verificationId = verId;
      //open dialog to enter received OTP SMS
      smsOtpDialog(context, number);
    };

    try {
      _auth.verifyPhoneNumber(
        phoneNumber: number,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: smsOtpSend,
        codeAutoRetrievalTimeout: (String verId) {
          this.verificationId = verId;
        },
      );
    } catch (e) {
      this.error = e.toString();
      this.loading = false;
      notifyListeners();
      print(e);
    }
  }

  Future<void> smsOtpDialog(BuildContext context, String number) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              children: [
                Text('Verification Code'),
                SizedBox(
                  height: 6,
                ),
                Text(
                  'Enter 6 digit OTP received as SMS',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            content: Container(
              height: 85,
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (value) {
                  this.smsOtp = value;
                },
              ),
            ),
            actions: [
              // ignore: deprecated_member_use
              FlatButton(
                onPressed: () async {
                  try {
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                            verificationId: verificationId, smsCode: smsOtp);
                    final User user =
                        (await _auth.signInWithCredential(credential)).user;

                    if (user != null) {
                      this.loading = false;
                      notifyListeners();

                      _userController.getUserById(user.uid).then((snapShot) {
                        if (snapShot.exists) {
                          //user data already exists
                          if (this.screen == 'Login') {
                            //check user data already exists in db or not
                            //if its 'login', no new data, no need to update
                            if (snapShot.data()['address'] != null) {
                              Navigator.pushReplacementNamed(
                                  context, MainScreen.id);
                            }
                            Navigator.pushReplacementNamed(
                                context, LandingScreen.id);
                          } else {
                            //need to update new selected address
                            updateUser(id: user.uid, number: user.phoneNumber);
                            Navigator.pushReplacementNamed(
                                context, MainScreen.id);
                          }
                        } else {
                          //user data does not exist
                          //will create data in db
                          _createUser(id: user.uid, number: user.phoneNumber);
                          Navigator.pushReplacementNamed(
                              context, LandingScreen.id);
                        }
                      });
                    } else {
                      print('Login failed');
                    }
                  } catch (e) {
                    this.error = 'Invalid OTP';
                    notifyListeners();
                    print(e.toString());
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  'DONE',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              )
            ],
          );
        }).whenComplete(() {
      this.loading = false;
      notifyListeners();
    });
  }

  void _createUser({String id, String number}) {
    _userController.createUserData({
      'id': id,
      'email': null,
      'firstName': null,
      'lastName': null,
      'number': number,
      'latitude': this.latitude,
      'longitude': this.longitude,
      'address': this.address,
      'location': this.location,
      'avatarImage': null
    });
    this.loading = false;
    notifyListeners();
  }

  void updateUser({String id, String number}) async {
    try {
      _userController.updateUserData({
        'id': id,
        'number': number,
        'latitude': this.latitude,
        'longitude': this.longitude,
        'address': this.address,
        'location': this.location,
      });
      this.loading = false;
      notifyListeners();
    } catch (e) {
      print('Error $e');
    }
  }

  getUserDetails() async {
    DocumentSnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser.uid)
        .get();
    if(result != null) {
      this.snapshot = result;
      notifyListeners();
    } else {
      this.snapshot = null;
      notifyListeners();
    }

    return result;
  }

  Future<File> getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery, imageQuality: 10);
    if (pickedFile != null) {
      this.image = File(pickedFile.path);
      notifyListeners();
    } else {
      this.pickError = 'No image selected.';
      print('No image selected.');
      notifyListeners();
    }
    return this.image;
  }
}
