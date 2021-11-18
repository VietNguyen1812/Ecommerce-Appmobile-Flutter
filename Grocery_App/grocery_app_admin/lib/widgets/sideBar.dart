import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:grocery_app_admin/screens/adminUsersScreen.dart';
import 'package:grocery_app_admin/screens/categoryScreen.dart';
import 'package:grocery_app_admin/screens/deliveryBoyScreen.dart';
import 'package:grocery_app_admin/screens/homeScreen.dart';
import 'package:grocery_app_admin/screens/loginScreen.dart';
import 'package:grocery_app_admin/screens/manageBannersScreen.dart';
import 'package:grocery_app_admin/screens/notificationScreen.dart';
import 'package:grocery_app_admin/screens/orderScreen.dart';
import 'package:grocery_app_admin/screens/settingsScreen.dart';
import 'package:grocery_app_admin/screens/vendorScreen.dart';

class SideBarWidget {
  sideBarMenus(context, selectedRoute) {
    return SideBar(
      activeBackgroundColor: Colors.black54,
      activeIconColor: Colors.white,
      activeTextStyle: TextStyle(color: Colors.white),
      items: const [
        MenuItem(
          title: 'Dashboard',
          route: HomeScreen.id,
          icon: Icons.dashboard,
        ),
        MenuItem(
          title: 'Banners',
          route: BannerScreen.id,
          icon: CupertinoIcons.photo,
        ),
        MenuItem(
          title: 'Vendors',
          route: VendorScreen.id,
          icon: CupertinoIcons.group_solid,
        ),
        MenuItem(
          title: 'Delivery People',
          route: DeliveryBoyScreen.id,
          icon: Icons.delivery_dining,
        ),
        MenuItem(
          title: 'Categories',
          route: CategoryScreen.id,
          icon: Icons.category,
        ),
        MenuItem(
          title: 'Orders',
          route: OrderScreen.id,
          icon: CupertinoIcons.cart_fill,
        ),
        MenuItem(
          title: 'Send Notification',
          route: NotificationScreen.id,
          icon: Icons.notifications,
        ),
        MenuItem(
          title: 'Admin Users',
          route: AdminUsers.id,
          icon: Icons.person_rounded,
        ),
        MenuItem(
          title: 'Settings',
          route: SettingScreen.id,
          icon: Icons.settings,
        ),
        MenuItem(
          title: 'Exit',
          route: LoginScreen.id,
          icon: Icons.exit_to_app,
        ),
      ],
      selectedRoute: selectedRoute,
      onSelected: (item) {
        Navigator.of(context).pushNamed(item.route);
      },
      header: Container(
        height: 50,
        width: double.infinity,
        color: Colors.black26,
        child: Center(
          child: Text(
            'Menu',
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 2,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      footer: Container(
        height: 50,
        width: double.infinity,
        color: Colors.black26,
        child: Center(
          child: Image.asset(
            'images/logo.png',
            height: 30,
          ),
        ),
      ),
    );
  }
}
