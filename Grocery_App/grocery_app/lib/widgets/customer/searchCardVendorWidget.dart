import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grocery_app/controllers/storeController.dart';
import 'package:grocery_app/models/vendorModel.dart';
import 'package:grocery_app/providers/storeProvider.dart';
import 'package:grocery_app/screens/customer/vendorHomeScreen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class SearchVendorCard extends StatelessWidget {
  const SearchVendorCard({
    Key key,
    @required this.vendor,
    @required this.document,
  }) : super(key: key);

  final Vendor vendor;
  final DocumentSnapshot document;

  @override
  Widget build(BuildContext context) {
    final _storeData = Provider.of<StoreProvider>(context);
    _storeData.getUserLocationData(context);
    StoreController _storeController = StoreController();

    String getDistance(location) {
      var distance = Geolocator.distanceBetween(_storeData.userLatitude,
          _storeData.userLongitude, location.latitude, location.longitude);
      var distanceInKm = distance / 1000;
      return distanceInKm.toStringAsFixed(2);
    }

    return Container(
      height: 160,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(width: 1, color: Colors.grey[300]))),
      child: StreamBuilder<QuerySnapshot>(
          stream: _storeController.getTopPickedStore(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapShot) {
            return Padding(
              padding:
                  const EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
              child: Row(
                children: [
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        _storeData.getSelectedStore(vendor.document,
                            getDistance(vendor.document['location']));
                        pushNewScreenWithRouteSettings(
                          context,
                          settings: RouteSettings(name: VendorHomeScreen.id),
                          screen: VendorHomeScreen(),
                          withNavBar: true,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                      child: SizedBox(
                        height: 140,
                        width: 130,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Hero(
                                tag:
                                    'vendor${vendor.document.data()['shopName']}',
                                child: Image.network(
                                    vendor.document.data()['imageUrl']))),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vendor.document.data()['dialog'],
                                style: TextStyle(fontSize: 10),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                vendor.document.data()['shopName'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width - 160,
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, left: 6),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.grey[200]),
                                child: Text(
                                  '+84 ${vendor.document.data()['mobile']}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600]),
                                ),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Container(
                                width: 250,
                                child: Text(
                                  vendor.document.data()['address'],
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }
}
