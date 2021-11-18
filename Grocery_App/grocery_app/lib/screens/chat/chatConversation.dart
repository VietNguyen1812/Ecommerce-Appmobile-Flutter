import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/controllers/chatController.dart';
import 'package:grocery_app/screens/chat/chatStream.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatConversationScreen extends StatefulWidget {
  static const String id = 'chat-conversation-screen';
  final DocumentSnapshot document;
  final String chatRoomId;
  ChatConversationScreen(this.document, this.chatRoomId);

  @override
  _ChatConversationScreenState createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  ChatController _chatController = ChatController();
  var chatMessageController = TextEditingController();
  bool _send = false;
  String mobile;

  sendMessage() {
    if (chatMessageController.text.isNotEmpty) {
      FocusScope.of(context).unfocus();
      Map<String, dynamic> message = {
        'message': chatMessageController.text,
        'sentBy': _auth.currentUser.uid,
        'time': DateTime.now().microsecondsSinceEpoch
      };
      _chatController.createChat(widget.chatRoomId, message);
      chatMessageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    _chatController.getMessage(widget.chatRoomId).then((value) {
      if (mounted) {
        setState(() {
          mobile = value.data()['vendor']['phone'];
        });
      }
    });
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
              onPressed: () {
                launch('tel: 0${this.mobile}');
              },
              icon: Icon(Icons.call)),
          _chatController.popupMenuConversation(widget.document, context)
        ],
        shape: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      body: Container(
        child: Stack(
          children: [
            ChatStream(widget.chatRoomId),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border(top: BorderSide(color: Colors.grey.shade800))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: TextField(
                        controller: chatMessageController,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                        decoration: InputDecoration(
                            hintText: 'Type Message',
                            hintStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
                            border: InputBorder.none),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              _send = true;
                            });
                          } else {
                            setState(() {
                              _send = false;
                            });
                          }
                        },
                        onSubmitted: (value) {
                          //can send message by pressing enter
                          if (value.length > 0) {
                            sendMessage();
                          }
                        },
                      )),
                      Visibility(
                        visible: _send,
                        child: IconButton(
                            onPressed: () {
                              sendMessage();
                            },
                            icon: Icon(
                              Icons.send,
                              color: Theme.of(context).primaryColor,
                            )),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
