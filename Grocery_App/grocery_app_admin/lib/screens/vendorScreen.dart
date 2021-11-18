import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:grocery_app_admin/widgets/sideBar.dart';
import 'package:grocery_app_admin/widgets/vendor/vendorDatatableWidget.dart';

class VendorScreen extends StatefulWidget {
  static const String id = 'vendor-screen';

  @override
  _VendorScreenState createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  SideBarWidget _sideBar = SideBarWidget();

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'Grocery App Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
      ),
      sideBar: _sideBar.sideBarMenus(context, VendorScreen.id),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.all(10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Vendor Management',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 36,
              ),
            ),
            Text('Manage all Vendor activities'),
            Divider(
              thickness: 5,
            ),
            VendorDatatable(),
            Divider(
              thickness: 5,
            ),
          ]),
        ),
      ),
    );
  }
}
