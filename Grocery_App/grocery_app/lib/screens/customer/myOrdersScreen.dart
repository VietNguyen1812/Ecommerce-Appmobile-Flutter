import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/controllers/orderController.dart';
import 'package:grocery_app/providers/orderProvider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyOrders extends StatefulWidget {
  static const String id = 'my-orders';

  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  OrderController _orderController = OrderController();

  User user = FirebaseAuth.instance.currentUser;

  int tag = 0;
  List<String> options = [
    'All Orders',
    'Ordered',
    'Accepted',
    'Pickup',
    'On the way',
    'Delivered',
    'Rejected',
  ];

  @override
  Widget build(BuildContext context) {
    var _orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text(
            'My Orders',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {},
                icon: Icon(
                  CupertinoIcons.search,
                  color: Colors.white,
                ))
          ],
        ),
        body: Column(children: [
          Container(
            height: 56,
            width: MediaQuery.of(context).size.width,
            child: ChipsChoice<int>.single(
              choiceStyle: C2ChoiceStyle(
                  borderRadius: BorderRadius.all(Radius.circular(3))),
              value: tag,
              onChanged: (val) {
                if (val == 0) {
                  setState(() {
                    _orderProvider.status == null;
                  });
                }
                setState(() {
                  tag = val;
                  _orderProvider.status = options[val];
                });
              },
              choiceItems: C2Choice.listFrom<int, String>(
                source: options,
                value: (i, v) => i,
                label: (i, v) => v,
              ),
            ),
          ),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: _orderController.orders
                  .where('userId', isEqualTo: user.uid)
                  .where('orderStatus',
                      isEqualTo: tag > 0 ? _orderProvider.status : null)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.data.size == 0) {
                  return Center(
                    child: Text(tag > 0
                        ? 'No ${options[tag]} orders.'
                        : 'No Orders. Continue shopping'),
                  );
                }

                return Expanded(
                  child: new ListView(
                    children:
                        snapshot.data.docs.map((DocumentSnapshot document) {
                      return new Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            ListTile(
                              horizontalTitleGap: 0,
                              leading: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 14,
                                child: _orderController.statusIcon(document),
                              ),
                              title: Text(
                                document.data()['orderStatus'],
                                style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        _orderController.statusColor(document),
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'On ${DateFormat.yMMMd().format(DateTime.parse(document.data()['timeStamp'].toDate().toString()))}',
                                style: TextStyle(fontSize: 13),
                              ),
                              trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Payment Type: ${document.data()['cod'] == true ? 'Cash on delivery' : 'Paid online'}',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Amount: \$${document.data()['total'].toStringAsFixed(0)}',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ]),
                            ),
                            // ignore: todo
                            //TODO: Delivery boy contact, live location, and delivery boy name
                            if (document.data()['deliveryBoy']['name'].length >
                                2)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Container(
                                  decoration: new BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(.2),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: ListTile(
                                      tileColor: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(.2),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Image.network(
                                          document.data()['deliveryBoy']
                                              ['image'],
                                          height: 24,
                                        ),
                                      ),
                                      title: Text(
                                        'Shipper: ${document.data()['deliveryBoy']['name']}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      subtitle: Text(
                                        _orderController
                                            .statusComment(document),
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ExpansionTile(
                              title: Text(
                                'Order details',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.black),
                              ),
                              subtitle: Text(
                                'View Order details',
                                style:
                                    TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Image.network(
                                            document.data()['products'][index]
                                                ['productImage']),
                                      ),
                                      title: Text(
                                        document.data()['products'][index]
                                            ['productName'],
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      subtitle: Text(
                                        '${document.data()['products'][index]['qty']} x \$${document.data()['products'][index]['price'].toStringAsFixed(0)} = \$${document.data()['products'][index]['total'].toStringAsFixed(0)}',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    );
                                  },
                                  itemCount: document.data()['products'].length,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 12, top: 8, bottom: 8),
                                  child: Card(
                                    elevation: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Seller: ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12),
                                              ),
                                              Text(
                                                document.data()['seller']
                                                    ['shopName'],
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          if (int.parse(document
                                                  .data()['discount']) !=
                                              0)
                                            Container(
                                              child: Column(children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Discount: ',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      '${document.data()['discount']}%',
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Voucher: ',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      '${document.data()['discountCode']}',
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12),
                                                    )
                                                  ],
                                                ),
                                              ]),
                                            ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Delivery Fee: ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12),
                                              ),
                                              Text(
                                                '\$${document.data()['deliveryFee'].toString()}',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Divider(
                              height: 3,
                              color: Colors.grey,
                            ),

                            _orderController.statusRejectedContainer(document, context),

                            Divider(
                              height: 3,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ]));
  }
}
