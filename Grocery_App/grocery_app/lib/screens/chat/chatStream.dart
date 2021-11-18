import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_2.dart';
import 'package:grocery_app/controllers/chatController.dart';
import 'package:intl/intl.dart';

class ChatStream extends StatefulWidget {
  final String chatRoomId;
  ChatStream(this.chatRoomId);

  @override
  _ChatStreamState createState() => _ChatStreamState();
}

class _ChatStreamState extends State<ChatStream> {
  ChatController _chatController = ChatController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  Stream chatMessageStream;
  DocumentSnapshot chatDoc;

  @override
  void initState() {
    _chatController.getChat(widget.chatRoomId).then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });
    _chatController.messages.doc(widget.chatRoomId).get().then((value) {
      setState(() {
        chatDoc = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: StreamBuilder<QuerySnapshot>(
        stream: chatMessageStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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

          return snapshot.hasData
              ? Column(children: [
                  if (chatDoc != null)
                    ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            width: 60,
                            height: 60,
                            child: chatDoc['product']['productImage'] != null
                                ? Image.network(
                                    chatDoc['product']['productImage'])
                                : Image.network(
                                    chatDoc['vendor']['vendorImage'])),
                      ),
                      title: chatDoc['product']['title'] != null
                          ? Text(chatDoc['product']['title'])
                          : Text(chatDoc['vendor']['shopName']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          chatDoc['product']['price'] != null
                              ? Text(
                                  '\$ ${chatDoc['product']['price'].toString()}')
                              : Text(chatDoc['vendor']['email']),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Container(
                      color: Colors.grey.shade300,
                      child: ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            String sentBy = snapshot.data.docs[index]['sentBy'];
                            String me = _auth.currentUser.uid;
                            //add chat time
                            String lastChatDate;
                            var _date = DateFormat.yMMMd().format(
                                DateTime.fromMicrosecondsSinceEpoch(
                                    snapshot.data.docs[index]['time']));
                            var _today = DateFormat.yMMMd().format(
                                DateTime.fromMicrosecondsSinceEpoch(
                                    DateTime.now().microsecondsSinceEpoch));
                            if (_date == _today) {
                              lastChatDate = DateFormat('hh:mm').format(
                                  DateTime.fromMicrosecondsSinceEpoch(
                                      snapshot.data.docs[index]['time']));
                            } else {
                              lastChatDate = _date.toString();
                            }
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(children: [
                                ChatBubble(
                                  alignment: sentBy == me
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  backGroundColor: sentBy == me
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              .8,
                                    ),
                                    child: Text(
                                      snapshot.data.docs[index]['message'],
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  clipper: ChatBubbleClipper2(
                                      type: sentBy == me
                                          ? BubbleType.sendBubble
                                          : BubbleType.receiverBubble),
                                ),
                                Align(
                                    alignment: sentBy == me
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Text(
                                      lastChatDate,
                                      style: TextStyle(fontSize: 12),
                                    ))
                              ]),
                            );
                          }),
                    ),
                  ),
                ])
              : Container();
        },
      ),
    );
  }
}
