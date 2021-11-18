import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/providers/customer/cartProvider.dart';
import 'package:grocery_app/providers/orderProvider.dart';
import 'package:grocery_app/screens/customer/payment/createNewCardScreen.dart';
import 'package:grocery_app/screens/customer/payment/paypal/paypalPayment.dart';
import 'package:grocery_app/screens/customer/payment/stripe/existingCards.dart';
import 'package:grocery_app/services/payment/stripePaymentService.dart';
import 'package:provider/provider.dart';

class PaymentHome extends StatefulWidget {
  static const String id = 'stripe-home';
  PaymentHome({Key key}) : super(key: key);

  @override
  PaymentHomeState createState() => PaymentHomeState();
}

class PaymentHomeState extends State<PaymentHome> {
  onItemPress(BuildContext context, int index, amount, orderProvider) async {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, CreateNewCreditCard.id);
        break;
      case 1:
        payViaNewCard(context, amount, orderProvider);
        break;
      case 2:
        Navigator.pushNamed(context, ExistingCardsPage.id);
        break;
    }
  }

  payViaNewCard(
      BuildContext context, amount, OrderProvider orderProvider) async {
    await EasyLoading.show(status: 'Please wait...');
    var response = await StripeService.payWithNewCard(
        amount: '${amount}00', currency: 'USD');
    if (response.success == true) {
      orderProvider.success = true;
    }
    await EasyLoading.dismiss();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(
          content: Text(response.message),
          duration: new Duration(
              milliseconds: response.success == true ? 1200 : 3000),
        ))
        .closed
        .then((_) {
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    super.initState();
    StripeService.init();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    var _cartProvider = Provider.of<CartProvider>(context);
    _cartProvider.getCartDetails();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          Divider(
            color: Colors.grey,
          ),
          // ignore: deprecated_member_use
          Center(
            child: FlatButton(
              onPressed: () {
                // make PayPal payment
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => PaypalPayment(
                      onFinish: (number) async {
                        // payment done
                        print('order id: ' + number);
                      },
                      amount: orderProvider.amount,
                      firstName: orderProvider.firstName,
                      lastName: orderProvider.lastName,
                      address: orderProvider.address,
                      productName: _cartProvider.productName,
                      cartList: _cartProvider.cartList,
                    ),
                  ),
                );
              },

              child: Text(
                'Pay with Paypal',
                textAlign: TextAlign.center,
              ),

              color: Colors.blue,
              textColor: Colors.white,

              ///....
            ),
          ),
          Divider(
            color: Colors.grey,
          ),
          // Material(
          //   elevation: 4,
          //   child: SizedBox(
          //       height: 56,
          //       width: MediaQuery.of(context).size.width,
          //       child: Image.network(
          //         'https://s6.upanh.pro/2019/09/23/paypal-logo.png',
          //         fit: BoxFit.fitHeight,
          //       )),
          // ),
          // Divider(
          //   color: Colors.grey,
          // ),
          // Material(
          //   elevation: 4,
          //   child: SizedBox(
          //       height: 56,
          //       width: MediaQuery.of(context).size.width,
          //       child: Image.network(
          //         'https://logos-world.net/wp-content/uploads/2021/03/Stripe-Logo.png',
          //         fit: BoxFit.fitHeight,
          //       )),
          // ),
          Container(
            padding: EdgeInsets.all(20),
            child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  Icon icon;
                  Text text;

                  switch (index) {
                    case 0:
                      icon = Icon(Icons.add_circle, color: theme.primaryColor);
                      text = Text('Add Cards');
                      break;
                    case 1:
                      icon = Icon(Icons.payment_outlined,
                          color: theme.primaryColor);
                      text = Text('Pay via new card');
                      break;
                    case 2:
                      icon = Icon(Icons.credit_card, color: theme.primaryColor);
                      text = Text('Pay via existing card');
                      break;
                  }

                  return InkWell(
                    onTap: () {
                      onItemPress(
                          context, index, orderProvider.amount, orderProvider);
                    },
                    child: ListTile(
                      title: text,
                      leading: icon,
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(
                      color: theme.primaryColor,
                    ),
                itemCount: 3),
          ),
        ]),
      ),
    );
  }
}
