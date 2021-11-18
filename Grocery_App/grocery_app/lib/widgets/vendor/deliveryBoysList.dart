import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grocery_app/controllers/orderController.dart';
import 'package:grocery_app/controllers/vendor/firebaseVendorController.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryBoysList extends StatefulWidget {
  final DocumentSnapshot document;
  DeliveryBoysList(this.document);

  @override
  _DeliveryBoysListState createState() => _DeliveryBoysListState();
}

class _DeliveryBoysListState extends State<DeliveryBoysList> {
  FirebaseVendorController _controller = FirebaseVendorController();
  OrderController _orderController = OrderController();
  GeoPoint _shopLocation;

  @override
  void initState() {
    _controller.getShopDetails().then((value) {
      if (value != null) {
        if (mounted) {
          setState(() {
            _shopLocation = value.data()['location'];
          });
        }
      } else {
        print('No data');
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(
                'Select Shipper',
                style: TextStyle(color: Colors.white),
              ),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: _controller.boys
                    .where('accVerified', isEqualTo: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return new ListView(
                    shrinkWrap: true,
                    children:
                        snapshot.data.docs.map((DocumentSnapshot document) {
                      GeoPoint location = document.data()['location'];
                      double distanceInMeters = _shopLocation == null
                          ? 0.0
                          : Geolocator.distanceBetween(
                                  _shopLocation.latitude,
                                  _shopLocation.longitude,
                                  location.latitude,
                                  location.longitude) /
                              1000;
                      if (distanceInMeters > 10) {
                        return Container();
                      }
                      return Column(children: [
                        new ListTile(
                          onTap: () {
                            EasyLoading.show(status: 'Assigning Shipper');
                            _controller
                                .selectBoys(
                              orderId: widget.document.id,
                              email: document.data()['email'],
                              phone: document.data()['mobile'],
                              name: document.data()['name'],
                              location: document.data()['location'],
                              image: document.data()['imageUrl'],
                            )
                                .then((value) {
                              EasyLoading.showSuccess('Assigned Shipper');
                              Navigator.pop(context);
                            });
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Image.network(document.data()['imageUrl']),
                          ),
                          title: new Text(document.data()['name']),
                          subtitle: new Text(
                              '${distanceInMeters.toStringAsFixed(0)} km'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    GeoPoint location =
                                        document.data()['location'];
                                    _orderController.launchMap(
                                        location, document.data()['name']);
                                  },
                                  icon: Icon(
                                    Icons.map,
                                    color: Theme.of(context).primaryColor,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    launch(
                                        'tel: 0${document.data()['mobile']}');
                                  },
                                  icon: Icon(
                                    Icons.phone,
                                    color: Theme.of(context).primaryColor,
                                  )),
                            ],
                          ),
                        ),
                        Divider(
                          height: 2,
                          color: Colors.grey,
                        )
                      ]);
                    }).toList(),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
