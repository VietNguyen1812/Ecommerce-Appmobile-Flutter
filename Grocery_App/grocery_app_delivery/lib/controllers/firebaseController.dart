import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseController {
  User user = FirebaseAuth.instance.currentUser;
  
  CollectionReference boys = FirebaseFirestore.instance.collection('boys');
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<DocumentSnapshot> validateUser(id) async {
    DocumentSnapshot result = await boys.doc(id).get();
    return result;
  }

  Future<DocumentSnapshot> getCustomerDetails(id) async {
    DocumentSnapshot doc = await users.doc(id).get();
    return doc;
  }

  Future<void> updateStatus({id, status}) {
    return orders.doc(id).update({'orderStatus': status});
  }
}
