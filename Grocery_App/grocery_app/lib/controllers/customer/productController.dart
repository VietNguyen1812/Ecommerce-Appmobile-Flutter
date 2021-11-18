import 'package:cloud_firestore/cloud_firestore.dart';

class ProductController {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference category =
      FirebaseFirestore.instance.collection('category');
  CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  Future<DocumentSnapshot> getProductById(String id) async {
    var result = await _firestore.collection('products').doc(id).get();
    return result;
  }
}
