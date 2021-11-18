import 'package:cloud_firestore/cloud_firestore.dart';

class StoreController {
  CollectionReference vendorbanner =
      FirebaseFirestore.instance.collection('vendorbanner');
  CollectionReference vendors =
      FirebaseFirestore.instance.collection('vendors');

  getTopPickedStore() {
    return vendors
        .where('accVerified', isEqualTo: true)
        .where('isTopPicked', isEqualTo: true)
        .where('shopOpen', isEqualTo: true)
        .snapshots();
  }

  getNearByStore() {
    return vendors.where('accVerified', isEqualTo: true).snapshots();
  }

  getNearByStorePagination() {
    return vendors.where('accVerified', isEqualTo: true);
  }

  Future<DocumentSnapshot> getShopDetails(sellerUid) async {
    DocumentSnapshot snapshot = await vendors.doc(sellerUid).get();
    return snapshot;
  }
}
