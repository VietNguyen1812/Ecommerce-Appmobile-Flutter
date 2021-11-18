import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_admin/controller/firebaseController.dart';
import 'package:grocery_app_admin/widgets/category/categoryCardWidget.dart';

class CategoryListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseController _controller = FirebaseController();

    return Container(
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder(
        stream: _controller.category.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Wrap(
            direction: Axis.horizontal,
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return CategoryCard(document);
            }).toList(),
          );
        },
      ),
    );
  }
}
