import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_delivery/controllers/firebaseController.dart';
import 'package:grocery_app_delivery/controllers/orderController.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderSummaryCard extends StatefulWidget {
  final DocumentSnapshot document;
  OrderSummaryCard(this.document);

  @override
  _OrderSummaryCardState createState() => _OrderSummaryCardState();
}

class _OrderSummaryCardState extends State<OrderSummaryCard> {
  FirebaseController _controller = FirebaseController();
  OrderController _orderController = OrderController();
  DocumentSnapshot _customer;

  @override
  void initState() {
    _controller
        .getCustomerDetails(widget.document.data()['userId'])
        .then((value) {
      if (value != null) {
        setState(() {
          _customer = value;
        });
      } else {
        print('no data');
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
              horizontalTitleGap: 0,
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 14,
                child: _orderController.statusIcon(widget.document),
              ),
              title: Text(
                widget.document.data()['orderStatus'],
                style: TextStyle(
                    fontSize: 13,
                    color: _orderController.statusColor(widget.document),
                    fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'On ${DateFormat.yMMMd().format(DateTime.parse(widget.document.data()['timeStamp'].toDate().toString()))}',
                style: TextStyle(fontSize: 13),
              ),
              trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Payment Type: ${widget.document.data()['cod'] == true ? 'Cash on delivery' : 'Paid online'}',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Amount: \$${widget.document.data()['total'].toStringAsFixed(0)}',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ]),
            ),

            _customer != null
                ? ListTile(
                    contentPadding: EdgeInsets.only(left: 10, right: 10),
                    title: Row(children: [
                      Text(
                        'Customer: ',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_customer.data()['firstName']} ${_customer.data()['lastName']}',
                        style: TextStyle(fontSize: 13),
                      ),
                    ]),
                    subtitle: Text(
                      _customer.data()['address'],
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      InkWell(
                        onTap: () {
                          _orderController.launchMap(
                            _customer.data()['latitude'],
                            _customer.data()['longitude'],
                            _customer.data()['firstName'],
                          );
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(4)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, top: 2, bottom: 2),
                              child: Icon(
                                Icons.map,
                                color: Colors.white,
                              ),
                            )),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () {
                          launch('tel: ${_customer.data()['number']}');
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(4)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, top: 2, bottom: 2),
                              child: Icon(
                                Icons.phone_in_talk,
                                color: Colors.white,
                              ),
                            )),
                      ),
                    ]),
                  )
                : Container(),

            // ignore: todo
            //TODO: Customer name, contact number
            ExpansionTile(
              title: Text(
                'Order details',
                style: TextStyle(fontSize: 11, color: Colors.black),
              ),
              subtitle: Text(
                'View Order details',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Image.network(widget.document.data()['products']
                            [index]['productImage']),
                      ),
                      title: Text(
                        widget.document.data()['products'][index]
                            ['productName'],
                        style: TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        '${widget.document.data()['products'][index]['qty']} x \$${widget.document.data()['products'][index]['price'].toStringAsFixed(0)} = \$${widget.document.data()['products'][index]['total'].toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    );
                  },
                  itemCount: widget.document.data()['products'].length,
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
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              Text(
                                widget.document.data()['seller']['shopName'],
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          if (int.parse(widget.document.data()['discount']) !=
                              0)
                            Container(
                              child: Column(children: [
                                Row(
                                  children: [
                                    Text(
                                      'Discount: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                    Text(
                                      '${widget.document.data()['discount']}%',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12),
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
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                    Text(
                                      '${widget.document.data()['discountCode']}',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12),
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
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              Text(
                                '\$${widget.document.data()['deliveryFee'].toString()}',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
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
            _orderController.statusContainer(widget.document, context),
            Divider(
              height: 3,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
