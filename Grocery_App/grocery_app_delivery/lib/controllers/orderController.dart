import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app_delivery/controllers/firebaseController.dart';
import 'package:map_launcher/map_launcher.dart';

class OrderController {
  FirebaseController _controller = FirebaseController();

  Color statusColor(document) {
    if (document.data()['orderStatus'] == 'Accepted') {
      return Colors.blueGrey[400];
    }
    if (document.data()['orderStatus'] == 'Rejected') {
      return Colors.red;
    }
    if (document.data()['orderStatus'] == 'Pickup') {
      return Colors.pink[900];
    }
    if (document.data()['orderStatus'] == 'On the way') {
      return Colors.deepPurpleAccent;
    }
    if (document.data()['orderStatus'] == 'Delivered') {
      return Colors.green;
    }
    return Colors.orange;
  }

  Icon statusIcon(document) {
    if (document.data()['orderStatus'] == 'Accepted') {
      return Icon(Icons.assignment_turned_in_outlined, color: statusColor(document),);
    }
    if (document.data()['orderStatus'] == 'Pickup') {
      return Icon(Icons.cases, color: statusColor(document),);
    }
    if (document.data()['orderStatus'] == 'On the way') {
      return Icon(Icons.delivery_dining, color: statusColor(document),);
    }
    if (document.data()['orderStatus'] == 'Delivered') {
      return Icon(Icons.shopping_bag_outlined, color: statusColor(document),);
    }
    return Icon(Icons.assignment_turned_in_outlined, color: statusColor(document),);
  }

  Widget statusContainer(DocumentSnapshot document, context) {
    if (document.data()['deliveryBoy']['name'].length > 1) {
      if (document.data()['orderStatus'] == 'Accepted') {
        return Container(
          color: Colors.grey[300],
          height: 50,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 8, 40, 8),
            child: TextButton(
                onPressed: () {
                  EasyLoading.show();
                  _controller
                      .updateStatus(id: document.id, status: 'Pickup')
                      .then((value) {
                    EasyLoading.showSuccess('Order Status is now Pickup');
                  });
                },
                style: ButtonStyle(
                    backgroundColor: ButtonStyleButton.allOrNull<Color>(
                        statusColor(document))),
                child: Text(
                  'Update Status to Pickup',
                  style: TextStyle(color: Colors.white),
                )),
          ),
        );
      }
    }

    if (document.data()['orderStatus'] == 'Pickup') {
      return Container(
        color: Colors.grey[300],
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 8, 40, 8),
          child: TextButton(
              onPressed: () {
                EasyLoading.show();
                _controller
                    .updateStatus(id: document.id, status: 'On the way')
                    .then((value) {
                  EasyLoading.showSuccess('Order Status is now On the way');
                });
              },
              style: ButtonStyle(
                  backgroundColor: ButtonStyleButton.allOrNull<Color>(
                      statusColor(document))),
              child: Text(
                'Update Status to On The Way',
                style: TextStyle(color: Colors.white),
              )),
        ),
      );
    }

    if (document.data()['orderStatus'] == 'On the way') {
      return Container(
        color: Colors.grey[300],
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 8, 40, 8),
          child: TextButton(
              onPressed: () {
                if (document.data()['cod'] == true) {
                  showMyDialog(
                      'Receive Payment', 'Delivered', document.id, context);
                } else {
                  EasyLoading.show();
                  _controller
                      .updateStatus(id: document.id, status: 'Delivered')
                      .then((value) {
                    EasyLoading.showSuccess('Order Status is now Delivered');
                  });
                }
              },
              style: ButtonStyle(
                  backgroundColor:
                      ButtonStyleButton.allOrNull<Color>(statusColor(document))),
              child: Text(
                'Deliver Order',
                style: TextStyle(color: Colors.white),
              )),
        ),
      );
    }

    return Container(
      color: Colors.grey[300],
      height: 30,
      width: MediaQuery.of(context).size.width,
      child: TextButton(
          onPressed: () {},
          style: ButtonStyle(
              backgroundColor:
                  ButtonStyleButton.allOrNull<Color>(statusColor(document))),
          child: Text(
            'Order Completed',
            style: TextStyle(color: Colors.white),
          )),
    );
  }

  showMyDialog(title, status, documentId, context) {
    OrderController _orderController = OrderController();
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text('Make sure you have received payment'),
            actions: [
              TextButton(
                  onPressed: () {
                    EasyLoading.show();
                    _controller
                        .updateStatus(id: documentId, status: 'Delivered')
                        .then((value) {
                      EasyLoading.showSuccess('Order status is now Delivered');
                      Navigator.pop(context);
                    });
                  },
                  child: Text(
                    'RECEIVE',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  )),
            ],
          );
        });
  }

  void launchMap(lat, long, name) async {
    final availableMaps = await MapLauncher.installedMaps;

    await availableMaps.first.showMarker(
      coords: Coords(lat, long),
      title: name,
    );
  }
}
