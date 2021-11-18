import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/controllers/customer/cartController.dart';
import 'package:grocery_app/widgets/customer/cart/counterWidget.dart';

class AddToCartWidget extends StatefulWidget {
  final DocumentSnapshot document;
  AddToCartWidget(this.document);

  @override
  _AddToCartWidgetState createState() => _AddToCartWidgetState();
}

class _AddToCartWidgetState extends State<AddToCartWidget> {
  CartController _cart = CartController();
  User user = FirebaseAuth.instance.currentUser;
  bool _loading = true;
  bool _exist = false;
  int _qty = 1;
  String _docId;

  @override
  void initState() {
    //while opening product details screen, first will check this item already in cart or not
    getCartData();

    super.initState();
  }

  getCartData() async {
    final snapshot =
        await _cart.cart.doc(user.uid).collection('products').get();
    if (snapshot.docs.length == 0) {
      setState(() {
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance
        .collection('cart')
        .doc(user.uid)
        .collection('products')
        .where('productId', isEqualTo: widget.document.data()['productId'])
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc["productId"] == widget.document.data()['productId']) {
          //means selected product already exists in cart, so no need to add to cart again
          if (mounted) {
            setState(() {
              _exist = true;
              _qty = doc['qty'];
              _docId = doc.id;
            });
          }
        }
      });
    });
    if (widget.document.data()['stockQty'] > 0) {
      return _loading
          ? Container(
              height: 56,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                ),
              ),
            )
          : _exist
              ? CounterWidget(
                  document: widget.document,
                  qty: _qty,
                  docId: _docId,
                )
              : InkWell(
                  onTap: () {
                    EasyLoading.show(status: 'Adding to Basket');
                    _cart.addToCart(widget.document).then((value) {
                      setState(() {
                        _exist = true;
                      });
                      EasyLoading.showSuccess('Added to Basket');
                    });
                  },
                  child: Container(
                    height: 56,
                    color: Colors.red[400],
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(
                            Icons.shopping_basket_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Add to basket',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ]),
                      ),
                    ),
                  ),
                );
    }
    return Container(
      height: 56,
      color: Colors.red[400],
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              Icons.remove_shopping_cart_outlined,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Out of Stock',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ]),
        ),
      ),
    );
  }
}
