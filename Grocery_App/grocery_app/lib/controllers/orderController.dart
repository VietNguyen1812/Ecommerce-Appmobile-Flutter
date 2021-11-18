import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/controllers/customer/productController.dart';
import 'package:grocery_app/controllers/vendor/firebaseVendorController.dart';
import 'package:grocery_app/providers/vendor/productProvider.dart';
import 'package:grocery_app/widgets/vendor/deliveryBoysList.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderController {
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  ProductController _productController = ProductController();
  ProductProvider _productProvider = ProductProvider();
  FirebaseVendorController _vendorController = FirebaseVendorController();

  int stockQty = 0;
  int quantitySold = 0;
  double revenueProduct = 0.0;
  double revenueShop = 0.0;

  Future<DocumentReference> saveOrder(Map<String, dynamic> data) {
    var result = orders.add(data);

    return result;
  }

  Future<void> updateOrderStatus(documentId, status) {
    var result = orders.doc(documentId).update({'orderStatus': status});
    return result;
  }

  Future<void> updateProductSold(documentId, sold) {
    var result = orders.doc(documentId).update({'sold': sold});
    return result;
  }

  Future<void> deleteOrder(documentId) {
    return orders.doc(documentId).delete();
  }

  String statusComment(document) {
    if (document.data()['orderStatus'] == 'Pickup') {
      return 'Your order is Picked by ${document.data()['deliveryBoy']['name']}';
    }
    if (document.data()['orderStatus'] == 'On the way') {
      return 'Your shipper ${document.data()['deliveryBoy']['name']} is on the way';
    }
    if (document.data()['orderStatus'] == 'Delivered') {
      return 'Your order is now completed';
    }
    return '${document.data()['deliveryBoy']['name']} is on the way yo Pick your Order';
  }

  Color statusColor(DocumentSnapshot document) {
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
      return Icon(
        Icons.assignment_turned_in_outlined,
        color: statusColor(document),
      );
    }
    if (document.data()['orderStatus'] == 'Pickup') {
      return Icon(
        Icons.cases,
        color: statusColor(document),
      );
    }
    if (document.data()['orderStatus'] == 'On the way') {
      return Icon(
        Icons.delivery_dining,
        color: statusColor(document),
      );
    }
    if (document.data()['orderStatus'] == 'Delivered') {
      return Icon(
        Icons.shopping_bag_outlined,
        color: statusColor(document),
      );
    }
    return Icon(
      Icons.assignment_turned_in_outlined,
      color: statusColor(document),
    );
  }

  showMyDialog(title, status, documentId, context) {
    OrderController _orderController = OrderController();
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text('Are you sure?'),
            actions: [
              TextButton(
                  onPressed: () {
                    EasyLoading.show(status: 'Updating status');
                    status == 'Accepted'
                        ? _orderController
                            .updateOrderStatus(documentId, status)
                            .then((value) {
                            EasyLoading.showSuccess('Successfully Updated');
                          })
                        : _orderController
                            .updateOrderStatus(documentId, status)
                            .then((value) {
                            EasyLoading.showSuccess('Successfully Updated');
                          });
                    Navigator.pop(context);
                  },
                  child: Text(
                    'OK',
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

  showDeleteDialog(title, status, documentId, context) {
    OrderController _orderController = OrderController();
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text('Are you sure?'),
            actions: [
              TextButton(
                  onPressed: () {
                    EasyLoading.show(status: 'Deleting order');
                    status == 'Accepted'
                        ? _orderController
                            .deleteOrder(documentId)
                            .then((value) {
                            EasyLoading.showSuccess('Successfully Deleted');
                          })
                        : _orderController
                            .deleteOrder(documentId)
                            .then((value) {
                            EasyLoading.showSuccess('Successfully Deleted');
                          });
                    Navigator.pop(context);
                  },
                  child: Text(
                    'OK',
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

  Widget statusContainer(DocumentSnapshot document, context) {
    if (document.data()['deliveryBoy']['name'].length > 1) {
      return document.data()['deliveryBoy']['image'] == null
          ? Container()
          : ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.network(document.data()['deliveryBoy']['image']),
              ),
              title: new Text(document.data()['deliveryBoy']['name']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      GeoPoint location =
                          document.data()['deliveryBoy']['location'];
                      launchMap(
                          location, document.data()['deliveryBoy']['name']);
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(4)),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, top: 2, bottom: 2),
                          child: Icon(
                            Icons.map,
                            color: Colors.white,
                          ),
                        )),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      launch(
                          'tel: 0${document.data()['deliveryBoy']['phone']}');
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(4)),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, top: 2, bottom: 2),
                          child: Icon(
                            Icons.phone_in_talk,
                            color: Colors.white,
                          ),
                        )),
                  ),
                ],
              ),
            );
    }

    if (document.data()['orderStatus'] == 'Ordered') {
      return Container(
        color: Colors.grey[300],
        height: 50,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                // ignore: deprecated_member_use
                child: FlatButton(
                    onPressed: () {
                      showMyDialog(
                          'Accept Order', 'Accepted', document.id, context);
                    },
                    color: Colors.blueGrey,
                    child: Text(
                      'Accept',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AbsorbPointer(
                  absorbing: document.data()['orderStatus'] == 'Rejected'
                      ? true
                      : false,
                  // ignore: deprecated_member_use
                  child: FlatButton(
                      onPressed: () {
                        showMyDialog(
                            'Reject Order', 'Rejected', document.id, context);
                      },
                      color: document.data()['orderStatus'] == 'Rejected'
                          ? Colors.grey
                          : Colors.red,
                      child: Text(
                        'Reject',
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container();
  }

  Widget statusAcceptedContainer(DocumentSnapshot document, context) {
    if (document.data()['orderStatus'] == 'Accepted') {
      return Container(
        color: Colors.grey[300],
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 8, 40, 8),
          child: TextButton(
              onPressed: () {
                print('Assign Shipper');
                //Delivery boys list
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DeliveryBoysList(document);
                    });
              },
              style: ButtonStyle(
                  backgroundColor:
                      ButtonStyleButton.allOrNull<Color>(Colors.orangeAccent)),
              child: Text(
                'Select Shipper',
                style: TextStyle(color: Colors.white),
              )),
        ),
      );
    }
    return Container();
  }

  Widget statusRejectedContainer(DocumentSnapshot document, context) {
    if (document.data()['orderStatus'] == 'Ordered') {
      return Container(
        color: Colors.grey[300],
        height: 50,
        width: 300,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AbsorbPointer(
            absorbing:
                document.data()['orderStatus'] == 'Rejected' ? true : false,
            // ignore: deprecated_member_use
            child: FlatButton(
                onPressed: () {
                  showMyDialog(
                      'Reject Order', 'Rejected', document.id, context);
                },
                color: document.data()['orderStatus'] == 'Rejected'
                    ? Colors.grey
                    : Colors.red,
                child: Text(
                  'Reject Order',
                  style: TextStyle(color: Colors.white),
                )),
          ),
        ),
      );
    }
    return Container();
  }

  Widget statusDeleteContainer(DocumentSnapshot document, context) {
    //if (document.data()['orderStatus'] == 'Rejected') {
    return Container(
      color: Colors.grey[300],
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 8, 40, 8),
        child: TextButton(
            onPressed: () {
              showDeleteDialog('Delete Order', 'Deleted', document.id, context);
            },
            style: ButtonStyle(
                backgroundColor:
                    ButtonStyleButton.allOrNull<Color>(Colors.red)),
            child: Text(
              'Delete Order',
              style: TextStyle(color: Colors.white),
            )),
      ),
    );
    //}
    //return Container();
  }

  Widget statusSoldContainer(DocumentSnapshot document, context) {
    OrderController _orderController = OrderController();
    if (document.data()['orderStatus'] == 'Delivered') {
      return Container(
        color: Colors.grey[300],
        height: 50,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AbsorbPointer(
                  absorbing: document.data()['sold'] == true ? true : false,
                  // ignore: deprecated_member_use
                  child: FlatButton(
                      onPressed: () {
                        _orderController
                            .updateProductSold(document.id, true)
                            .then((value) {
                          EasyLoading.showSuccess('Successfully Updated');
                          for (int i = 0; i < document.data().length; i++) {
                            _productController.products
                                .doc(document
                                    .data()['products'][i]['productId']
                                    .toString())
                                .get()
                                .then((DocumentSnapshot document1) {
                              if (document.data()['products'][i]['productId'] ==
                                  document1.data()['productId']) {
                                stockQty = document1.data()['stockQty'] -
                                    document.data()['products'][i]['qty'];
                                quantitySold =
                                    document1.data()['quantitySold'] +
                                        document.data()['products'][i]['qty'];
                                revenueProduct = document1.data()['price'] *
                                    document.data()['products'][i]['qty'];
                                _productProvider.updateQuantityProduct(
                                    stockQty: stockQty,
                                    productId: document.data()['products'][i]
                                        ['productId']);
                                _productProvider.updateQuantityProductSold(
                                    quantitySold: quantitySold,
                                    productId: document.data()['products'][i]
                                        ['productId']);
                                revenueShop = document.data()['total'] -
                                    document.data()['deliveryFee'];
                                _productProvider.calculateRevenueProduct(
                                    document.data()['products'][i]['productId'],
                                    revenueProduct,
                                    context);
                                _vendorController.calculateRevenueShop(
                                    revenueShop, context);
                              }
                            });
                          }
                        });
                      },
                      color: document.data()['orderStatus'] != 'Delivered'
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                      child: Text(
                        'Products Sold',
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AbsorbPointer(
                  absorbing: document.data()['orderStatus'] == 'Rejected'
                      ? true
                      : false,
                  // ignore: deprecated_member_use
                  child: FlatButton(
                      onPressed: () {
                        showMyDialog(
                            'Reject Order', 'Rejected', document.id, context);
                      },
                      color: document.data()['orderStatus'] == 'Rejected'
                          ? Colors.grey
                          : Colors.red,
                      child: Text(
                        'Delivery Rejection',
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container();
  }

  void launchMap(GeoPoint location, name) async {
    final availableMaps = await MapLauncher.installedMaps;

    await availableMaps.first.showMarker(
      coords: Coords(location.latitude, location.longitude),
      title: name,
    );
  }
}
