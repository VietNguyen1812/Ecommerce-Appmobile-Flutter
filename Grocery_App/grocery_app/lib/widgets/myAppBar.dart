import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/models/vendorModel.dart';
import 'package:grocery_app/providers/locationProvider.dart';
import 'package:grocery_app/screens/mapScreen.dart';
import 'package:grocery_app/widgets/customer/searchCardVendorWidget.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppBar extends StatefulWidget {
  @override
  _MyAppBarState createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  static List<Vendor> vendors = [];
  String shopName;
  String _location = '';
  String _address = '';
  DocumentSnapshot document;

  @override
  void initState() {
    getPrefs();

    FirebaseFirestore.instance
        .collection('vendors')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (mounted) {
          setState(() {
            document = doc;
            vendors.add(Vendor(
                shopName: doc.data()['shopName'],
                address: doc.data()['address'],
                mobile: doc.data()['mobile'],
                imageUrl: doc.data()['imageUrl'],
                dialog: doc.data()['dialog'],
                document: doc));
          });
        }
      });
    });

    super.initState();
  }

  getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String location = prefs.getString('location');
    String address = prefs.getString('address');
    setState(() {
      _location = location;
      _address = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationData = Provider.of<LocationProvider>(context);
    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0.0,
      floating: true,
      snap: true,
      // ignore: deprecated_member_use
      title: FlatButton(
        onPressed: () {
          locationData.getCurrentPosition().then((value) {
            if (value != null) {
              pushNewScreenWithRouteSettings(
                context,
                settings: RouteSettings(name: MapScreen.id),
                screen: MapScreen(),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            } else {
              print('Permission not allowed');
            }
          });
        },
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _location == null ? 'Address not set' : _location,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 15,
                  )
                ],
              ),
              Flexible(
                  child: Text(
                _address == null
                    ? 'Press here to set Delivery Location'
                    : _address,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white, fontSize: 12),
              )),
            ]),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            decoration: InputDecoration(
                hintText: 'Search Vendors',
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide.none),
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Colors.white),
            onTap: () {
              showSearch(
                context: context,
                delegate: SearchPage<Vendor>(
                  onQueryUpdate: (s) => print(s),
                  items: vendors,
                  searchLabel: 'Search vendor',
                  suggestion: Center(
                    child: Text('Filter vendor by name, address or mobile'),
                  ),
                  failure: Center(
                    child: Text('No vendor found :('),
                  ),
                  filter: (vendor) => [
                    //this are fields search will happen
                    vendor.shopName,
                    vendor.address,
                    vendor.mobile,
                  ],
                  builder: (vendor) => SearchVendorCard(
                    vendor: vendor,
                    document: vendor.document,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
