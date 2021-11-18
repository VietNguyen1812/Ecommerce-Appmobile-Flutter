import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grocery_app/controllers/storeController.dart';
import 'package:grocery_app/providers/storeProvider.dart';
import 'package:grocery_app/screens/customer/vendorHomeScreen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class TopPickStore extends StatefulWidget {
  @override
  _TopPickStoreState createState() => _TopPickStoreState();
}

class _TopPickStoreState extends State<TopPickStore> {
  @override
  Widget build(BuildContext context) {
    StoreController _storeController = StoreController();
    final _storeData = Provider.of<StoreProvider>(context);
    _storeData.getUserLocationData(context);

    String getDistance(location) {
      var distance = Geolocator.distanceBetween(_storeData.userLatitude,
          _storeData.userLongitude, location.latitude, location.longitude);
      var distanceInKm = distance / 1000;
      return distanceInKm.toStringAsFixed(2);
    }

    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: _storeController.getTopPickedStore(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapShot) {
          if (!snapShot.hasData)
            return Center(child: CircularProgressIndicator());

          if (snapShot.hasError) {
            return Text('Something went wrong');
          }
          List shopDistance = [];
          for (int i = 0; i <= snapShot.data.docs.length - 1; i++) {
            var distance = Geolocator.distanceBetween(
                _storeData.userLatitude,
                _storeData.userLongitude,
                snapShot.data.docs[i]['location'].latitude,
                snapShot.data.docs[i]['location'].longitude);
            var distanceInKm = distance / 1000;
            shopDistance.add(distanceInKm);
          }
          shopDistance.sort();
          if (shopDistance[0] > 10) {
            return Container();
          }
          return Container(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 20),
                    child: Row(
                      children: [
                        SizedBox(
                            height: 30, child: Image.asset('images/like.gif')),
                        Text(
                          'Top Picked Stores For You',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                          snapShot.data.docs.map((DocumentSnapshot document) {
                        //show the stores only with in 10km
                        if (double.parse(getDistance(document['location'])) <=
                            10) {
                          return InkWell(
                            onTap: () {
                              _storeData.getSelectedStore(
                                  document, getDistance(document['location']));
                              pushNewScreenWithRouteSettings(
                                context,
                                settings:
                                    RouteSettings(name: VendorHomeScreen.id),
                                screen: VendorHomeScreen(),
                                withNavBar: true,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(7.5),
                              child: Container(
                                width: 80,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                          width: 80,
                                          height: 80,
                                          child: Card(
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: Image.network(
                                                    document['imageUrl'],
                                                    fit: BoxFit.cover,
                                                  )))),
                                      Container(
                                        height: 35,
                                        child: Text(
                                          document['shopName'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${getDistance(document['location'])}Km',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 10),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
