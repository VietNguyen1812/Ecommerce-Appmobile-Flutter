import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grocery_app/providers/authProvider.dart';
import 'package:grocery_app/widgets/myAppBar.dart';
import 'package:grocery_app/widgets/nearByStore.dart';
import 'package:grocery_app/widgets/topPickStore.dart';
import 'package:grocery_app/widgets/imageSlider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    timeDilation = 5.0;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [MyAppBar()];
        },
        body: ListView(
          padding: EdgeInsets.only(top: 0.0),
          children: [
            ImageSlider(),
            Container(color: Colors.white, child: TopPickStore()),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: NearByStores(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  'images/deliverfood.png',
                  width: 130,
                  height: 150,
                ),
                // Image.asset(
                //   'images/orderfood.png',
                //   width: 130,
                //   height: 150,
                // ),
              ],
            ),
            Text(
                'App supports stores to make trading easier, fast and economical delivery, works 24/7',
                textAlign: TextAlign.center),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  'images/orderfood.png',
                  width: 130,
                  height: 150,
                ),
              ],
            ),
            Text(
                'Nationwide delivery , Fast and very convenient , affordable price , quick connection between users and stores ',
                textAlign: TextAlign.center),
            Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                  Text('Contact ', textAlign: TextAlign.center),
                  Text('Email: admin@abc.com', textAlign: TextAlign.center),
                  Text('Phone : 0123456789', textAlign: TextAlign.center),
                  Text('Facebook : Viet Nguyen', textAlign: TextAlign.center),
                ]))
          ],
        ),
      ),
    );
  }
}
