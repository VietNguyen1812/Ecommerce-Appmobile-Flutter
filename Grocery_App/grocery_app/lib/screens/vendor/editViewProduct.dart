import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/controllers/vendor/firebaseVendorController.dart';
import 'package:grocery_app/providers/vendor/productProvider.dart';
import 'package:grocery_app/widgets/vendor/categoryList.dart';
import 'package:provider/provider.dart';

class EditViewProduct extends StatefulWidget {
  final String productId;
  EditViewProduct({this.productId});

  @override
  _EditViewProductState createState() => _EditViewProductState();
}

class _EditViewProductState extends State<EditViewProduct> {
  FirebaseVendorController _controller = FirebaseVendorController();
  final _formKey = GlobalKey<FormState>();

  List<String> _collections = [
    'Featured Products',
    'Best Selling',
    'Recently Added'
  ];
  String dropdownValue;

  var _brandText = TextEditingController();
  var _skuText = TextEditingController();
  var _productNameText = TextEditingController();
  var _weightText = TextEditingController();
  var _priceText = TextEditingController();
  var _comparedPriceText = TextEditingController();
  var _descriptionText = TextEditingController();
  var _categoryTextController = TextEditingController();
  var _subCategoryTextController = TextEditingController();
  var _stockTextController = TextEditingController();
  var _lowStockTextController = TextEditingController();
  var _taxTextController = TextEditingController();

  DocumentSnapshot doc;
  double discount;
  String image;
  String categoryImage;
  File _image;
  bool _visible = false;
  bool _editing = true;

  @override
  void initState() {
    getProductDetails();
    super.initState();
  }

