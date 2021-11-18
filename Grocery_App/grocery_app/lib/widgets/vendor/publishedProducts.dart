import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/controllers/vendor/firebaseVendorController.dart';
import 'package:grocery_app/screens/vendor/editViewProduct.dart';

class PublishedProduct extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser;
    FirebaseVendorController _controller = FirebaseVendorController();

    return Container(
      child: StreamBuilder(
          stream: _controller.products
              .where('published', isEqualTo: true)
              .where('seller.sellerUid', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong...');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return SingleChildScrollView(
              child: FittedBox(
                child: DataTable(
                  showBottomBorder: true,
                  dataRowHeight: 60,
                  headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                  columns: <DataColumn>[
                    DataColumn(
                        label: Expanded(
                      child: Text('Product'),
                    )),
                    DataColumn(
                      label: Text('Image'),
                    ),
                    DataColumn(
                      label: Text('Info'),
                    ),
                    DataColumn(
                      label: Text('Actions'),
                    ),
                  ],
                  rows: _productDetails(snapshot.data, context),
                ),
              ),
            );
          }),
    );
  }

  List<DataRow> _productDetails(QuerySnapshot snapshot, context) {
    List<DataRow> newList = snapshot.docs.map((DocumentSnapshot document) {
      if (document != null) {
        return DataRow(cells: [
          DataCell(Container(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(children: [
                Text(
                  'Name: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Expanded(
                    child: Text(document.data()['productName'],
                        style: TextStyle(fontSize: 15)))
              ]),
              subtitle: Row(children: [
                Text(
                  'SKU: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  document.data()['sku'],
                  style: TextStyle(fontSize: 12),
                )
              ]),
            ),
          )),
          DataCell(Container(
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Row(children: [
                Image.network(
                  document.data()['productImage'],
                  width: 50,
                )
              ]),
            ),
          )),
          DataCell(IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditViewProduct(
                            productId: document.data()['productId'],
                          )));
            },
            icon: Icon(Icons.info_outline),
          )),
          DataCell(popUpButton(document.data())),
        ]);
      }
    }).toList();
    return newList;
  }

  Widget popUpButton(data, {BuildContext context}) {
    FirebaseVendorController _controller = FirebaseVendorController();

    return PopupMenuButton<String>(
        onSelected: (String value) {
          if (value == 'unpublish') {
            _controller.unPublishProduct(id: data['productId']);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                  value: 'unpublish',
                  child: ListTile(
                    leading: Icon(Icons.check),
                    title: Text('Unpublish'),
                  )),
            ]);
  }
}
