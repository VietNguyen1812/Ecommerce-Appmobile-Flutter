import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/controllers/customer/productController.dart';
import 'package:grocery_app/providers/storeProvider.dart';
import 'package:grocery_app/widgets/customer/products/productCardWidget.dart';
import 'package:provider/provider.dart';

class ProductListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ProductController _controller = ProductController();
    var _store = Provider.of<StoreProvider>(context);

    return FutureBuilder<QuerySnapshot>(
      future: _controller.products
          .where('published', isEqualTo: true)
          .where('category.mainCategory',
              isEqualTo: _store.selectedProductCategory)
          .where('category.subCategory',
              isEqualTo: _store.selectedSubCategory)
          .where('seller.sellerUid',
              isEqualTo: _store.storedetails['uid'])
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data.docs.isEmpty) {
          return Container();
        }

        return Column(children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[300],
            ),
            child: Row(children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  '${snapshot.data.docs.length} Items',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey[600]),
                ),
              ),
            ]),
          ),
          new ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return new ProductCard(document);
            }).toList(),
          ),
          SizedBox(height: 50,)
        ]);
      },
    );
  }
}
