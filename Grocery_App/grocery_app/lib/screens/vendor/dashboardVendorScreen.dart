import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/controllers/vendor/firebaseVendorController.dart';
import 'package:grocery_app/widgets/vendor/cartesianChartVendorRevenueWidget.dart';
import 'package:grocery_app/widgets/vendor/bestSellingProductsTable.dart';
import 'package:grocery_app/widgets/vendor/circularChartProductRatingWidget.dart';
import 'package:grocery_app/widgets/vendor/topProductsRevenueThisMonthTable.dart';

class MainVendorScreen extends StatefulWidget {
  @override
  _MainVendorScreenState createState() => _MainVendorScreenState();
}

class _MainVendorScreenState extends State<MainVendorScreen> {
  FirebaseVendorController _vendorController = FirebaseVendorController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  DocumentSnapshot doc;

  num dem0 = 0;
  num dem1 = 0;
  num dem2 = 0;
  num dem3 = 0;
  num dem4 = 0;
  num dem5 = 0;

  @override
  void initState() {
    calPercentProductsRating();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: _vendorController.vendors
              .where('uid', isEqualTo: _auth.currentUser.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return SingleChildScrollView(
              child: Column(children: [
                Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  color: Theme.of(context).primaryColor,
                  child: Center(
                    child: Text(
                      'Dashboard',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children:
                        snapshot.data.docs.map((DocumentSnapshot document) {
                      return CartesianChartVendorRevenueWidget(document);
                    }).toList(),
                  ),
                ),
                Column(children: [
                  CircularChartProductRatingWidget(this.dem0, this.dem1,
                      this.dem2, this.dem3, this.dem4, this.dem5),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                      child: Text(
                    'TOP 5 BEST SELLING PRODUCTS',
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Segoe UI',
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor),
                  )),
                  SizedBox(
                    height: 10,
                  ),
                  BestSellingProductsTable(),
                  SizedBox(
                    height: 50,
                  ),
                  Center(
                      child: Text(
                    'TOP 5 BEST PRODUCT REVENUE OF THIS MONTH',
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Segoe UI',
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor),
                  )),
                  SizedBox(
                    height: 10,
                  ),
                  TopProductsRevenueThisMonthTable()
                ])
              ]),
            );
          }),
    );
  }

  Future<void> calPercentProductsRating() async {
    await FirebaseFirestore.instance
        .collection("products")
        .where('published', isEqualTo: true)
        .where('seller.sellerUid', isEqualTo: _auth.currentUser.uid)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        if (result.data()['star'] >= 0 && result.data()['star'] < 1) {
          setState(() {
            dem0++;
          });
        } else if (result.data()['star'] >= 1 && result.data()['star'] < 2) {
          setState(() {
            dem1++;
          });
        } else if (result.data()['star'] >= 2 && result.data()['star'] < 3) {
          setState(() {
            dem2++;
          });
        } else if (result.data()['star'] >= 3 && result.data()['star'] < 4) {
          setState(() {
            dem3++;
          });
        } else if (result.data()['star'] >= 4 && result.data()['star'] < 5) {
          setState(() {
            dem4++;
          });
        } else {
          setState(() {
            dem5++;
          });
        }
      });
    });
  }
}
