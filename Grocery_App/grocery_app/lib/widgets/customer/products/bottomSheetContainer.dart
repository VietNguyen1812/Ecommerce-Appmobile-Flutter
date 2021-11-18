import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/controllers/chatController.dart';
import 'package:grocery_app/controllers/userController.dart';
import 'package:grocery_app/controllers/vendor/firebaseVendorController.dart';
import 'package:grocery_app/screens/chat/chatConversation.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'addToCartWidget.dart';
import 'saveForLater.dart';

class BottomSheetContainer extends StatefulWidget {
  final DocumentSnapshot document;
  BottomSheetContainer(this.document);

  @override
  _BottomSheetContainerState createState() => _BottomSheetContainerState();
}

class _BottomSheetContainerState extends State<BottomSheetContainer> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  ChatController _chatController = ChatController();
  FirebaseVendorController _vendorController = FirebaseVendorController();
  UserController _userController = UserController();
  String vendorMobile;
  String cusFirstName;
  String cusLastName;
  String cusAvatarImage;
  String cusPhone;

  createChatRoom() {
    Map<String, dynamic> product = {
      'productId': widget.document.data()['productId'],
      'shopName': widget.document.data()['seller']['shopName'],
      'title': widget.document.data()['productName'],
      'productImage': widget.document.data()['productImage'],
      'price': widget.document.data()['price'],
      'chatProduct': true
    };
    Map<String, dynamic> customer = {
      'cusId': _auth.currentUser.uid,
      'firstName': cusFirstName,
      'lastName': cusLastName,
      'avatarImage': cusAvatarImage,
      'phone': cusPhone
    };
    Map<String, dynamic> vendor = {
      'sellerId': null,
      'shopName': null,
      'vendorImage': null,
      'email': null,
      'phone': vendorMobile
    };
    List<String> users = [
      //seller & customer
      widget.document.data()['seller']['sellerUid'], //seller
      _auth.currentUser.uid //customer
    ];
    String chatRoomId =
        '${widget.document.data()['seller']['sellerUid']}.${_auth.currentUser.uid}.${widget.document.data()['productId']}';
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
      screen: ChatConversationScreen(widget.document, chatRoomId),
      withNavBar: true,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  @override
  Widget build(BuildContext context) {
    _vendorController
        .getShopById(widget.document.data()['seller']['sellerUid'])
        .then((value) {
      if (mounted) {
        setState(() {
          vendorMobile = value.data()['mobile'];
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

    return Container(
      child: Row(
        children: [
          Flexible(
              flex: 0,
              child: Container(
                height: 56,
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: IconButton(
                      color: Colors.white,
                      onPressed: () {
                        createChatRoom();
                      },
                      icon: Icon(Icons.messenger_outline)),
                ),
              )),
          Flexible(
              flex: 0,
              child: Container(
                  height: 56,
                  color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
                    child: Text(
                      '|',
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                  ))),
          Flexible(flex: 0, child: SaveForLater(widget.document)),
          Flexible(flex: 2, child: AddToCartWidget(widget.document)),
        ],
      ),
    );
  }
}
