import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/controllers/chatController.dart';
import 'package:grocery_app/controllers/userController.dart';
import 'package:grocery_app/controllers/vendor/firebaseVendorController.dart';
import 'package:grocery_app/models/productModel.dart';
import 'package:grocery_app/providers/storeProvider.dart';
import 'package:grocery_app/screens/chat/chatConversation.dart';
import 'package:grocery_app/widgets/customer/ratingShopWidget.dart';
import 'package:grocery_app/widgets/customer/searchCardWidget.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorAppbar extends StatefulWidget {
  @override
  _VendorAppbarState createState() => _VendorAppbarState();
}

class _VendorAppbarState extends State<VendorAppbar> {
  FirebaseVendorController _vendorController = FirebaseVendorController();
  UserController _userController = UserController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  ChatController _chatController = ChatController();
  static List<Product> products = [];
  String offer;
  String shopName;
  String cusFirstName;
  String cusLastName;
  String cusAvatarImage;
  String cusPhone;
  DocumentSnapshot document;
  int _rating;
  num _stars = 0.0;

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection('products')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          document = doc;
          offer = ((doc.data()['comparedPrice'] - doc.data()['price']) /
                  doc.data()['comparedPrice'] *
                  100)
              .toStringAsFixed(0);
          products.add(Product(
              brand: doc.data()['brand'],
              comparedPrice: doc.data()['comparedPrice'],
              weight: doc.data()['weight'],
              category: doc.data()['category']['mainCategory'],
              image: doc.data()['image'],
              price: doc.data()['price'],
              productName: doc.data()['productName'],
              shopName: doc.data()['seller']['shopName'],
              document: doc));
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    products.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _store = Provider.of<StoreProvider>(context);
    _vendorController.getShopById(_store.storedetails['uid']).then((value) {
      if (mounted) {
        setState(() {
          _stars = value.data()['star'];
        });
      }
    });

    _userController.getUserById(_auth.currentUser.uid).then((value) {
      if (mounted) {
        cusFirstName = value.data()['firstName'];
        cusLastName = value.data()['lastName'];
        cusAvatarImage = value.data()['avatarImage'];
        cusPhone = value.data()['number'];
      }
    });

    mapLauncher() async {
      GeoPoint location = _store.storedetails['location'];
      final availableMaps = await MapLauncher.installedMaps;

      await availableMaps.first.showMarker(
        coords: Coords(location.latitude, location.longitude),
        title: '${_store.storedetails['shopName']} is here',
      );
    }

