import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/providers/customer/cartProvider.dart';
import 'package:grocery_app/providers/orderProvider.dart';
import 'package:grocery_app/services/payment/paypalServices.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaypalPayment extends StatefulWidget {
  final Function onFinish;
  final String amount;
  final String firstName;
  final String lastName;
  final String address;
  final String productName;
  final List cartList;

  PaypalPayment(
      {this.onFinish,
      this.amount,
      this.firstName,
      this.lastName,
      this.address,
      this.productName,
      this.cartList});

  @override
  State<StatefulWidget> createState() {
    return PaypalPaymentState();
  }
}

class PaypalPaymentState extends State<PaypalPayment> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String checkoutUrl;
  String executeUrl;
  String accessToken;

  PaypalServices services = PaypalServices();

  // you can change default currency according to your need
  Map<dynamic, dynamic> defaultCurrency = {
    "symbol": "USD ",
    "decimalDigits": 2,
    "symbolBeforeTheNumber": true,
    "currency": "USD"
  };

  bool isEnableShipping = false;
  bool isEnableAddress = false;

  String returnURL = 'return.google.com';
  String cancelURL = 'cancel.google.com';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      try {
        accessToken = await services.getAccessToken();

        final transactions = getOrderParams();

        final res =
            await services.createPaypalPayment(transactions, accessToken);
        print(res);
        if (res != null) {
          setState(() {
            checkoutUrl = res["approvalUrl"];
            executeUrl = res["executeUrl"];
          });
        }
      } catch (e) {
        print('exception: ' + e.toString());
        final snackBar = SnackBar(
          content: Text(e.toString()),
          duration: Duration(seconds: 10),
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );
        // ignore: deprecated_member_use
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    });
  }

  Map<String, dynamic> getOrderParams() {
    var _cartProvider = Provider.of<CartProvider>(context, listen: false);
    _cartProvider.getCartDetails();
    
    // item name, price and quantity
    // String itemName = '';
    // String itemPrice = widget.amount;
    // int quantity = 1;
    // List _newList = [];
    // List items = [];
    
    // _cartProvider.cartList.forEach((doc) {
    //   _newList.add({
    //     "name": doc['productName'],
    //     "quantity": quantity,
    //     "price": itemPrice,
    //     "currency": defaultCurrency["currency"]
    //   });
    // });

    // items = _newList;

    // List items = [
    //   {
    //     "name": itemName,
    //     "quantity": quantity,
    //     "price": itemPrice,
    //     "currency": defaultCurrency["currency"]
    //   }
    // ];

    // checkout invoice details
    String totalAmount = widget.amount;
    // String subTotalAmount = widget.amount;
    // String shippingCost = '0';
    // int shippingDiscountCost = 0;
    String userFirstName = widget.firstName;
    String userLastName = widget.lastName;
    String address = widget.address;
    String addressPhoneNumber = '+919990119091';

    Map<String, dynamic> temp = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {
            "total": totalAmount,
            "currency": defaultCurrency["currency"],
            // "details": {
            //   "subtotal": subTotalAmount,
            //   "shipping": shippingCost,
            //   "shipping_discount": ((-1.0) * shippingDiscountCost).toString()
            // }
          },
          "description": "The payment transaction description.",
          "payment_options": {
            "allowed_payment_method": "INSTANT_FUNDING_SOURCE"
          },
          "item_list": {
            //"items": items,
            if (isEnableShipping && isEnableAddress)
              "shipping_address": {
                "recipient_name": userFirstName + " " + userLastName,
                "address": address,
                "phone": addressPhoneNumber,
              },
          }
        }
      ],
      "note_to_payer": "Contact us for any questions on your order.",
      "redirect_urls": {"return_url": returnURL, "cancel_url": cancelURL}
    };
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    
    if (checkoutUrl != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          leading: GestureDetector(
            child: Icon(Icons.arrow_back_ios),
            onTap: () => Navigator.pop(context),
          ),
        ),
        body: WebView(
          initialUrl: checkoutUrl,
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (NavigationRequest request) {
            if (request.url.contains(returnURL)) {
              final uri = Uri.parse(request.url);
              final payerID = uri.queryParameters['PayerID'];
              if (payerID != null) {
                services
                    .executePayment(executeUrl, payerID, accessToken)
                    .then((id) {
                  orderProvider.paymentStatus(true);
                  widget.onFinish(id);
                  Navigator.pop(context);
                });
                EasyLoading.showSuccess('Transaction successfully');
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
              Navigator.pop(context);
            }
            if (request.url.contains(cancelURL)) {
              Navigator.pop(context);
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
          backgroundColor: Colors.black12,
          elevation: 0.0,
        ),
        body: Center(child: Container(child: CircularProgressIndicator())),
      );
    }
  }
}
