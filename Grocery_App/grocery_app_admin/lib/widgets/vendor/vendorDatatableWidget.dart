import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_admin/controller/firebaseController.dart';

import 'vendorDetailsBox.dart';

class VendorDatatable extends StatefulWidget {
  @override
  _VendorDatatableState createState() => _VendorDatatableState();
}

class _VendorDatatableState extends State<VendorDatatable> {
  FirebaseController _controller = FirebaseController();

  int tag = 0;
  List<String> options = [
    'All Vendors',
    'Active Vendors',
    'Inactive Vendors',
    'Top Picked',
    'Top Rated',
  ];

  bool topPicked;
  bool active;

  filter(val) {
    if (val == 0) {
      setState(() {
        active = null;
        topPicked = null;
      });
    }
    if (val == 1) {
      setState(() {
        active = true;
      });
    }
    if (val == 2) {
      setState(() {
        active = false;
      });
    }
    if (val == 3) {
      setState(() {
        topPicked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ChipsChoice<int>.single(
        value: tag,
        onChanged: (val) {
          setState(() {
            tag = val;
          });
          filter(val);
        },
        choiceItems: C2Choice.listFrom<int, String>(
          activeStyle: (i, v) {
            return C2ChoiceStyle(
                brightness: Brightness.dark, color: Colors.black54);
          },
          source: options,
          value: (i, v) => i,
          label: (i, v) => v,
        ),
      ),
      Divider(
        thickness: 5,
      ),
      StreamBuilder(
          stream: _controller.vendors
              .where('isTopPicked', isEqualTo: topPicked)
              .where('accVerified', isEqualTo: active)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 38.0,
                showBottomBorder: true,
                dataRowHeight: 60,
                headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                //table headers
                columns: <DataColumn>[
                  DataColumn(
                    label: Text('Active/Inactive'),
                  ),
                  DataColumn(
                    label: Text('Top Picked'),
                  ),
                  DataColumn(
                    label: Text('Shop Name'),
                  ),
                  DataColumn(
                    label: Text('Rating'),
                  ),
                  DataColumn(
                    label: Text('Total Votes'),
                  ),
                  DataColumn(
                    label: Text('Mobile'),
                  ),
                  DataColumn(
                    label: Text('Email'),
                  ),
                  DataColumn(
                    label: Text('View Details'),
                  ),
                ],
                //details
                rows: _vendorDetailsRows(snapshot.data, _controller),
              ),
            );
          }),
    ]);
  }

  List<DataRow> _vendorDetailsRows(
      QuerySnapshot snapshot, FirebaseController controller) {
    List<DataRow> newList = snapshot.docs.map((DocumentSnapshot document) {
      return DataRow(cells: [
        DataCell(
          IconButton(
            onPressed: () {
              controller.updateVendorStatus(
                  id: document.data()['uid'],
                  field: 'accVerified',
                  status: document.data()['accVerified']);
            },
            icon: document.data()['accVerified']
                ? Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  )
                : Icon(
                    Icons.remove_circle,
                    color: Colors.red,
                  ),
          ),
        ),
        DataCell(
          IconButton(
            onPressed: () {
              controller.updateVendorStatus(
                  id: document.data()['uid'],
                  field: 'isTopPicked',
                  status: document.data()['isTopPicked']);
            },
            icon: document.data()['isTopPicked']
                ? Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  )
                : Icon(null),
          ),
        ),
        DataCell(Text(document.data()['shopName'])),
        DataCell(Row(
          children: [
            Icon(
              Icons.star,
              color: Colors.grey,
            ),
            Text(document.data()['star'].toStringAsFixed(1))
          ],
        )),
        DataCell(Center(child: Text(document.data()['totalRating'].toString()))),
        DataCell(Text('0${document.data()['mobile']}')),
        DataCell(Text(document.data()['email'])),
        DataCell(Center(
          child: IconButton(
            icon: Icon(Icons.info_outlined),
            onPressed: () {
              showDialog(
                context: context, 
                builder: (BuildContext context) {
                  return VendorDetailsBox(document.data()['uid']);
                }
              );
            },
          ),
        ))
      ]);
    }).toList();
    return newList;
  }
}
