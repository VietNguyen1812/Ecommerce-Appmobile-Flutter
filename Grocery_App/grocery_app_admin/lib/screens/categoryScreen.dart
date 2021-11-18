import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:grocery_app_admin/widgets/category/categoryListWidget.dart';
import 'package:grocery_app_admin/widgets/category/categoryUploadWidget.dart';
import 'package:grocery_app_admin/widgets/sideBar.dart';

class CategoryScreen extends StatelessWidget {
  static const String id = 'category-screen';

  @override
  Widget build(BuildContext context) {
    SideBarWidget _sideBar = SideBarWidget();

    return AdminScaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'Grocery App Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
      ),
      sideBar: _sideBar.sideBarMenus(context, CategoryScreen.id),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.all(10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Categories',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 36,
              ),
            ),
            Text('Add New Categories And Sub Categories'),
            Divider(
              thickness: 5,
            ),
            CategoryCreateWidget(),
            Divider(
              thickness: 5,
            ),
            CategoryListWidget(),
          ]),
        ),
      ),
    );
  }
}
