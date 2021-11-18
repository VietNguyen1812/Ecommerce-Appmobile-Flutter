import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/controllers/orderController.dart';
import 'package:grocery_app/providers/orderProvider.dart';
import 'package:grocery_app/widgets/orderSummaryCard.dart';
import 'package:provider/provider.dart';

class OrderVendorScreen extends StatefulWidget {
  @override
  _OrderVendorScreenState createState() => _OrderVendorScreenState();
}

class _OrderVendorScreenState extends State<OrderVendorScreen> {
  OrderController _orderController = OrderController();

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
    User user = FirebaseAuth.instance.currentUser;

    return Scaffold(
        backgroundColor: Colors.grey[200],
        body: Column(children: [
          Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Text(
                'Customer Orders',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
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
                  .where('seller.sellerId', isEqualTo: user.uid)
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
                    padding: EdgeInsets.zero,
                    children:
                        snapshot.data.docs.map((DocumentSnapshot document) {
                      return new OrderSummaryCard(document);
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ]));
  }
}
