import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/widgets/customer/products/bottomSheetContainer.dart';
import 'package:grocery_app/widgets/customer/ratingProductWidget.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const String id = 'product-details-screen';
  final DocumentSnapshot document;
  ProductDetailsScreen({this.document});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _rating;
  @override
  Widget build(BuildContext context) {
    var offer = ((widget.document.data()['comparedPrice'] -
            widget.document.data()['price']) /
        widget.document.data()['comparedPrice'] *
        100);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.search),
            onPressed: () {},
          )
        ],
      ),
      bottomSheet: BottomSheetContainer(widget.document),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Row(children: [
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(.3),
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                    )),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 2, bottom: 2),
                  child: Text(widget.document.data()['brand']),
                ),
              ),
            ]),
            SizedBox(
              height: 10,
            ),
            Text(
              widget.document.data()['productName'],
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              widget.document.data()['weight'],
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text(
                  '\$${widget.document.data()['price'].toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 10,
                ),
                if (offer > 0)
                  Text(
                    '\$${widget.document.data()['comparedPrice']}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough),
                  ),
                SizedBox(
                  width: 10,
                ),
                if (offer > 0)
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(2)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8, right: 8, top: 3, bottom: 3),
                      child: Text(
                        '${offer.toStringAsFixed(0)}% OFF',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  ),
                SizedBox(
                  width: 120,
                ),
                // ignore: deprecated_member_use
                RaisedButton(
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      'Vote Product',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Container(
                                width: 100,
                                height: 150,
                                color: Colors.white,
                                child: RatingProduct((rating) {
                                  setState(() {
                                    _rating = rating;
                                  });
                                }, widget.document, 5),
                              ),
                            );
                          });
                    }),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Hero(
                  tag: 'product${widget.document.data()['productName']}',
                  child: Image.network(widget.document.data()['productImage'])),
            ),
            Divider(
              color: Colors.grey[300],
              thickness: 6,
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  'About this product',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Divider(color: Colors.grey[400]),
            Padding(
              padding:
                  const EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
              child: ExpandableText(
                widget.document.data()['description'],
                expandText: 'View more',
                collapseText: 'View less',
                maxLines: 2,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Divider(color: Colors.grey[400]),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  'Other product info',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Divider(color: Colors.grey[400]),
            Padding(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SKU: ${widget.document.data()['sku']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Seller: ${widget.document.data()['seller']['shopName']}',
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 60,
            )
          ],
        ),
      ),
    );
  }

  Future<void> saveForLater() {
    CollectionReference _favourite =
        FirebaseFirestore.instance.collection('favourites');
    User user = FirebaseAuth.instance.currentUser;
    return _favourite
        .add({'product': widget.document.data(), 'customerId': user.uid});
  }
}
