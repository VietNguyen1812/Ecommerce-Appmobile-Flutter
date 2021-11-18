import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/controllers/chatController.dart';
import 'package:grocery_app/controllers/customer/productController.dart';
import 'package:grocery_app/screens/chat/chatConversation.dart';
import 'package:intl/intl.dart';

class ChatCard extends StatefulWidget {
  final DocumentSnapshot document;
  final Map<String, dynamic> chatData;
  ChatCard(this.document, this.chatData);

  @override
  _ChatCardState createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  ChatController _chatController = ChatController();
  ProductController _productController = ProductController();
  DocumentSnapshot doc;
  String _lastChatDate;

  @override
  void initState() {
    getProductDetails();
    getChatTime();
    super.initState();
  }

  getProductDetails() {
    _productController
        .getProductById(widget.chatData['product']['productId'])
        .then((value) {
      setState(() {
        doc = value;
      });
    });
  }

  getChatTime() {
    var _date = DateFormat.yMMMd().format(
        DateTime.fromMicrosecondsSinceEpoch(widget.chatData['lastChatTime']));
    var _today = DateFormat.yMMMd().format(DateTime.fromMicrosecondsSinceEpoch(
        DateTime.now().microsecondsSinceEpoch));
    if (_date == _today) {
      setState(() {
        _lastChatDate = 'Today';
      });
    } else {
      setState(() {
        _lastChatDate = _date.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return doc == null
        ? Container()
        : Container(
            child: Stack(children: [
              SizedBox(
                height: 10,
              ),
              ListTile(
                  onTap: () {
                    _chatController.messages
                        .doc(widget.chatData['chatRoomId'])
                        .update({'read': true});
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            ChatConversationScreen(
                                widget.document, widget.chatData['chatRoomId']),
                      ),
                    );
                  },
                  leading: Container(
                      width: 60,
                      height: 60,
                      child: widget.chatData['product']['productImage'] != null
                          ? Image.network(
                              widget.chatData['product']['productImage'])
                          : Image.network(widget.chatData['vendor']['vendorImage'])),
                  title: Row(children: [
                    widget.chatData['product']['title'] != null
                        ? Text(
                            widget.chatData['product']['title'],
                            style: TextStyle(
                                fontWeight: widget.chatData['read'] == false
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                          )
                        : Text(widget.chatData['vendor']['shopName']),
                    widget.chatData['product']['shopName'] != null
                        ? Text(
                            ' (From ${widget.chatData['product']['shopName']})',
                            style: TextStyle(
                                fontWeight: widget.chatData['read'] == false
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                          )
                        : Container(),
                  ]),
                  subtitle: widget.chatData['lastChat'] != null
                      ? Text(
                          widget.chatData['lastChat'],
                          maxLines: 1,
                          style: TextStyle(fontSize: 12),
                        )
                      : Text(''),
                  trailing:
                      _chatController.popupMenu(widget.chatData, context)),
              Positioned(right: 20.0, top: 10.0, child: Text(_lastChatDate))
            ]),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey))),
          );
  }
}
