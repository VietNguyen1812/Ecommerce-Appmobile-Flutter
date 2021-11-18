import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/controllers/customer/productController.dart';
import 'package:image_picker/image_picker.dart';

class ProductProvider with ChangeNotifier {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ProductController _productController = ProductController();
  String selectedCategory;
  String selectedSubCategory;
  String categoryImage;
  File image;
  String pickError;
  String shopName;
  String productUrl;

  selectCategory(mainCategory, categoryImage) {
    this.selectedCategory = mainCategory;
    this.categoryImage = categoryImage;
    notifyListeners();
  }

  selectSubCategory(selected) {
    this.selectedSubCategory = selected;
    notifyListeners();
  }

  getShopName(shopName) {
    this.shopName = shopName;
    notifyListeners();
  }

  resetProvider() {
    //remove all the existing data before update next product
    this.selectedCategory = null;
    this.selectedSubCategory = null;
    this.categoryImage = null;
    this.image = null;
    this.productUrl = null;
    notifyListeners();
  }

  //upload image
  Future<String> uploadProductImage(filePath, productName) async {
    File file =
        File(filePath); //need file to upload, we already have inside provider
    var timeStamp = Timestamp.now().microsecondsSinceEpoch;

    FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      await _storage
          .ref('productImage/${this.shopName}/$productName$timeStamp')
          .putFile(file);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print(e.code);
    }
    //now after upload file we need to file url path to save in database
    String downloadURL = await _storage
        .ref('productImage/${this.shopName}/$productName$timeStamp')
        .getDownloadURL();
    this.productUrl = downloadURL;
    notifyListeners();
    return downloadURL;
  }

  Future<File> getProductImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 10);
    if (pickedFile != null) {
      this.image = File(pickedFile.path);
      notifyListeners();
    } else {
      this.pickError = 'No image selected.';
      print('No image selected.');
      notifyListeners();
    }
    return this.image;
  }

  alertDialog({context, title, content}) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  //save product data to firestore
  Future<void> saveProductDataToDb(
      //bring these details from Add Product Screen
      {productName,
      description,
      price,
      comparedPrice,
      collection,
      brand,
      sku,
      weight,
      tax,
      stockQty,
      lowStockQty,
      context}) {
    var timeStamp =
        DateTime.now().microsecondsSinceEpoch; //this will use as product id
    User user = FirebaseAuth.instance.currentUser;
    CollectionReference _products =
        FirebaseFirestore.instance.collection('products');
    try {
      _products.doc(timeStamp.toString()).set({
        'seller': {'shopName': this.shopName, 'sellerUid': user.uid},
        'productName': productName,
        'description': description,
        'price': price,
        'comparedPrice': comparedPrice,
        'revenueProduct': 0,
        'rating': 0.00,
        'star': 0.00,
        'totalRating': 0,
        'quantitySold': 0,
        'collection': collection,
        'brand': brand,
        'sku': sku,
        'category': {
          'mainCategory': this.selectedCategory,
          'subCategory': this.selectedSubCategory,
          'categoryImage': this.categoryImage
        },
        'weight': weight,
        'tax': tax,
        'stockQty': stockQty,
        'lowStockQty': lowStockQty,
        'published': false, //keep initial value as false
        'productId': timeStamp.toString(),
        'productImage': this.productUrl
      });
      this.alertDialog(
          context: context,
          title: 'SAVE DATA',
          content: 'Product Details saved successfully');
    } catch (e) {
      this.alertDialog(
          context: context, title: 'SAVE DATA', content: '${e.toString()}');
    }
    return null;
  }

  Future<void> updateProduct(
      //bring these details from Add Product Screen
      {productName,
      description,
      price,
      comparedPrice,
      collection,
      brand,
      sku,
      weight,
      tax,
      stockQty,
      lowStockQty,
      context,
      productId,
      image,
      category,
      subCategory,
      categoryImage}) {
    CollectionReference _products =
        FirebaseFirestore.instance.collection('products');
    try {
      _products.doc(productId).update({
        'productName': productName,
        'description': description,
        'price': price,
        'comparedPrice': comparedPrice,
        'collection': collection,
        'brand': brand,
        'sku': sku,
        'category': {
          'mainCategory': category,
          'subCategory': subCategory,
          'categoryImage':
              this.categoryImage == null ? categoryImage : this.categoryImage
        },
        'weight': weight,
        'tax': tax,
        'stockQty': stockQty,
        'lowStockQty': lowStockQty,
        'productImage': this.productUrl == null ? image : this.productUrl
      });
      this.alertDialog(
          context: context,
          title: 'SAVE DATA',
          content: 'Product Details saved successfully');
    } catch (e) {
      this.alertDialog(
          context: context, title: 'SAVE DATA', content: '${e.toString()}');
    }
    return null;
  }

  Future<void> updateQuantityProduct({
    stockQty,
    productId,
  }) {
    CollectionReference _products =
        FirebaseFirestore.instance.collection('products');
    _products.doc(productId).update({
      'stockQty': stockQty,
    });
    return null;
  }

  Future<void> updateQuantityProductSold({
    quantitySold,
    productId,
  }) {
    CollectionReference _products =
        FirebaseFirestore.instance.collection('products');
    _products.doc(productId).update({
      'quantitySold': quantitySold,
    });
    return null;
  }

  Future<void> updateRevenueProduct({
    revenueProduct,
    productId,
  }) {
    CollectionReference _products =
        FirebaseFirestore.instance.collection('products');
    _products.doc(productId).update({
      'revenueProduct': revenueProduct,
    });
    return null;
  }

  Future<DocumentSnapshot> getProductById(String id) async {
    var result = await _firestore.collection('products').doc(id).get();
    return result;
  }

  Future<void> calculateRevenueProduct(productId, revenue, context) async {
    DateTime _currentMonth = DateTime.now();
    await getProductById(productId).then((value) {
      DocumentReference doc = _productController.products.doc(productId);
      if (value.data()['revenueProduct'] == 0) {
        for (int i = 0; i < 12; i++) {
          // ignore: unrelated_type_equality_checks
          if (_currentMonth.month == i + 1) {
            doc.update({
              // ignore: unnecessary_brace_in_string_interps
              'revenueProduct.${i}.month': _currentMonth.month,
              // ignore: unnecessary_brace_in_string_interps
              'revenueProduct.${i}.revenue': revenue,
            });
          } else {
            doc.update({
              // ignore: unnecessary_brace_in_string_interps
              'revenueProduct.${i}.month': i + 1,
              // ignore: unnecessary_brace_in_string_interps
              'revenueProduct.${i}.revenue': 0,
            });
          }
        }
      } else {
        for (int i = 0; i < value.data()['revenueProduct'].length; i++) {
          // ignore: unnecessary_brace_in_string_interps
          if (value.data()['revenueProduct']['${i}']['month'] ==
              _currentMonth.month) {
            doc.update({
              // ignore: unnecessary_brace_in_string_interps
              'revenueProduct.${i}.revenue':
                  // ignore: unnecessary_brace_in_string_interps
                  value.data()['revenueProduct']['${i}']['revenue'] + revenue,
            });
            break;
          }
          if (i == value.data()['revenueProduct'].length - 1) {
            doc.update({
              // ignore: unnecessary_brace_in_string_interps
              'revenueProduct.${i}.month': _currentMonth.month,
              // ignore: unnecessary_brace_in_string_interps
              'revenueProduct.${i}.revenue':
                  // ignore: unnecessary_brace_in_string_interps
                  value.data()['revenueProduct']['${i}']['revenue'] + revenue,
            }).then((value) {
              EasyLoading.showSuccess('Successfully Updated Product Revenue');
            });
          }
        }
      }
    });
  }
}