    return SliverAppBar(
      floating: true,
      snap: true,
      iconTheme: IconThemeData(color: Colors.white),
      expandedHeight: 260,
      flexibleSpace: SizedBox(
        child: Padding(
          padding: const EdgeInsets.only(top: 86),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(_store.storedetails['imageUrl']),
                    )),
                child: Container(
                  color: Colors.grey.withOpacity(.7),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        Text(
                          _store.storedetails['dialog'],
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        Text(
                          _store.storedetails['address'],
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          _store.storedetails['email'],
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Distance: ${_store.distance}km',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        _stars == 0
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.star_outline,
                                    color: Colors.white,
                                  ),
                                  Icon(
                                    Icons.star_outline,
                                    color: Colors.white,
                                  ),
                                  Icon(
                                    Icons.star_outline,
                                    color: Colors.white,
                                  ),
                                  Icon(
                                    Icons.star_outline,
                                    color: Colors.white,
                                  ),
                                  Icon(
                                    Icons.star_outline,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    _stars.toStringAsFixed(1),
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              )
                            : _stars > 0 && _stars < 1
                                ? Row(
                                    children: [
                                      Icon(
                                        Icons.star_half,
                                        color: Colors.white,
                                      ),
                                      Icon(
                                        Icons.star_outline,
                                        color: Colors.white,
                                      ),
                                      Icon(
                                        Icons.star_outline,
                                        color: Colors.white,
                                      ),
                                      Icon(
                                        Icons.star_outline,
                                        color: Colors.white,
                                      ),
                                      Icon(
                                        Icons.star_outline,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        _stars.toStringAsFixed(1),
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  )
                                : _stars == 1
                                    ? Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                          ),
                                          Icon(
                                            Icons.star_outline,
                                            color: Colors.white,
                                          ),
                                          Icon(
                                            Icons.star_outline,
                                            color: Colors.white,
                                          ),
                                          Icon(
                                            Icons.star_outline,
                                            color: Colors.white,
                                          ),
                                          Icon(
                                            Icons.star_outline,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            _stars.toStringAsFixed(1),
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      )
                                    : _stars > 1 && _stars < 2
                                        ? Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.white,
                                              ),
                                              Icon(
                                                Icons.star_half,
                                                color: Colors.white,
                                              ),
                                              Icon(
                                                Icons.star_outline,
                                                color: Colors.white,
                                              ),
                                              Icon(
                                                Icons.star_outline,
                                                color: Colors.white,
                                              ),
                                              Icon(
                                                Icons.star_outline,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                _stars.toStringAsFixed(1),
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            ],
                                          )
                                        : _stars == 2
                                            ? Row(
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.white,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.white,
                                                  ),
                                                  Icon(
                                                    Icons.star_outline,
                                                    color: Colors.white,
                                                  ),
                                                  Icon(
                                                    Icons.star_outline,
                                                    color: Colors.white,
                                                  ),
                                                  Icon(
                                                    Icons.star_outline,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    _stars.toStringAsFixed(1),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                ],
                                              )
                                            : _stars > 2 && _stars < 3
                                                ? Row(
                                                    children: [
                                                      Icon(
                                                        Icons.star,
                                                        color: Colors.white,
                                                      ),
                                                      Icon(
                                                        Icons.star,
                                                        color: Colors.white,
                                                      ),
                                                      Icon(
                                                        Icons.star_half,
                                                        color: Colors.white,
                                                      ),
                                                      Icon(
                                                        Icons.star_outline,
                                                        color: Colors.white,
                                                      ),
                                                      Icon(
                                                        Icons.star_outline,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        _stars
                                                            .toStringAsFixed(1),
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      )
                                                    ],
                                                  )
                                                : _stars == 3
                                                    ? Row(
                                                        children: [
                                                          Icon(
                                                            Icons.star,
                                                            color: Colors.white,
                                                          ),
                                                          Icon(
                                                            Icons.star,
                                                            color: Colors.white,
                                                          ),
                                                          Icon(
                                                            Icons.star,
                                                            color: Colors.white,
                                                          ),
                                                          Icon(
                                                            Icons.star_outline,
                                                            color: Colors.white,
                                                          ),
                                                          Icon(
                                                            Icons.star_outline,
                                                            color: Colors.white,
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            _stars
                                                                .toStringAsFixed(
                                                                    1),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          )
                                                        ],
                                                      )
                                                    : _stars > 3 && _stars < 4
                                                        ? Row(
                                                            children: [
                                                              Icon(
                                                                Icons.star,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              Icon(
                                                                Icons.star,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              Icon(
                                                                Icons.star,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              Icon(
                                                                Icons.star_half,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              Icon(
                                                                Icons
                                                                    .star_outline,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                _stars
                                                                    .toStringAsFixed(
                                                                        1),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              )
                                                            ],
                                                          )
                                                        : _stars == 4
                                                            ? Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons.star,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  Icon(
                                                                    Icons.star,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  Icon(
                                                                    Icons.star,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  Icon(
                                                                    Icons.star,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  Icon(
                                                                    Icons
                                                                        .star_outline,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Text(
                                                                    _stars
                                                                        .toStringAsFixed(
                                                                            1),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  )
                                                                ],
                                                              )
                                                            : _stars > 4 &&
                                                                    _stars < 5
                                                                ? Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .star_half,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                        _stars.toStringAsFixed(
                                                                            1),
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      )
                                                                    ],
                                                                  )
                                                                : Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                        _stars.toStringAsFixed(
                                                                            1),
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      )
                                                                    ],
                                                                  ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // ignore: deprecated_member_use
                            RaisedButton(
                                color: Theme.of(context).primaryColor,
                                child: Text(
                                  'Vote Shop',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Container(
                                            width: 100,
                                            height: 150,
                                            color: Colors.white,
                                            child: Rating((rating) {
                                              setState(() {
                                                _rating = rating;
                                              });
                                            }, 5),
                                          ),
                                        );
                                      });
                                }),
                            SizedBox(
                              width: 10,
                            ),
                            // ignore: deprecated_member_use
                            RaisedButton(
                                color: Theme.of(context).primaryColor,
                                child: Text(
                                  'Chat with Shop',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  createChatRoom();
                                }),
                            SizedBox(
                              width: 40,
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: Icon(
                                  Icons.phone,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: () {
                                  launch(
                                      'tel: 0${_store.storedetails['mobile']}');
                                },
                              ),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: Icon(
                                  Icons.map,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: () {
                                  mapLauncher();
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              shopName = _store.storedetails['shopName'];
            });
            showSearch(
              context: context,
              delegate: SearchPage<Product>(
                onQueryUpdate: (s) => print(s),
                items: products,
                searchLabel: 'Search product',
                suggestion: Center(
                  child: Text('Filter product by name, category or price'),
                ),
                failure: Center(
                  child: Text('No product found :('),
                ),
                filter: (product) => [
                  //this are fields search will happen
                  product.productName,
                  product.category,
                  product.brand,
                  product.price.toString(),
                ],
                builder: (product) => shopName != product.shopName
                    ? Container()
                    : SearchCard(
                        offer: offer,
                        product: product,
                        document: product.document,
                      ),
              ),
            );
          },
          icon: Icon(CupertinoIcons.search),
        )
      ],
      title: Text(
        _store.storedetails['shopName'],
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  createChatRoom() {
    var _store = Provider.of<StoreProvider>(context, listen: false);
    Map<String, dynamic> product = {
      'productId': null,
      'shopName': null,
      'title': null,
      'productImage': null,
      'price': null,
      'chatProduct': false
    };
    Map<String, dynamic> customer = {
      'cusId': _auth.currentUser.uid,
      'firstName': cusFirstName,
      'lastName': cusLastName,
      'avatarImage': cusAvatarImage,
      'phone': cusPhone
    };
    Map<String, dynamic> vendor = {
      'sellerId': _store.storedetails['uid'],
      'shopName': _store.storedetails['shopName'],
      'vendorImage': _store.storedetails['imageUrl'],
      'email': _store.storedetails['email'],
      'phone': _store.storedetails['mobile']
    };
    List<String> users = [
      //seller & customer
      _store.storedetails['uid'], //seller
      _auth.currentUser.uid //customer
    ];
    String chatRoomId =
        '${_store.storedetails['uid']}.${_auth.currentUser.uid}';
    Map<String, dynamic> chatData = {
      'users': users,
      'customer': customer,
      'vendor': vendor,
      'chatRoomId': chatRoomId,
      'read': false,
      'product': product,
      'lastChat': null,
      'lastChatTime': DateTime.now().microsecondsSinceEpoch
    };
    _chatController.createChatRoom(chatData: chatData);
    pushNewScreenWithRouteSettings(
      context,
      settings: RouteSettings(name: ChatConversationScreen.id),
      screen: ChatConversationScreen(document, chatRoomId),
      withNavBar: true,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }
}
