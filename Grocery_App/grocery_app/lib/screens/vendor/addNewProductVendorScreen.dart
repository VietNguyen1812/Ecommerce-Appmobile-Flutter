import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/providers/vendor/productProvider.dart';
import 'package:grocery_app/widgets/vendor/categoryList.dart';
import 'package:provider/provider.dart';

class AddNewProduct extends StatefulWidget {
  static const String id = 'addnewproduct-screen';

  @override
  _AddNewProductState createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProduct> {

  final _formKey = GlobalKey<FormState>();

  List<String> _collections = [
    'Featured Products',
    'Best Selling',
    'Recently Added'
  ];
  String dropdownValue;
  
  var _categoryTextController = TextEditingController();
  var _subCategoryTextController = TextEditingController();
  var _comparedPriceTextController = TextEditingController();
  var _brandTextController = TextEditingController();
  var _lowStockTextController = TextEditingController();
  var _stockTextController = TextEditingController();

  File _image;
  bool _visible = false;
  bool _track = false;

  String productName;
  String description;
  double price;
  double comparedPrice;
  String sku;
  String weight;
  double tax;

  @override
  Widget build(BuildContext context) {
    var _provider = Provider.of<ProductProvider>(context);

    return DefaultTabController(
      length: 2,
      initialIndex: 1, //advoid textfield clearing automatically
      child: Scaffold(
        appBar: AppBar(),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Material(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Container(
                          child: Text('Products / Add'),
                        ),
                      ),
                      // ignore: deprecated_member_use
                      FlatButton.icon(
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              if (_image != null) {
                                EasyLoading.show(status: 'Saving...');
                                //upload image to storage
                                _provider
                                    .uploadProductImage(
                                        _image.path, productName)
                                    .then((url) {
                                  if (_categoryTextController.text.isNotEmpty) {
                                    if (_subCategoryTextController
                                        .text.isNotEmpty) {
                                      if (url != null) {
                                        //upload product data to firestore
                                        EasyLoading.dismiss();
                                        _provider.saveProductDataToDb(
                                          context: context,
                                          comparedPrice: int.parse(_comparedPriceTextController.text),
                                          brand: _brandTextController.text,
                                          collection: 'Recently Added',
                                          description: description,
                                          lowStockQty: int.parse(_lowStockTextController.text),
                                          price: price,
                                          sku: sku,
                                          stockQty: int.parse(_stockTextController.text),
                                          tax: tax,
                                          weight: weight,
                                          productName: productName,
                                        );

                                        setState(() {
                                          _formKey.currentState.reset();
                                          _comparedPriceTextController.clear();
                                          dropdownValue = null;
                                          _subCategoryTextController.clear();
                                          _categoryTextController.clear();
                                          _brandTextController.clear();
                                          _track = false;
                                          _image = null;
                                          _visible = false;
                                        });

                                      } else {
                                        _provider.alertDialog(
                                            context: context,
                                            title: 'IMAGE UPLOAD',
                                            content:
                                                'Failed to upload product image');
                                      }
                                    } else {
                                      _provider.alertDialog(
                                          context: context,
                                          title: 'Sub Category',
                                          content:
                                              'Sub Category not selected');
                                    }
                                  } else {
                                    _provider.alertDialog(
                                        context: context,
                                        title: 'Main Category',
                                        content: 'Main Category not selected');
                                  }
                                });
                              } else {
                                _provider.alertDialog(
                                    context: context,
                                    title: 'PRODUCT IMAGE',
                                    content: 'Product Image not selected');
                              }
                            }
                          },
                          color: Theme.of(context).primaryColor,
                          icon: Icon(
                            Icons.save,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          )),
                    ],
                  ),
                ),
              ),
              TabBar(
                  indicatorColor: Theme.of(context).primaryColor,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Theme.of(context).primaryColor,
                  tabs: [
                    Tab(
                      text: 'GENERAL',
                    ),
                    Tab(
                      text: 'INVENTORY',
                    )
                  ]),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Card(
                  child: TabBarView(children: [
                    ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Enter Product name';
                                  }
                                  setState(() {
                                    productName = value;
                                  });
                                  return null;
                                },
                                decoration: InputDecoration(
                                    labelText: 'Product Name*',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]))),
                              ),
                              TextFormField(
                                keyboardType: TextInputType.multiline,
                                maxLines: 5,
                                maxLength: 500,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Enter Product description';
                                  }
                                  setState(() {
                                    description = value;
                                  });
                                  return null;
                                },
                                decoration: InputDecoration(
                                    labelText: 'About Product*',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]))),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    _provider.getProductImage().then((image) {
                                      _image = image;
                                    });
                                  },
                                  child: SizedBox(
                                    width: 150,
                                    height: 150,
                                    child: Card(
                                        child: Center(
                                      child: _image == null
                                          ? Text('Select Image')
                                          : Image.file(_image),
                                    )),
                                  ),
                                ),
                              ),
                              TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Enter selling price';
                                  }
                                  setState(() {
                                    price = double.parse(value);
                                  });
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    labelText: 'Price*',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]))),
                              ),
                              TextFormField(
                                controller: _comparedPriceTextController,
                                validator: (value) {
                                  if (price > double.parse(value)) {
                                    return 'Compared price should be higher than price';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    labelText:
                                        'Compared Price*', //Price before discount
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]))),
                              ),
                              // Container(
                              //   child: Row(
                              //     children: [
                              //       Text(
                              //         'Collection',
                              //         style: TextStyle(color: Colors.grey),
                              //       ),
                              //       SizedBox(
                              //         width: 10,
                              //       ),
                              //       DropdownButton<String>(
                              //         hint: Text('Select Collection'),
                              //         value: dropdownValue,
                              //         icon: Icon(Icons.arrow_drop_down),
                              //         onChanged: (String value) {
                              //           setState(() {
                              //             dropdownValue = value;
                              //           });
                              //         },
                              //         items: _collections
                              //             .map<DropdownMenuItem<String>>(
                              //                 (String value) {
                              //           return DropdownMenuItem<String>(
                              //             value: value,
                              //             child: Text(value),
                              //           );
                              //         }).toList(),
                              //       )
                              //     ],
                              //   ),
                              // ),
                              TextFormField(
                                controller: _brandTextController,
                                decoration: InputDecoration(
                                    labelText: 'Brand*',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]))),
                              ),
                              TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Enter SKU';
                                  }
                                  setState(() {
                                    sku = value;
                                  });
                                  return null;
                                },
                                decoration: InputDecoration(
                                    labelText: 'SKU*', //Item code
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]))),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 20, bottom: 10),
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
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey[300]))),
                                        ),
                                      ),
                                    ),
                                    IconButton(
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
                                        icon: Icon(Icons.edit_outlined))
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: _visible,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 20),
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
                                            controller:
                                                _subCategoryTextController,
                                            decoration: InputDecoration(
                                                hintText: 'not selected*',
                                                labelStyle: TextStyle(
                                                    color: Colors.grey),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey[300]))),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return SubCategoryList();
                                                }).whenComplete(() {
                                              setState(() {
                                                _subCategoryTextController
                                                        .text =
                                                    _provider
                                                        .selectedSubCategory;
                                              });
                                            });
                                          },
                                          icon: Icon(Icons.edit_outlined))
                                    ],
                                  ),
                                ),
                              ),
                              TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Enter weight';
                                  }
                                  setState(() {
                                    weight = value;
                                  });
                                  return null;
                                },
                                decoration: InputDecoration(
                                    labelText: 'Weight.   eg:- Kg, gm, etc',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]))),
                              ),
                              TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Enter Tax %';
                                  }
                                  setState(() {
                                    tax = double.parse(value);
                                  });
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    labelText: 'Tax %',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]))),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          SwitchListTile(
                            value: _track,
                            onChanged: (selected) {
                              setState(() {
                                _track = !_track;
                              });
                            },
                            title: Text('Track Inventory'),
                            activeColor: Theme.of(context).primaryColor,
                            subtitle: Text(
                              'Switch ON to track Inventory',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                          Visibility(
                            visible: _track,
                            child: SizedBox(
                              height: 300,
                              width: double.infinity,
                              child: Card(
                                elevation: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: _stockTextController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            labelText: 'Inventory Quantity*',
                                            labelStyle:
                                                TextStyle(color: Colors.grey),
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey[300]))),
                                      ),
                                      TextFormField(
                                        keyboardType: TextInputType.number,
                                        controller: _lowStockTextController,
                                        decoration: InputDecoration(
                                            labelText:
                                                'Inventory low stock quantity*',
                                            labelStyle:
                                                TextStyle(color: Colors.grey),
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey[300]))),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ]),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
