import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/controllers/customer/productController.dart';
import 'package:grocery_app/providers/storeProvider.dart';
import 'package:grocery_app/widgets/customer/products/productCardWidget.dart';
import 'package:provider/provider.dart';

class RecentlyAddedProducts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ProductController _controller = ProductController();
    var _store = Provider.of<StoreProvider>(context);

    return FutureBuilder<QuerySnapshot>(
      future: _controller.products
          .where('published', isEqualTo: true)
          .where('collection', isEqualTo: 'Recently Added')
          .where('seller.sellerUid', isEqualTo: _store.storedetails['uid'])
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (!snapshot.hasData) {
          return Container();
        }

        if (snapshot.data.docs.isEmpty) {
          return Container();
        }

        return Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.teal[100],
                ),
                child: Center(
                  child: Text(
                    'Recently Added',
                    style: TextStyle(
                        shadows: <Shadow>[
                          Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 3.0,
                              color: Colors.black)
                        ],
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
          new ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return new ProductCard(document);
            }).toList(),
          ),
        ]);
      },
    );
  }
}
