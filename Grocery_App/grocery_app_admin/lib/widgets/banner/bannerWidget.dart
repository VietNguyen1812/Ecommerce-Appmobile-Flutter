import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_admin/controller/firebaseController.dart';

class BannerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseController _controller = FirebaseController();

    return StreamBuilder<QuerySnapshot>(
      stream: _controller.banners.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 300,
          child: new ListView(
            scrollDirection: Axis.vertical,
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(children: [
                    SizedBox(
                      height: 300,
                      child: new Card(
                        elevation: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            document.data()['image'],
                            width: 500,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          onPressed: () {
                            _controller.confirmDeleteDialog(
                              context: context,
                              message: 'Are you sure you want to delete?',
                              title: 'Delete Banner',
                              id: document.id
                            );
                          },
                          icon: Icon(Icons.delete, color: Colors.red,),
                        ),
                      )
                    )
                  ]),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
