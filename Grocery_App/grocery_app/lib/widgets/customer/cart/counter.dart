import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/controllers/customer/cartController.dart';

class CounterForCard extends StatefulWidget {
  final DocumentSnapshot document;
  CounterForCard(this.document);

  @override
  _CounterForCardState createState() => _CounterForCardState();
}

class _CounterForCardState extends State<CounterForCard> {
  User user = FirebaseAuth.instance.currentUser;
  CartController _cart = CartController();

  int _qty = 1;
  String _docId;
  bool _exist = false;
  bool _updating = false;
  int _stockQty = 0;

  getCartData() {
    FirebaseFirestore.instance
        .collection('cart')
        .doc(user.uid)
        .collection('products')
        .where('productId', isEqualTo: widget.document.data()['productId'])
        .get()
        .then((QuerySnapshot querySnapshot) => {
              if (querySnapshot.docs.isNotEmpty)
                {
                  querySnapshot.docs.forEach((doc) {
                    if (doc["productId"] ==
                        widget.document.data()['productId']) {
                      //means selected product already exists in cart, so no need to add to cart again
                      if (mounted) {
                        setState(() {
                          _qty = doc['qty'];
                          _docId = doc.id;
                          _exist = true;
                        });
                      }
                    }
                  })
                }
              else
                {
                  if (mounted)
                    {
                      setState(() {
                        _exist = false;
                      })
                    }
                }
            });
  }

  getStockQtyData() {
    FirebaseFirestore.instance
        .collection('products')
        .where('productId', isEqualTo: widget.document.data()['productId'])
        .get()
        .then((QuerySnapshot querySnapshotStock) => {
              if (querySnapshotStock.docs.isNotEmpty)
                {
                  querySnapshotStock.docs.forEach((doc) {
                    if (doc["productId"] ==
                        widget.document.data()['productId']) {
                      if (mounted) {
                        setState(() {
                          _exist = true;
                          _stockQty = doc['stockQty'];
                        });
                      }
                    }
                  })
                }
              else
                {
                  if (mounted)
                    {
                      setState(() {
                        _exist = false;
                      })
                    }
                }
            });
  }

  @override
  void initState() {
    getCartData();
    getStockQtyData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _exist
        ? StreamBuilder(
            stream: getCartData(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              return Container(
                height: 28,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.pink),
                    borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    Container(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _updating = true;
                          });
                          if (_qty == 1) {
                            _cart.removeFromCart(_docId).then((value) {
                              setState(() {
                                _updating = false;
                                _exist = false;
                              });
                              _cart.checkData();
                            });
                          }
                          if (_qty > 1) {
                            setState(() {
                              _qty--;
                            });
                            var total = _qty * widget.document.data()['price'];
                            _cart
                                .updateCartQty(_docId, _qty, total)
                                .then((value) {
                              setState(() {
                                _updating = false;
                              });
                            });
                          }
                        },
                        child: Container(
                          child: Icon(
                            _qty == 1 ? Icons.delete_outline : Icons.remove,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: double.infinity,
                      width: 30,
                      color: Colors.pink,
                      child: Center(
                        child: FittedBox(
                          child: _updating
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  _qty.toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                    Container(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _updating = true;
                            _qty++;
                          });
                          var total = _qty * widget.document.data()['price'];
                          _cart
                              .updateCartQty(_docId, _qty, total)
                              .then((value) {
                            setState(() {
                              _updating = false;
                            });
                          });
                        },
                        child: Icon(
                          Icons.add,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })
        : StreamBuilder(
            stream: getCartData(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              return _stockQty > 0 
                  ? InkWell(
                      onTap: () {
                        EasyLoading.show(status: 'Adding to Cart');
                        _cart.checkSeller().then((shopName) {
                          if (shopName ==
                              widget.document.data()['seller']['shopName']) {
                            //product from same seller
                            setState(() {
                              _exist = true;
                            });
                            _cart.addToCart(widget.document).then((value) {
                              EasyLoading.showSuccess('Added to Cart');
                            });
                            return;
                          }
                          if (shopName == null) {
                            setState(() {
                              _exist = true;
                            });
                            _cart.addToCart(widget.document).then((value) {
                              EasyLoading.showSuccess('Added to Cart');
                            });
                            return;
                          }
                          if (shopName !=
                              widget.document.data()['seller']['shopName']) {
                            //product from different seller
                            EasyLoading.dismiss();
                            showDialog(shopName);
                          }
                        });
                      },
                      child: Container(
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 30),
                              child: Text(
                                'Add',
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ),
                    )
                  : Container(
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: Text(
                            'Out of Stock',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
            });
  }

  showDialog(shopName) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Replace Cart item?'),
            content: Text(
                'Your cart contains items from $shopName. Do you want to discard the selection and add items from ${widget.document.data()['seller']['shopName']}'),
            actions: [
              // ignore: deprecated_member_use
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'No',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  )),
              // ignore: deprecated_member_use
              FlatButton(
                  onPressed: () {
                    //delete existing product from cart
                    _cart.deleteCart().then((value) {
                      _cart.addToCart(widget.document).then((value) {
                        setState(() {
                          _exist = true;
                        });
                        Navigator.pop(context);
                      });
                    });
                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  )),
            ],
          );
        });
  }
}
