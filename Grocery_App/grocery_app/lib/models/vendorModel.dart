import 'package:cloud_firestore/cloud_firestore.dart';

class Vendor {
  final String shopName, address, mobile, dialog, imageUrl;
  final DocumentSnapshot document;

  Vendor({
    this.shopName,
    this.imageUrl,
    this.dialog,
    this.address,
    this.mobile,
    this.document,
  });
}
