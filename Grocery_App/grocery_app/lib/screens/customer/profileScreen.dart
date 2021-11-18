import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/providers/authProvider.dart';
import 'package:grocery_app/providers/locationProvider.dart';
import 'package:grocery_app/screens/customer/myOrdersScreen.dart';
import 'package:grocery_app/screens/customer/payment/creditCardList.dart';
import 'package:grocery_app/screens/customer/profileUpdateScreen.dart';
import 'package:grocery_app/screens/mapScreen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

import '../welcomeScreen.dart';

class ProfileScreen extends StatelessWidget {
  static const String id = 'profile-screen';
  @override
  Widget build(BuildContext context) {
    var userDetails = Provider.of<AuthProvider>(context);
    var locationData = Provider.of<LocationProvider>(context);
    userDetails.getUserDetails();

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Grocery Store',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: userDetails.snapshot == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'MY ACCOUNT',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Stack(children: [
                  Container(
                    color: Colors.redAccent,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: [
                        Row(
                          children: [
                            userDetails.snapshot.data()['avatarImage'] == null
                                ? CircleAvatar(
                                    radius: 40,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    child: Text(
                                      userDetails.snapshot
                                                  .data()['firstName'] !=
                                              null
                                          ? userDetails.snapshot
                                              .data()['firstName'][0]
                                          : '',
                                      style: TextStyle(
                                          fontSize: 50, color: Colors.white),
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(userDetails
                                        .snapshot
                                        .data()['avatarImage'])),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: 70,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    userDetails.snapshot.data()['firstName'] !=
                                            null
                                        ? '${userDetails.snapshot.data()['firstName']} ${userDetails.snapshot.data()['lastName']}'
                                        : 'Update Your Name',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    userDetails.snapshot.data()['email'] != null
                                        ? '${userDetails.snapshot.data()['email']}'
                                        : 'Update Your Email',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                  Text(userDetails.snapshot.data()['number'],
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14))
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        if (userDetails.snapshot != null)
                          Container(
                            decoration: new BoxDecoration(color: Colors.white),
                            child: ListTile(
                              tileColor: Colors.white,
                              leading: Icon(
                                Icons.location_on,
                                color: Colors.redAccent,
                              ),
                              title: Text(
                                userDetails.snapshot.data()['location'],
                              ),
                              subtitle: Text(
                                userDetails.snapshot.data()['address'],
                                maxLines: 1,
                              ),
                              trailing: SizedBox(
                                width: 80,
                                // ignore: deprecated_member_use
                                child: OutlineButton(
                                  borderSide:
                                      BorderSide(color: Colors.redAccent),
                                  child: Text(
                                    'Change',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                  onPressed: () {
                                    EasyLoading.show(status: 'Please wait...');
                                    locationData
                                        .getCurrentPosition()
                                        .then((value) {
                                      if (value != null) {
                                        EasyLoading.dismiss();
                                        pushNewScreenWithRouteSettings(
                                          context,
                                          settings:
                                              RouteSettings(name: MapScreen.id),
                                          screen: MapScreen(),
                                          withNavBar: false,
                                          pageTransitionAnimation:
                                              PageTransitionAnimation.cupertino,
                                        );
                                      } else {
                                        EasyLoading.dismiss();
                                        print('Permission not allowed');
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                      ]),
                    ),
                  ),
                  Positioned(
                      right: 10.0,
                      child: IconButton(
                          onPressed: () {
                            pushNewScreenWithRouteSettings(
                              context,
                              settings: RouteSettings(name: UpdateProfile.id),
                              screen: UpdateProfile(),
                              withNavBar: false,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          icon: Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                          )))
                ]),
                ListTile(
                  onTap: () {
                    pushNewScreenWithRouteSettings(
                      context,
                      settings: RouteSettings(name: MyOrders.id),
                      screen: MyOrders(),
                      withNavBar: true,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                  leading: Icon(Icons.history),
                  title: Text('My Orders'),
                  horizontalTitleGap: 2,
                ),
                Divider(),
                ListTile(
                  onTap: () {
                    pushNewScreenWithRouteSettings(
                      context,
                      settings: RouteSettings(name: CreditCardList.id),
                      screen: CreditCardList(),
                      withNavBar: true,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                  leading: Icon(Icons.credit_card),
                  title: Text('Manage Credit Cards'),
                  horizontalTitleGap: 2,
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.notifications_none),
                  title: Text('Notifications'),
                  horizontalTitleGap: 2,
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.power_settings_new),
                  title: Text('Logout'),
                  horizontalTitleGap: 2,
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    //Navigator.pushReplacementNamed(context, WelcomeScreen.id);
                    pushNewScreenWithRouteSettings(
                      context,
                      settings: RouteSettings(name: WelcomeScreen.id),
                      screen: WelcomeScreen(),
                      withNavBar: false,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                ),
              ]),
            ),
    );
  }
}
