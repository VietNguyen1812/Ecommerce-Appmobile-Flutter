import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';
import 'package:grocery_app_delivery/screens/homeScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

class AuthProvider extends ChangeNotifier {
  File image;
  bool isPickAvail = false;
  String pickError = '';
  String error = '';

  //shipper data
  double shopLatitude;
  double shopLongitude;
  String shopAdress;
  String placeName;
  String email;

  bool loading = false;

  CollectionReference _boys = FirebaseFirestore.instance.collection('boys');

  getEmail(email) {
    this.email = email;
    notifyListeners();
  }

  Future<File> getImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 10);
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

  Future getCurrentAdress() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    this.shopLatitude = _locationData.latitude;
    this.shopLongitude = _locationData.longitude;
    notifyListeners();

    final coordinates =
        new Coordinates(_locationData.latitude, _locationData.longitude);
    var _addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var shopAdress = _addresses.first;
    this.shopAdress = shopAdress.addressLine;
    this.placeName = shopAdress.featureName;
    notifyListeners();

    return shopAdress;
  }

  //register vendor account using email
  Future<UserCredential> registerBoys(email, password) async {
    this.email = email;
    notifyListeners();

    UserCredential userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        this.error = 'The password provided is too weak.';
        notifyListeners();
      } else if (e.code == 'email-already-in-use') {
        this.error = 'The account already exists for that email.';
        notifyListeners();
      }
    } catch (e) {
      this.error = e.toString();
      notifyListeners();
      print(e);
    }
    return userCredential;
  }

  //login
  Future<UserCredential> loginBoys(email, password) async {
    this.email = email;
    notifyListeners();

    UserCredential userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      this.error = e.code;
      notifyListeners();
    } catch (e) {
      this.error = e.code;
      notifyListeners();
      print(e);
    }
    return userCredential;
  }

  //reset password
  Future<void> resetPassword(email) async {
    this.email = email;
    notifyListeners();

    UserCredential userCredential;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email).whenComplete(() {

      });
    } on FirebaseAuthException catch (e) {
      this.error = e.code;
      notifyListeners();
    } catch (e) {
      this.error = e.code;
      notifyListeners();
      print(e);
    }
    return userCredential;
  }

  //save vendor data to Firestore
  Future<void> saveBoysDataToDb(
      {String url, String name, String mobile, String password, context}) {
    User user = FirebaseAuth.instance.currentUser;
    _boys.doc(this.email).update({
      'uid': user.uid,
      'name': name,
      'password': password,
      'mobile': mobile,
      'address': '${this.placeName} : ${this.shopAdress}',
      'location': GeoPoint(this.shopLatitude, this.shopLongitude),
      'imageUrl': url,
      'accVerified': false //keep initial value as false
    }).whenComplete(() {
      Navigator.pushReplacementNamed(context, HomeScreen.id);
    });
    return null;
  }
}
