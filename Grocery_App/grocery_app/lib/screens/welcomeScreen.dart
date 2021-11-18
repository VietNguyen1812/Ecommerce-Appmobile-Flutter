import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/providers/authProvider.dart';
import 'package:grocery_app/providers/locationProvider.dart';
import 'package:grocery_app/screens/vendor/homeVendorScreen.dart';
import 'package:grocery_app/screens/vendor/loginVendorScreen.dart';
import 'package:provider/provider.dart';
import 'mapScreen.dart';
import 'onBoardScreen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome-screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    bool _validPhoneNumber = false;
    var _phoneNumberController = TextEditingController();

    void showBottomSheet(context) {
      showModalBottomSheet(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, StateSetter mystate) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: auth.error == 'Invalid OTP' ? true : false,
                      child: Container(
                        child: Column(
                          children: [
                            Text(
                              auth.error,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      'LOGIN',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Enter your phone number to proceed',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        prefixText: '+84',
                        labelText: '9 digit mobile number',
                        labelStyle: TextStyle(color: Colors.deepOrangeAccent),
                      ),
                      keyboardType: TextInputType.phone,
                      maxLength: 9,
                      controller: _phoneNumberController,
                      onChanged: (value) {
                        if (value.length == 9) {
                          mystate(() {
                            _validPhoneNumber = true;
                          });
                        } else {
                          mystate(() {
                            _validPhoneNumber = false;
                          });
                        }
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(children: [
                      Expanded(
                        child: AbsorbPointer(
                          absorbing: _validPhoneNumber ? false : true,
                          // ignore: deprecated_member_use
                          child: FlatButton(
                            onPressed: () {
                              mystate(() {
                                auth.loading = true;
                              });
                              String number =
                                  '+84${_phoneNumberController.text}';
                              //we dont have location data here, so we will send null value
                              auth
                                  .verifyPhone(context: context, number: number)
                                  .then((value) {
                                _phoneNumberController.clear();
                              });
                            },
                            color: _validPhoneNumber
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                            child: auth.loading
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : Text(
                                    _validPhoneNumber
                                        ? 'CONTINUE'
                                        : 'ENTER PHONE NUMBER',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ),
                    ]),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          // ignore: deprecated_member_use
                          child: FlatButton(
                            onPressed: () {
                              FirebaseAuth.instance
                                  .authStateChanges()
                                  .listen((User user) {
                                if (user == null) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                LoginVendorScreen()));
                                  });
                                } else {
                                  Navigator.pushReplacementNamed(
                                      context, HomeVendorScreen.id);
                                }
                              });
                            },
                            color: Theme.of(context).primaryColor,
                            child: Text(
                              'LOGIN AS A VENDOR',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ).whenComplete(() {
        setState(() {
          auth.loading = false;
          _phoneNumberController.clear();
        });
      });
    }

    final locationData = Provider.of<LocationProvider>(context, listen: false);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: OnBoardScreen(),
                ),
                Text(
                  'Ready to order from your nearest shop?',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  height: 20,
                ),
                // ignore: deprecated_member_use
                FlatButton(
                  color: Theme.of(context).primaryColor,
                  child: locationData.loading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          'SET DELIVERY LOCATION',
                          style: TextStyle(color: Colors.white),
                        ),
                  onPressed: () async {
                    setState(() {
                      locationData.loading = true;
                    });

                    await locationData.getCurrentPosition();
                    if (locationData.permissionAllowed == true) {
                      Navigator.pushReplacementNamed(context, MapScreen.id);
                      setState(() {
                        locationData.loading = false;
                      });
                    } else {
                      print('Permission not allowed');
                      setState(() {
                        locationData.loading = false;
                      });
                    }
                  },
                ),
                // ignore: deprecated_member_use
                FlatButton(
                  child: RichText(
                    text: TextSpan(
                        text: 'Already a Customer ?',
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                              text: ' Login',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orangeAccent))
                        ]),
                  ),
                  onPressed: () {
                    setState(() {
                      auth.screen = 'Login';
                    });
                    showBottomSheet(context);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
