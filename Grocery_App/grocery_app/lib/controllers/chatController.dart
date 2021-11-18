import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/models/popupMenuModel.dart';

class ChatController {
  CollectionReference messages =
      FirebaseFirestore.instance.collection('messages');

  createChatRoom({chatData}) {
    messages.doc(chatData['chatRoomId']).set(chatData).catchError((e) {
      print(e.toString());
    });
  }

  createChat(String chatRoomId, message) {
    messages.doc(chatRoomId).collection('chats').add(message).catchError((e) {
      print(e.toString());
    });
    messages.doc(chatRoomId).update({
      'lastChat': message['message'],
      'lastChatTime': message['time'],
      'read': false
    });
  }

  getChat(chatRoomId) async {
    return messages
        .doc(chatRoomId)
        .collection('chats')
        .orderBy('time')
        .snapshots();
  }

  Future<DocumentSnapshot> getMessage(String id) async {
    var result = await messages.doc(id).get();
    return result;
  }

  deleteChat(chatRoomId) async {
    return messages.doc(chatRoomId).delete();
  }

  deleteConversation(chatRoomId, context) async {
    return messages.doc(chatRoomId).delete().then((value) {
      Navigator.pop(context);
    });
  }

  popupMenu(chatData, context) {
    CustomPopupMenuController _controller = CustomPopupMenuController();
    List<PopupMenuModel> menuItems = [
      PopupMenuModel('Delete Message', Icons.delete),
      PopupMenuModel('Mark as Done', Icons.done),
    ];
    return CustomPopupMenu(
      child: Container(
        child: Icon(Icons.more_vert_sharp, color: Colors.black),
        padding: EdgeInsets.all(20),
      ),
      menuBuilder: () => ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          color: Theme.of(context).primaryColor,
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: menuItems
                  .map(
                    (item) => GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        if (item.title == 'Delete Message') {
                          deleteChat(chatData['chatRoomId']);
                          _controller.hideMenu();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Message deleted.'),
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: 40,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              item.icon,
                              size: 15,
                              color: Colors.white,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 10),
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
      pressType: PressType.singleClick,
      verticalMargin: -10,
      controller: _controller,
    );
  }

  popupMenuConversation(chatData, context) {
    CustomPopupMenuController _controller = CustomPopupMenuController();
    List<PopupMenuModel> menuItems = [
      PopupMenuModel('Delete Message', Icons.delete),
      PopupMenuModel('Mark as Read', Icons.done),
    ];
    return CustomPopupMenu(
      child: Container(
        child: Icon(Icons.more_vert_sharp, color: Colors.black),
        padding: EdgeInsets.all(20),
      ),
      menuBuilder: () => ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          color: Theme.of(context).primaryColor,
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: menuItems
                  .map(
                    (item) => GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        if (item.title == 'Delete Message') {
                          deleteConversation(chatData['chatRoomId'], context);
                          _controller.hideMenu();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Message deleted.'),
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: 40,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              item.icon,
                              size: 15,
                              color: Colors.white,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 10),
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
      pressType: PressType.singleClick,
      verticalMargin: -10,
      controller: _controller,
    );
  }
}
