import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/controllers/customer/productController.dart';

class RatingProductController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  ProductController _productController = ProductController();

  Future<void> ratingStar(currentRating, productId, context) async {
    await _productController.getProductById(productId).then((value) {
      DocumentReference doc = _productController.products.doc(productId);
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

  Future<void> calculateStars(curRating, productId, context) async {
    await _productController.getProductById(productId).then((value) {
      DocumentReference doc = _productController.products.doc(productId);
      int totalStar = 0;
      for (int i = 0; i < value.data()['totalRating']; i++) {
        // ignore: unnecessary_brace_in_string_interps
        totalStar = totalStar + value.data()['rating']['${i}']['stars'];
      }
      doc.update({
        'star': totalStar / value.data()['totalRating'],
        if (totalStar / value.data()['totalRating'] >= 4 &&
            value.data()['totalRating'] > 2)
          'collection': 'Featured Products'
        else if (totalStar / value.data()['totalRating'] < 4 &&
            value.data()['totalRating'] > 3)
          'collection': 'Not Featured Products'
      });
    });
  }
}
