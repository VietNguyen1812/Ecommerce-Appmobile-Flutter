import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_admin/constant.dart';
import 'package:grocery_app_admin/controller/firebaseController.dart';

class VendorDetailsBox extends StatefulWidget {
  final String uid;

  VendorDetailsBox(this.uid);

  @override
  _VendorDetailsBoxState createState() => _VendorDetailsBoxState();
}

class _VendorDetailsBoxState extends State<VendorDetailsBox> {
  FirebaseController _controller = FirebaseController();
  num totalRevenue = 0;
  int totalSales = 0;
  int totalProducts = 0;
  int totalOrders = 0;
  int totalActiveOrders = 0;

  @override
  void initState() {
    calTotalProductsVendor();
    calTotalOrdersVendor();
    calTotalActiveOrdersVendor();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _controller.vendors.doc(widget.uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data['revenueShop'] != 0) {
            for (int i = 0; i < 12; i++) {
              this.totalRevenue +=
                  // ignore: unnecessary_brace_in_string_interps
                  snapshot.data['revenueShop']['${i}']['revenue'];
            }
          }
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Stack(children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width * .3,
                  child: ListView(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                snapshot.data['imageUrl'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data['shopName'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 25),
                              ),
                              Text(snapshot.data['dialog']),
                            ],
                          )
                        ],
                      ),
                      Divider(
                        thickness: 4,
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Container(
                                  child: Text(
                                    'Contact Number',
                                    style: kVendorDetailsTextStyle,
                                  ),
                                )),
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Text(':'),
                                  ),
                                ),
                                Expanded(
                                    child: Container(
                                  child: Text('+84${snapshot.data['mobile']}'),
                                ))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Container(
                                  child: Text(
                                    'Email',
                                    style: kVendorDetailsTextStyle,
                                  ),
                                )),
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Text(':'),
                                  ),
                                ),
                                Expanded(
                                    child: Container(
                                  child: Text(snapshot.data['email']),
                                ))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Container(
                                  child: Text(
                                    'Address',
                                    style: kVendorDetailsTextStyle,
                                  ),
                                )),
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Text(':'),
                                  ),
                                ),
                                Expanded(
                                    child: Container(
                                  child: Text(snapshot.data['address']),
                                ))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Divider(
                              thickness: 2,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Container(
                                  child: Text(
                                    'Top Pick Status',
                                    style: kVendorDetailsTextStyle,
                                  ),
                                )),
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Text(''),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                      child: snapshot.data['isTopPicked']
                                          ? Chip(
                                              backgroundColor: Colors.green,
                                              label: Row(
                                                children: [
                                                  Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                  ),
                                                  Text(
                                                    ' Top Picked',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                ],
                                              ),
                                            )
                                          : Container()),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Divider(
                              thickness: 2,
                            ),
                          ),
                          Wrap(
                            children: [
                              SizedBox(
                                height: 120,
                                width: 120,
                                child: Card(
                                  color: Colors.orangeAccent.withOpacity(.9),
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            CupertinoIcons.money_dollar_circle,
                                            size: 50,
                                            color: Colors.black54,
                                          ),
                                          Text('Total Revenue'),
                                          Text(
                                              '${this.totalRevenue.toStringAsFixed(0)}\$')
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 120,
                                width: 120,
                                child: Card(
                                  color: Colors.orangeAccent.withOpacity(.9),
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.shopping_cart,
                                            size: 50,
                                            color: Colors.black54,
                                          ),
                                          Text('Active Orders'),
                                          Text(
                                              this.totalActiveOrders.toString())
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 120,
                                width: 120,
                                child: Card(
                                  color: Colors.orangeAccent.withOpacity(.9),
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.shopping_bag,
                                            size: 50,
                                            color: Colors.black54,
                                          ),
                                          Text('Total Orders'),
                                          Text(this.totalOrders.toString())
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 120,
                                width: 120,
                                child: Card(
                                  color: Colors.orangeAccent.withOpacity(.9),
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.grain_outlined,
                                            size: 50,
                                            color: Colors.black54,
                                          ),
                                          Text('Total Products'),
                                          Text(this.totalProducts.toString())
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 120,
                                width: 120,
                                child: Card(
                                  color: Colors.orangeAccent.withOpacity(.9),
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.list_alt_outlined,
                                            size: 50,
                                            color: Colors.black54,
                                          ),
                                          Text('Total Sales'),
                                          Text(this.totalSales.toString())
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: snapshot.data['accVerified']
                      ? Chip(
                          backgroundColor: Colors.green,
                          label: Row(
                            children: [
                              Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                'Active',
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ))
                      : Chip(
                          backgroundColor: Colors.red,
                          label: Row(
                            children: [
                              Icon(
                                Icons.remove_circle,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                'Inactive',
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          )),
                )
              ]),
            ),
          );
        });
  }

  Future<void> calTotalProductsVendor() async {
    await FirebaseFirestore.instance
        .collection("products")
        .where('published', isEqualTo: true)
        .where('seller.sellerUid', isEqualTo: widget.uid)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        setState(() {
          this.totalProducts++;
          this.totalSales += result.data()['quantitySold'];
        });
      });
    });
  }

  Future<void> calTotalOrdersVendor() async {
    await FirebaseFirestore.instance
        .collection("orders")
        .where('seller.sellerId', isEqualTo: widget.uid)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        setState(() {
          this.totalOrders++;
        });
      });
    });
  }

  Future<void> calTotalActiveOrdersVendor() async {
    await FirebaseFirestore.instance
        .collection("orders")
        .where('orderStatus', isNotEqualTo: 'Ordered')
        .where('seller.sellerId', isEqualTo: widget.uid)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        setState(() {
          this.totalActiveOrders++;
        });
      });
    });
  }
}