  Future<void> getProductDetails() async {
    _controller.products
        .doc(widget.productId)
        .get()
        .then((DocumentSnapshot document) {
      if (document.exists) {
        setState(() {
          doc = document;
          _brandText.text = document.data()['brand'];
          _skuText.text = document.data()['sku'];
          _productNameText.text = document.data()['productName'];
          _weightText.text = document.data()['weight'];
          _priceText.text = document.data()['price'].toString();
          _comparedPriceText.text = document.data()['comparedPrice'].toString();
          var difference = int.parse(_comparedPriceText.text) - double.parse(_priceText.text);
          discount = (difference / int.parse(_comparedPriceText.text) * 100);
          image = document.data()['productImage'];
          _descriptionText.text = document.data()['description'];
          _categoryTextController.text =
              document.data()['category']['mainCategory'];
          _subCategoryTextController.text =
              document.data()['category']['subCategory'];
          dropdownValue = document.data()['collection'];
          _stockTextController.text = document.data()['stockQty'].toString();
          _lowStockTextController.text =
              document.data()['lowStockQty'].toString();
          _taxTextController.text = document.data()['tax'].toString();
          categoryImage = document.data()['category']['categoryImage'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var _provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white), //make back button white
        actions: [
          // ignore: deprecated_member_use
          FlatButton(
              onPressed: () {
                setState(() {
                  _editing = false;
                });
              },
              child: Text(
                'Edit',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      bottomSheet: Container(
        height: 60,
        child: Row(
          children: [
            Expanded(
                child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )),
            Expanded(
                child: AbsorbPointer(
              absorbing: _editing,
              child: InkWell(
                onTap: () {
                  if (_formKey.currentState.validate()) {
                    EasyLoading.show(status: 'Saving...');
                    if (_image != null) {
                      //upload new image and save data
                      _provider
                          .uploadProductImage(
                              _image.path, _productNameText.text)
                          .then((url) {
                        if (url != null) {
                          EasyLoading.dismiss();
                          _provider.updateProduct(
                            context: context,
                            productName: _productNameText.text,
                            weight: _weightText.text,
                            tax: double.parse(_taxTextController.text),
                            stockQty: int.parse(_stockTextController.text),
                            sku: _skuText.text,
                            price: double.parse(_priceText.text),
                            lowStockQty:
                                int.parse(_lowStockTextController.text),
                            description: _descriptionText.text,
                            collection: dropdownValue,
                            brand: _brandText.text,
                            comparedPrice: int.parse(_comparedPriceText.text),
                            productId: widget.productId,
                            image: image,
                            category: _categoryTextController.text,
                            subCategory: _subCategoryTextController.text,
                            categoryImage: categoryImage,
                          );
                        }
                      });
                    } else {
                      //no need to change image, just save new data, no need to upload image
                      _provider.updateProduct(
                        context: context,
                        productName: _productNameText.text,
                        weight: _weightText.text,
                        tax: double.parse(_taxTextController.text),
                        stockQty: int.parse(_stockTextController.text),
                        sku: _skuText.text,
                        price: double.parse(_priceText.text),
                        lowStockQty: int.parse(_lowStockTextController.text),
                        description: _descriptionText.text,
                        collection: dropdownValue,
                        brand: _brandText.text,
                        comparedPrice: int.parse(_comparedPriceText.text),
                        productId: widget.productId,
                        image: image,
                        category: _categoryTextController.text,
                        subCategory: _subCategoryTextController.text,
                        categoryImage: categoryImage,
                      );
                      EasyLoading.dismiss();
                    }
                    _provider.resetProvider();
                  }
                },
                child: Container(
                  color: Colors.pinkAccent,
                  child: Center(
                    child: Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
      body: doc == null
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: ListView(
                  children: [
                    AbsorbPointer(
                      absorbing: _editing,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 130,
                                  height: 30,
                                  child: TextFormField(
                                    controller: _brandText,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        hintText: 'Brand',
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        border: OutlineInputBorder(),
                                        filled: true,
                                        fillColor: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(.1)),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('SKU: '),
                                    Container(
                                      width: 50,
                                      child: TextFormField(
                                        controller: _skuText,
                                        style: TextStyle(fontSize: 12),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.zero,
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ]),
                          SizedBox(
                            height: 20,
                            child: TextFormField(
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none),
                              controller: _productNameText,
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            child: TextFormField(
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none),
                              controller: _weightText,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    prefixText: '\$',
                                  ),
                                  controller: _priceText,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              Container(
                                width: 80,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    prefixText: '\$',
                                  ),
                                  controller: _comparedPriceText,
                                  style: TextStyle(
                                      fontSize: 18,
                                      decoration: TextDecoration.lineThrough),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: Colors.red),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: Text(
                                    '${discount.toStringAsFixed(0)}% OFF',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Text(
                            'Inclusive of all taxes',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                          InkWell(
                            onTap: () {
                              _provider.getProductImage().then((image) {
                                setState(() {
                                  _image = image;
                                });
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _image != null
                                  ? Center(
                                    child: Image.file(
                                        _image,
                                        height: 300,
                                      ),
                                  )
                                  : Center(
                                      child: Image.network(
                                        image,
                                        height: 300,
                                      ),
                                    ),
                            ),
                          ),
                          Text(
                            'About this product',
                            style: TextStyle(fontSize: 20),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              maxLines: null,
                              controller: _descriptionText,
                              keyboardType: TextInputType.multiline,
                              style: TextStyle(color: Colors.grey),
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 10),
                            child: Row(
                              children: [
                                Text(
                                  'Category',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: AbsorbPointer(
                                    absorbing:
                                        true, //block user entering category name
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Select Category name';
                                        }
                                        return null;
                                      },
                                      controller: _categoryTextController,
                                      decoration: InputDecoration(
                                          hintText: 'not selected*',
                                          labelStyle:
                                              TextStyle(color: Colors.grey),
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey[300]))),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _editing ? false : true,
                                  child: IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return CategoryList();
                                            }).whenComplete(() {
                                          setState(() {
                                            _categoryTextController.text =
                                                _provider.selectedCategory;
                                            _visible = true;
                                          });
                                        });
                                      },
                                      icon: Icon(Icons.edit_outlined)),
                                )
                              ],
                            ),
                          ),
                          Visibility(
                            visible: _visible,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 20),
                              child: Row(
                                children: [
                                  Text(
                                    'Sub Category',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: AbsorbPointer(
                                      absorbing: true,
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Select Sub Category name';
                                          }
                                          return null;
                                        },
                                        controller: _subCategoryTextController,
                                        decoration: InputDecoration(
                                            hintText: 'not selected*',
                                            labelStyle:
                                                TextStyle(color: Colors.grey),
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey[300]))),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return SubCategoryList();
                                            }).whenComplete(() {
                                          setState(() {
                                            _subCategoryTextController.text =
                                                _provider.selectedSubCategory;
                                          });
                                        });
                                      },
                                      icon: Icon(Icons.edit_outlined))
                                ],
                              ),
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                Text(
                                  'Collection',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                DropdownButton<String>(
                                  hint: Text('Select Collection'),
                                  value: dropdownValue,
                                  icon: Icon(Icons.arrow_drop_down),
                                  onChanged: (String value) {
                                    setState(() {
                                      dropdownValue = value;
                                    });
                                  },
                                  items: _collections
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                )
                              ],
                            ),
                          ),
                          Row(children: [
                            Text('Stock: '),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none),
                                controller: _stockTextController,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ]),
                          Row(children: [
                            Text('Low Stock: '),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none),
                                controller: _lowStockTextController,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ]),
                          Row(children: [
                            Text('Tax (%): '),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none),
                                controller: _taxTextController,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ]),
                          SizedBox(height: 60,)
                        ],
                      ),
                    )
                  ],
                ),
              )),
    );
  }
}
