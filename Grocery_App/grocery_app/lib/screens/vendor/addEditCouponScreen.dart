import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/controllers/vendor/firebaseVendorController.dart';
import 'package:intl/intl.dart';

class AddEditCoupon extends StatefulWidget {
  static const String id = 'update-coupon';
  final DocumentSnapshot document;
  AddEditCoupon({this.document});

  @override
  _AddEditCouponState createState() => _AddEditCouponState();
}

class _AddEditCouponState extends State<AddEditCoupon> {
  final _formKey = GlobalKey<FormState>();
  FirebaseVendorController _controller = FirebaseVendorController();
  DateTime _selectedDate = DateTime.now();
  bool _active = false;

  var dateText = TextEditingController();
  var titleText = TextEditingController();
  var detailsText = TextEditingController();
  var discountRate = TextEditingController();

  _selectDate(context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2050));
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        String formattedText = DateFormat('yyyy-MM-dd').format(_selectedDate);
        dateText.text = formattedText;
      });
    }
  }

  @override
  void initState() {
    if (widget.document != null)
      setState(() {
        titleText.text = widget.document.data()['title'];
        discountRate.text = widget.document.data()['discountRate'].toString();
        detailsText.text = widget.document.data()['details'];
        dateText.text = widget.document.data()['expiry'].toDate().toString();
        _active = widget.document.data()['active'];
      });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Add / Edit Coupon',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: titleText,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Coupon title';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        labelText: 'Coupon title',
                        labelStyle: TextStyle(
                          color: Colors.grey,
                        )),
                  ),
                  TextFormField(
                    controller: discountRate,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Discount %';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        labelText: 'Discount %',
                        labelStyle: TextStyle(color: Colors.grey)),
                  ),
                  TextFormField(
                    controller: dateText,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Apply Expiry Date';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      labelText: 'Expiry Date',
                      labelStyle: TextStyle(color: Colors.grey),
                      suffixIcon: InkWell(
                          onTap: () {
                            _selectDate(context);
                          },
                          child: Icon(
                            Icons.date_range_outlined,
                          )),
                    ),
                  ),
                  TextFormField(
                    controller: detailsText,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Coupon details';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        labelText: 'Coupon Details',
                        labelStyle: TextStyle(color: Colors.grey)),
                  ),
                  SwitchListTile(
                      activeColor: Theme.of(context).primaryColor,
                      contentPadding: EdgeInsets.zero,
                      title: Text('Activate Coupon'),
                      value: _active,
                      onChanged: (bool newValue) {
                        setState(() {
                          _active = !_active;
                        });
                      }),
                  SizedBox(
                    height: 20,
                  ),
                  Row(children: [
                    Expanded(
                      // ignore: deprecated_member_use
                      child: FlatButton(
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          'Submit',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            EasyLoading.show(status: 'Please wait...');
                            _controller
                                .saveCoupon(
                                    document: widget.document,
                                    title: titleText.text.toUpperCase(),
                                    details: detailsText.text,
                                    discountRate: int.parse(discountRate.text),
                                    expiry: _selectedDate,
                                    active: _active)
                                .then((value) {
                              setState(() {
                                titleText.clear();
                                discountRate.clear();
                                dateText.clear();
                                detailsText.clear();
                                _active = false;
                              });
                              EasyLoading.showSuccess(
                                  'Saved Coupon successfully');
                            });
                          }
                        },
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          )),
    );
  }
}
