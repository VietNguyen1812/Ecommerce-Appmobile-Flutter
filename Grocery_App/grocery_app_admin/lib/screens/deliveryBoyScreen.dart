import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:grocery_app_admin/widgets/delivery/approvedBoys.dart';
import 'package:grocery_app_admin/widgets/delivery/createDeliveryBoy.dart';
import 'package:grocery_app_admin/widgets/delivery/newBoys.dart';
import 'package:grocery_app_admin/widgets/sideBar.dart';

class DeliveryBoyScreen extends StatelessWidget {
  static const String id = 'deliveryboy-screen';

  @override
  Widget build(BuildContext context) {
    SideBarWidget _sideBar = SideBarWidget();

    return DefaultTabController(
      length: 2,
      child: AdminScaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: const Text(
            'Grocery App Dashboard',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black87,
        ),
        sideBar: _sideBar.sideBarMenus(context, DeliveryBoyScreen.id),
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(10),
            height: MediaQuery.of(context).size.height,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Delivery People',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 36,
                ),
              ),
              Text('Create new Delivery People and Manage all Delivery People'),
              Divider(
                thickness: 5,
              ),
              CreateNewBoyWidget(),
              Divider(
                thickness: 5,
              ),
              //List of delivery people
              TabBar(
                  indicatorColor: Theme.of(context).primaryColor,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.black54,
                  tabs: [
                    Tab(
                      text: 'NEW',
                    ),
                    Tab(
                      text: 'APPROVED',
                    )
                  ]),
              Expanded(
                child: Container(
                  child: TabBarView(
                    children: [
                      NewBoys(),
                      ApprovedBoys()
                    ],
                  ),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
