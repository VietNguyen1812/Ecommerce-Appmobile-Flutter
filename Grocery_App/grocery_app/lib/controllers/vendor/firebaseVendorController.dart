import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class FirebaseVendorController {
  User user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference category =
      FirebaseFirestore.instance.collection('category');
  CollectionReference products =
      FirebaseFirestore.instance.collection('products');
  CollectionReference vendorbanner =
      FirebaseFirestore.instance.collection('vendorbanner');
  CollectionReference coupons =
      FirebaseFirestore.instance.collection('coupons');
  CollectionReference boys = FirebaseFirestore.instance.collection('boys');
  CollectionReference vendors =
      FirebaseFirestore.instance.collection('vendors');
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> publishProduct({id}) {
    return products.doc(id).update({'published': true});
  }

  Future<void> unPublishProduct({id}) {
    return products.doc(id).update({'published': false});
  }

  Future<void> deleteProduct({id}) {
    return products.doc(id).delete();
  }

  Future<void> saveBanner(url) {
    return vendorbanner.add({'imageUrl': url, 'sellerUid': user.uid});
  }

  Future<void> deleteBanner({id}) {
    return vendorbanner.doc(id).delete();
  }

  Future<void> saveCoupon(
      {document, title, discountRate, expiry, details, active}) {
    if (document == null) {
      return coupons.doc(title).set({
        'title': title,
        'discountRate': discountRate,
        'expiry': expiry,
        'details': details,
        'active': active,
        'sellerId': user.uid,
      });
    }
    return coupons.doc(title).update({
      'title': title,
      'discountRate': discountRate,
      'expiry': expiry,
      'details': details,
      'active': active,
      'sellerId': user.uid,
    });
  }

  Future<DocumentSnapshot> getShopDetails() async {
    DocumentSnapshot doc = await vendors.doc(user.uid).get();
    return doc;
  }

  Future<DocumentSnapshot> getShopById(String id) async {
    var result = await _firestore.collection('vendors').doc(id).get();
    return result;
  }

  Future<void> calculateRevenueShop(revenue, context) async {
    DateTime _currentMonth = DateTime.now();
    await getShopById(user.uid).then((value) {
      DocumentReference doc = vendors.doc(user.uid);
      if (value.data()['revenueShop'] == 0) {
        for (int i = 0; i < 12; i++) {
          // ignore: unrelated_type_equality_checks
          if (_currentMonth.month == i + 1) {
            doc.update({
              // ignore: unnecessary_brace_in_string_interps
              'revenueShop.${i}.month': _currentMonth.month,
              // ignore: unnecessary_brace_in_string_interps
              'revenueShop.${i}.revenue': revenue,
            });
          } else {
            doc.update({
              // ignore: unnecessary_brace_in_string_interps
              'revenueShop.${i}.month': i + 1,
              // ignore: unnecessary_brace_in_string_interps
              'revenueShop.${i}.revenue': 0,
            });
          }
        }
      } else {
        for (int i = 0; i < value.data()['revenueShop'].length; i++) {
          // ignore: unnecessary_brace_in_string_interps
          if (value.data()['revenueShop']['${i}']['month'] ==
              _currentMonth.month) {
            doc.update({
              // ignore: unnecessary_brace_in_string_interps
              'revenueShop.${i}.revenue':
                  // ignore: unnecessary_brace_in_string_interps
                  value.data()['revenueShop']['${i}']['revenue'] + revenue,
            }).then((value) {
              EasyLoading.showSuccess('Successfully Updated Shop Revenue');
            });
            break;
          }
          if (i == value.data()['revenueShop'].length - 1) {
            doc.update({
              // ignore: unnecessary_brace_in_string_interps
              'revenueShop.${i}.month': _currentMonth.month,
              // ignore: unnecessary_brace_in_string_interps
              'revenueShop.${i}.revenue':
                  // ignore: unnecessary_brace_in_string_interps
                  value.data()['revenueShop']['${i}']['revenue'] + revenue,
            }).then((value) {
              EasyLoading.showSuccess('Successfully Updated Shop Revenue');
            });
          }
        }
      }
    });
  }

  Future<DocumentSnapshot> getCustomerDetails(id) async {
    DocumentSnapshot doc = await users.doc(id).get();
    return doc;
  }

  Future<void> selectBoys({orderId, location, email, name, image, phone}) {
    var result = orders.doc(orderId).update({
      'deliveryBoy': {
        'location': location,
        'email': email,
        'name': name,
        'image': image,
        'phone': phone
      }
    });
    return result;
  }
}
