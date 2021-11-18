import 'package:flutter/material.dart';
import 'package:grocery_app_admin/controller/firebaseController.dart';

class CreateNewBoyWidget extends StatefulWidget {
  @override
  _CreateNewBoyWidgetState createState() => _CreateNewBoyWidgetState();
}

class _CreateNewBoyWidgetState extends State<CreateNewBoyWidget> {
  FirebaseController _controller = FirebaseController();
  bool _visible = false;

  var emailText = TextEditingController();
  var passwordText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.grey,
      height: 80,
      child: Row(
        children: [
          Visibility(
            visible: _visible ? false : true,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 30),
                // ignore: deprecated_member_use
                child: FlatButton(
                  onPressed: () {
                    setState(() {
                      _visible = true;
                    });
                  },
                  child: Text(
                    'Creat new Delivery Person',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          Visibility(
            visible: _visible,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Container(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 200,
                        height: 30,
                        child: TextField(
                          controller: emailText,
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1)),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Email ID',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.only(left: 20)),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 200,
                        height: 30,
                        child: TextField(
                          controller: passwordText,
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1)),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Password',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.only(left: 20)),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      // ignore: deprecated_member_use
                      FlatButton(
                        onPressed: () {
                          if (emailText.text.isEmpty) {
                            return _controller.showMyDialog(
                                context: context,
                                title: 'Email ID',
                                message: 'Email ID not entered');
                          }
                          if (passwordText.text.isEmpty) {
                            return _controller.showMyDialog(
                                context: context,
                                title: 'Password',
                                message: 'Password not entered');
                          }
                          if (passwordText.text.length < 6) {
                            return _controller.showMyDialog(
                                context: context,
                                title: 'Password',
                                message:
                                    'Password must contain at least 6 characters');
                          }
                          _controller
                              .saveDeliveryBoys(
                                  emailText.text, passwordText.text)
                              .whenComplete(() {
                            emailText.clear();
                            passwordText.clear();
                            _controller.showMyDialog(
                                context: context,
                                title: 'Save Delivery Person',
                                message: 'Saved Successfully');
                          });
                        },
                        child: Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.black54,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
