import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SaveForLater extends StatelessWidget {
  final DocumentSnapshot document;
  SaveForLater(this.document);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        EasyLoading.show(status: 'Saving');
        saveForLater().then((value) {
          EasyLoading.showSuccess('Saved Successfully');
        });
      },
      child: Container(
        height: 56,
        color: Theme.of(context).primaryColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Icon(
              CupertinoIcons.heart,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveForLater() {
    CollectionReference _favourite =
        FirebaseFirestore.instance.collection('favourites');
    User user = FirebaseAuth.instance.currentUser;
    return _favourite.add({'product': document.data(), 'customerId': user.uid});
  }
}
