import 'package:flutter/material.dart';
import 'package:grocery_app/screens/vendor/addNewProductVendorScreen.dart';
import 'package:grocery_app/widgets/vendor/publishedProducts.dart';
import 'package:grocery_app/widgets/vendor/unpublishedProduct.dart';

class ProductVendorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(children: [
          Material(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Container(
                      child: Row(
                        children: [
                          Text('Products'),
                          SizedBox(
                            width: 10,
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.black54,
                            maxRadius: 8,
                            child: FittedBox(
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  '20',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  // ignore: deprecated_member_use
                  FlatButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AddNewProduct.id);
                      },
                      color: Theme.of(context).primaryColor,
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Add New',
                        style: TextStyle(color: Colors.white),
                      ))
                ],
              ),
            ),
          ),
          TabBar(
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.black54,
              tabs: [
                Tab(
                  text: 'PUBLISHED',
                ),
                Tab(
                  text: 'UNPUBLISHED',
                )
              ]),
          Expanded(
            child: Container(
              child: TabBarView(
                children: [
                  PublishedProduct(),
                  UnPublishedProduct(),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
