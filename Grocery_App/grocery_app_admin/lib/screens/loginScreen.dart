import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_admin/controller/firebaseController.dart';
import 'package:grocery_app_admin/screens/homeScreen.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login-screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  FocusNode _focusNodeUserName, _focusNodePassword;
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  FirebaseController _controller = FirebaseController();
  var _usernameTextController = TextEditingController();
  var _passwordTextController = TextEditingController();

  _login({username, password}) async {
    _controller.getAdminCredentials(username).then((value) async {
      if (value.exists) {
        if (value.data()['username'] == username) {
          if (value.data()['password'] == password) {
            try {
              UserCredential userCredential =
                  await FirebaseAuth.instance.signInAnonymously();
              if (userCredential != null) {
                Navigator.pushReplacementNamed(context, HomeScreen.id);
              }
            } catch (e) {
              _controller.showMyDialog(
                  context: context, title: 'Login', message: '${e.toString()}');
            }
            return;
          }
          _controller.showMyDialog(
              context: context,
              title: 'Incorrect Password',
              message: 'Password you have entered is incorrect, try again');
          return;
        }
        _controller.showMyDialog(
            context: context,
            title: 'Incorrect Username',
            message: 'Username you have entered is not exist, try again');
      }
      _controller.showMyDialog(
          context: context,
          title: 'Incorrect Username',
          message: 'Username you have entered is not exist, try again');
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNodeUserName = FocusNode();
    _focusNodePassword = FocusNode();
  }

  @override
  void dispose() {
    _focusNodeUserName.dispose();
    _focusNodePassword.dispose();
    super.dispose();
  }

  void _requestFocusUserName() {
    if (mounted) {
      setState(() {
        FocusScope.of(context).requestFocus(_focusNodeUserName);
      });
    }
  }

  void _requestFocusPassword() {
    if (mounted) {
      setState(() {
        FocusScope.of(context).requestFocus(_focusNodePassword);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Center(
            child: Text('Connection Failed'),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF84c225), Colors.white],
                    stops: [1.0, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment(0.0, 0.0))),
            child: Center(
              child: Container(
                width: 300,
                height: 400,
                child: Card(
                  elevation: 6,
                  shape: Border.all(color: Colors.green, width: 2),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            child: Column(
                              children: [
                                Image.asset('images/logo.png'),
                                Text(
                                  'GROCERY APP ADMIN',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  controller: _usernameTextController,
                                  focusNode: _focusNodeUserName,
                                  onTap: _requestFocusUserName,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Enter Username';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      labelText: 'UserName',
                                      labelStyle: TextStyle(
                                          color: _focusNodeUserName.hasFocus
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey),
                                      prefixIcon: _focusNodeUserName.hasFocus
                                          ? Icon(
                                              Icons.person,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            )
                                          : Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                            ),
                                      contentPadding:
                                          EdgeInsets.only(left: 20, right: 20),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 2,
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 2))),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  controller: _passwordTextController,
                                  focusNode: _focusNodePassword,
                                  onTap: _requestFocusPassword,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Enter Password';
                                    }
                                    if (value.length < 6) {
                                      return 'Minimun 6 Characters';
                                    }
                                    return null;
                                  },
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      labelText: 'Password',
                                      labelStyle: TextStyle(
                                          color: _focusNodePassword.hasFocus
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey),
                                      prefixIcon: _focusNodePassword.hasFocus
                                          ? Icon(
                                              Icons.vpn_key_sharp,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            )
                                          : Icon(
                                              Icons.vpn_key_sharp,
                                              color: Colors.grey,
                                            ),
                                      hintText: 'Minimun 6 Characters',
                                      contentPadding:
                                          EdgeInsets.only(left: 20, right: 20),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 2,
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 2))),
                                ),
                              ],
                            ),
                          ),
                          Row(children: [
                            Expanded(
                              // ignore: deprecated_member_use
                              child: FlatButton(
                                  onPressed: () async {
                                    if (_formKey.currentState.validate()) {
                                      _login(
                                          username:
                                              _usernameTextController.text,
                                          password:
                                              _passwordTextController.text);
                                    }
                                  },
                                  color: Theme.of(context).primaryColor,
                                  child: Text(
                                    'Login',
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ),
                          ])
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    ));
  }
}
