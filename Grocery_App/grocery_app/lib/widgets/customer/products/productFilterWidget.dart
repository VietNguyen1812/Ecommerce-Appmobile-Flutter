import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/controllers/customer/productController.dart';
import 'package:grocery_app/providers/storeProvider.dart';
import 'package:provider/provider.dart';

class ProductFilterWidget extends StatefulWidget {
  @override
  _ProductFilterWidgetState createState() => _ProductFilterWidgetState();
}

class _ProductFilterWidgetState extends State<ProductFilterWidget> {
  List _subCatList = [];
  ProductController _controller = ProductController();
  bool _activeAll = true;
  bool _active = false;

  @override
  void didChangeDependencies() {
    var _store = Provider.of<StoreProvider>(context);

    FirebaseFirestore.instance
        .collection('products')
        .where('category.mainCategory',
            isEqualTo: _store.selectedProductCategory)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (mounted) {
          setState(() {
            _subCatList.add(doc['category']['subCategory']);
          });
        }
      });
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var _storeData = Provider.of<StoreProvider>(context);

    return FutureBuilder<DocumentSnapshot>(
      future:
          _controller.category.doc(_storeData.selectedProductCategory).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (!snapshot.hasData) {
          return Container();
        }

        Map<String, dynamic> data = snapshot.data.data();
        return Container(
            height: 50,
            color: Colors.grey,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(
                  width: 10,
                ),
                ActionChip(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  elevation: 4,
                  label: _activeAll == true
                      ? Text(
                          'All ${_storeData.selectedProductCategory}',
                          style: TextStyle(color: Colors.white),
                        )
                      : Text(
                          'All ${_storeData.selectedProductCategory}',
                        ),
                  onPressed: () {
                    _active = false;
                    _storeData.selectedCategorySub(null);
                    _activeAll = true;
                  },
                  backgroundColor: _activeAll == true
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: ScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: _subCatList.contains(data['subCat'][index]['name'])
                          ? ActionChip(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              elevation: 4,
                              label: _active == true &&
                                      data['subCat'][index]['name'] ==
                                          _storeData.selectedSubCategory
                                  ? Text(
                                      data['subCat'][index]['name'],
                                      style: TextStyle(color: Colors.white),
                                    )
                                  : Text(
                                      data['subCat'][index]['name'],
                                    ),
                              onPressed: () {
                                _activeAll = false;
                                _storeData.selectedCategorySub(
                                    data['subCat'][index]['name']);
                                _active = true;
                              },
                              backgroundColor: _active == true &&
                                      data['subCat'][index]['name'] ==
                                          _storeData.selectedSubCategory
                                  ? Theme.of(context).primaryColor
                                  : Colors.white,
                            )
                          : Container(),
                    );
                  },
                  itemCount: data.length,
                ),
              ],
            ));
      },
    );
  }
}
