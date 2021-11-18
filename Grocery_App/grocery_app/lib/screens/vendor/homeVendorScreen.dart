import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:grocery_app/controllers/vendor/drawerController.dart';
import 'package:grocery_app/widgets/vendor/drawerMenuWidget.dart';

class HomeVendorScreen extends StatefulWidget {
  static const String id = 'home-vendor-screen';

  @override
  _HomeVendorScreenState createState() => _HomeVendorScreenState();
}

class _HomeVendorScreenState extends State<HomeVendorScreen> {
  DrawerVendorController _controller = DrawerVendorController();
  GlobalKey<SliderMenuContainerState> _key =
      new GlobalKey<SliderMenuContainerState>();
  String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SliderMenuContainer(
            appBarColor: Colors.white,
            appBarHeight: 80,
            key: _key,
            sliderMenuOpenSize: 200,
            title: Text(
              '',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            trailing: Row(
              children: [
                IconButton(
                  onPressed: () {}, 
                  icon: Icon(CupertinoIcons.bell)
                ),
              ],
            ),
            sliderMenu: MenuWidget(
              onItemClick: (title) {
                _key.currentState.closeDrawer();
                setState(() {
                  this.title = title;
                });
              },
            ),
            sliderMain: _controller.drawerScreen(title, context)),
      ),
    );
  }
}
