import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/widgets/customer/categoriesWidget.dart';
import 'package:grocery_app/widgets/customer/products/bestSellingProducts.dart';
import 'package:grocery_app/widgets/customer/products/featuredProducts.dart';
import 'package:grocery_app/widgets/customer/products/recentlyAddedProducts.dart';
import 'package:grocery_app/widgets/customer/vendorAppbar.dart';
import 'package:grocery_app/widgets/customer/vendorBanner.dart';

class VendorHomeScreen extends StatelessWidget {
  static const String id = 'vendor-screen';

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            VendorAppbar()
          ];
        },
        body: ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            VendorBanner(),
            VendorCategories(),
            RecentlyAddedProducts(),
            FeaturedProducts(),
            BestSellingProducts(),
          ],
        )
      ),
    );
  }
}
