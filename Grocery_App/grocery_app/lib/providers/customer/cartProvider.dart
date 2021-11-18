import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grocery_app/controllers/customer/cartController.dart';
import 'package:grocery_app/controllers/vendor/firebaseVendorController.dart';
import 'package:grocery_app/providers/storeProvider.dart';
import 'package:provider/provider.dart';

class CartProvider with ChangeNotifier {
  CartController _cart = CartController();
  FirebaseVendorController _vendorController = FirebaseVendorController();
  double subTotal = 0.0;
  int cartQty = 0;
  QuerySnapshot snapshot;
  DocumentSnapshot document;
  double saving = 0.0;
  double totalSaving = 0.0;
  double distance = 0.0;
  String productName;
  bool cod = false;
  List cartList = [];
  FirebaseAuth _auth = FirebaseAuth.instance;
  int deliveryFee = 0;

  Future<double> getCartTotal() async {
    var cartTotal = 0.0;
    var saving = 0.0;
    List _newList = [];

    QuerySnapshot snapshot = await _cart.cart
        .doc(_auth.currentUser.uid)
        .collection('products')
        .get();
    if (snapshot == null) {
      return null;
    }
    snapshot.docs.forEach((doc) {
      if (!_newList.contains(doc.data())) {
        _newList.add(doc.data());
        this.cartList = _newList;
        notifyListeners();
      }
      cartTotal = cartTotal + doc.data()['total'];
      saving = saving +
          (((doc.data()['comparedPrice'] - doc.data()['price'])) > 0
              ? doc.data()['comparedPrice'] - doc.data()['price']
              : 0);
    });

    this.subTotal = cartTotal;
    this.cartQty = snapshot.size;
    this.snapshot = snapshot;
    this.saving = saving;
    notifyListeners();

    return cartTotal;
  }

  Future<void> getTotalSaving() async {
    var totalSaving = 0.0;
    List _newList = [];

    QuerySnapshot snapshot = await _cart.cart
        .doc(_auth.currentUser.uid)
        .collection('products')
        .get();
    if (snapshot == null) {
      return null;
    }
    snapshot.docs.forEach((doc) {
      if (!_newList.contains(doc.data())) {
        _newList.add(doc.data());
        this.cartList = _newList;
        notifyListeners();
      }
      totalSaving = totalSaving +
          (((doc.data()['comparedPrice'] - doc.data()['price'])) > 0
              ? (doc.data()['comparedPrice'] - doc.data()['price']) *
                  doc.data()['qty']
              : 0);
    });
    this.totalSaving = totalSaving;
    notifyListeners();
  }

  getDistance(distance) {
    this.distance = distance;
    notifyListeners();
  }

  getPaymentMethod(index) {
    if (index == 0) {
      this.cod = false;
      notifyListeners();
    } else {
      this.cod = true;
      notifyListeners();
    }
  }

  getShopName() async {
    DocumentSnapshot doc = await _cart.cart.doc(_auth.currentUser.uid).get();
    if (doc.exists) {
      this.document = doc;
      notifyListeners();
    } else {
      this.document = null;
      notifyListeners();
    }
  }

  num getDistanceForDeliveryFee(location, context) {
    final _storeData = Provider.of<StoreProvider>(context, listen: false);
    num distance = Geolocator.distanceBetween(_storeData.userLatitude,
        _storeData.userLongitude, location.latitude, location.longitude);
    num distanceInKm = distance / 1000;
    return distanceInKm;
  }

  Future<void> calculateDeliveryShip(context) async {
    final _storeData = Provider.of<StoreProvider>(context, listen: false);
    _storeData.getUserLocationData(context);
    DocumentSnapshot doc = await _cart.cart.doc(_auth.currentUser.uid).get();

    DocumentSnapshot docVendor =
        await _vendorController.getShopById(doc.data()['sellerUid']);
    if (getDistanceForDeliveryFee(docVendor.data()['location'], context) > 1 &&
        getDistanceForDeliveryFee(docVendor.data()['location'], context) < 2) {
      this.deliveryFee = 10;
      notifyListeners();
    } else if (getDistanceForDeliveryFee(
                docVendor.data()['location'], context) >=
            2 &&
        getDistanceForDeliveryFee(docVendor.data()['location'], context) < 3) {
      this.deliveryFee = 12;
      notifyListeners();
    } else if (getDistanceForDeliveryFee(
                docVendor.data()['location'], context) >=
            3 &&
        getDistanceForDeliveryFee(docVendor.data()['location'], context) < 4) {
      this.deliveryFee = 14;
      notifyListeners();
    } else if (getDistanceForDeliveryFee(
                docVendor.data()['location'], context) >=
            4 &&
        getDistanceForDeliveryFee(docVendor.data()['location'], context) < 5) {
      this.deliveryFee = 16;
      notifyListeners();
    } else if (getDistanceForDeliveryFee(
                docVendor.data()['location'], context) >=
            5 &&
        getDistanceForDeliveryFee(docVendor.data()['location'], context) < 6) {
      this.deliveryFee = 18;
      notifyListeners();
    } else if (getDistanceForDeliveryFee(
                docVendor.data()['location'], context) >=
            6 &&
        getDistanceForDeliveryFee(docVendor.data()['location'], context) < 7) {
      this.deliveryFee = 20;
      notifyListeners();
    } else if (getDistanceForDeliveryFee(
                docVendor.data()['location'], context) >=
            7 &&
        getDistanceForDeliveryFee(docVendor.data()['location'], context) < 8) {
      this.deliveryFee = 22;
      notifyListeners();
    } else if (getDistanceForDeliveryFee(
                docVendor.data()['location'], context) >=
            8 &&
        getDistanceForDeliveryFee(docVendor.data()['location'], context) < 9) {
      this.deliveryFee = 24;
      notifyListeners();
    } else if (getDistanceForDeliveryFee(
                docVendor.data()['location'], context) >=
            9 &&
        getDistanceForDeliveryFee(docVendor.data()['location'], context) < 10) {
      this.deliveryFee = 26;
      notifyListeners();
    } else if (getDistanceForDeliveryFee(
            docVendor.data()['location'], context) ==
        10) {
      this.deliveryFee = 28;
      notifyListeners();
    }
  }

  Future<void> getCartDetails() async {
    List _newList = [];

    QuerySnapshot snapshot = await _cart.cart
        .doc(_auth.currentUser.uid)
        .collection('products')
        .get();
    if (snapshot == null) {
      return null;
    }
    snapshot.docs.forEach((doc) {
      if (!_newList.contains(doc.data())) {
        _newList.add(doc.data());
        this.cartList = _newList;
        this.productName = doc.data()['productName'];
        notifyListeners();
      }
    });

    this.snapshot = snapshot;
    notifyListeners();
  }
}
