import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/controllers/vendor/firebaseVendorController.dart';
import 'package:grocery_app/providers/storeProvider.dart';
import 'package:provider/provider.dart';

class RatingVendorController {
  FirebaseVendorController _vendorController = FirebaseVendorController();
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> ratingStar(currentRating, context) async {
    var _store = Provider.of<StoreProvider>(context, listen: false);
    await _vendorController
        .getShopById(_store.storedetails['uid'])
        .then((value) {
      DocumentReference doc =
          _vendorController.vendors.doc(_store.storedetails['uid']);
      if (value.data()['totalRating'] == 0) {
        doc.update({
          'rating.${0}.customerId': _auth.currentUser.uid,
          'rating.${0}.stars': currentRating,
          'totalRating': value.data()['totalRating'] + 1,
          'star': currentRating
        }).then((value) {
          EasyLoading.showSuccess('Successfully Voted');
        });
      } else {
        for (int i = 0; i < value.data()['totalRating']; i++) {
          // ignore: unnecessary_brace_in_string_interps
          if (value.data()['rating']['${i}']['customerId'] ==
              _auth.currentUser.uid) {
            doc.update({
              // ignore: unnecessary_brace_in_string_interps
              'rating.${i}.customerId': _auth.currentUser.uid,
              // ignore: unnecessary_brace_in_string_interps
              'rating.${i}.stars': currentRating,
            }).then((value) {
              EasyLoading.showSuccess('Successfully Voted');
            });
            break;
          }
          if (i == value.data()['totalRating'] - 1) {
            doc.update({
              // ignore: unnecessary_brace_in_string_interps
              'rating.${value.data()['totalRating']}.customerId':
                  _auth.currentUser.uid,
              // ignore: unnecessary_brace_in_string_interps
              'rating.${value.data()['totalRating']}.stars': currentRating,
              'totalRating': value.data()['totalRating'] + 1,
            }).then((value) {
              EasyLoading.showSuccess('Successfully Voted');
            });
          }
        }
      }
    });
  }

  Future<void> calculateStars(curRating, context) async {
    var _store = Provider.of<StoreProvider>(context, listen: false);
    await _vendorController
        .getShopById(_store.storedetails['uid'])
        .then((value) {
      DocumentReference doc =
          _vendorController.vendors.doc(_store.storedetails['uid']);
      int totalStar = 0;
      for (int i = 0; i < value.data()['totalRating']; i++) {
        // ignore: unnecessary_brace_in_string_interps
        totalStar = totalStar + value.data()['rating']['${i}']['stars'];
      }
      doc.update({
        'star': totalStar / value.data()['totalRating'],
        if (totalStar / value.data()['totalRating'] >= 4 &&
            value.data()['totalRating'] > 2)
          'isTopPicked': true
        else
          'isTopPicked': false
      });
    });
  }
}