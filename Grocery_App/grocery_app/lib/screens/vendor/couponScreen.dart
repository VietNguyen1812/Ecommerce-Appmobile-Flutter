import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/controllers/vendor/firebaseVendorController.dart';
import 'package:grocery_app/screens/vendor/addEditCouponScreen.dart';
import 'package:intl/intl.dart';

class CouponScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseVendorController _controller = FirebaseVendorController();

    return Scaffold(
      body: Container(
        child: StreamBuilder(
          stream: _controller.coupons
              .where('sellerId', isEqualTo: _controller.user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            return new Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    // ignore: deprecated_member_use
                    child: FlatButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AddEditCoupon.id);
                        },
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          'Add New Coupon',
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                ]),
                FittedBox(
                  child: DataTable(columns: <DataColumn>[
                    DataColumn(label: Text('Title')),
                    DataColumn(label: Text('Rate')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Info')),
                    DataColumn(label: Text('Expiry')),
                  ], rows: _couponList(snapshot.data, context)),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  List<DataRow> _couponList(QuerySnapshot snapshot, context) {
    List<DataRow> newList = snapshot.docs.map((DocumentSnapshot document) {
      if (document != null) {
        var date = document.data()['expiry'];
        var expiry = DateFormat.yMMMd().add_jm().format(date.toDate());
        return DataRow(cells: [
          DataCell(Text(document.data()['title'])),
          DataCell(Text(document.data()['discountRate'].toString())),
          DataCell(Text(document.data()['active'] ? 'Active' : 'Inactive')),
          DataCell(Text(expiry.toString())),
          DataCell(IconButton(
            icon: Icon(Icons.info_outline_rounded),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddEditCoupon(
                            document: document,
                          )));
            },
          ))
        ]);
      }
    }).toList();
    return newList;
  }
}
