import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/controllers/chatController.dart';
import 'package:grocery_app/screens/chat/vendor/chatCardVendor.dart';

class ChatScreenVendor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ChatController _chatController = ChatController();
    FirebaseAuth _auth = FirebaseAuth.instance;

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: TabBar(
          labelStyle: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
          labelColor: Theme.of(context).primaryColor,
          indicatorWeight: 5,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(
              text: 'CUSTOMER',
            ),
            Tab(
              text: 'PRODUCT',
            ),
          ],
        ),
        body: TabBarView(children: [
          Container(
              child: StreamBuilder<QuerySnapshot>(
            stream: _chatController.messages
                .where('users', arrayContains: _auth.currentUser.uid)
                .where('product.chatProduct', isEqualTo: false)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ),
                );
              }

              if (snapshot.data.docs.length == 0) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      'No Messages started yet!',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text('Shopping & have conversations with the Sellers')
                  ]),
                );
              }

              return new ListView(
                children: snapshot.data.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  return new ChatCardVendor(document, data);
                }).toList(),
              );
            },
          )),
          Container(
              child: StreamBuilder<QuerySnapshot>(
            stream: _chatController.messages
                .where('users', arrayContains: _auth.currentUser.uid)
                .where('product.chatProduct', isEqualTo: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ),
                );
              }

              if (snapshot.data.docs.length == 0) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      'No Messages started yet!',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text('Shopping & have conversations with the Sellers')
                  ]),
                );
              }

              return new ListView(
                children: snapshot.data.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  return new ChatCardVendor(document, data);
                }).toList(),
              );
            },
          )),
        ]),
      ),
    );
  }
}
