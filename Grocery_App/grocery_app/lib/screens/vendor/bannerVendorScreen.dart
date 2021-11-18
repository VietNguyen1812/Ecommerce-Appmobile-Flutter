import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/controllers/vendor/firebaseVendorController.dart';
import 'package:grocery_app/providers/vendor/productProvider.dart';
import 'package:grocery_app/widgets/vendor/bannerCard.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class BannerVendorScreen extends StatefulWidget {
  @override
  _BannerVendorScreenState createState() => _BannerVendorScreenState();
}

class _BannerVendorScreenState extends State<BannerVendorScreen> {
  FirebaseVendorController _controller = FirebaseVendorController();
  bool _visible = false;
  File _image;
  var _imagePathText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var _provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          BannerCard(),
          Divider(
            thickness: 3,
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: Center(
              child: Text(
                'ADD NEW BANNER',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                  height: 150,
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    color: Colors.grey[200],
                    child: _image != null
                        ? Image.file(_image, fit: BoxFit.fill,)
                        : Center(
                            child: Text('No Image Selected'),
                          ),
                  ),
                ),
                TextFormField(
                  controller: _imagePathText,
                  enabled: false,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder()),
                ),
                SizedBox(
                  height: 20,
                ),
                Visibility(
                  visible: _visible ? false : true,
                  child: Row(
                    children: [
                      Expanded(
                          // ignore: deprecated_member_use
                          child: FlatButton(
                        onPressed: () {
                          setState(() {
                            _visible = true;
                          });
                        },
                        child: Text(
                          'Add New Banner',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        color: Theme.of(context).primaryColor,
                      ))
                    ],
                  ),
                ),
                Visibility(
                  visible: _visible,
                  child: Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                // ignore: deprecated_member_use
                                child: FlatButton(
                              onPressed: () {
                                getBannerImage().then((value) {
                                  if (_image != null) {
                                    setState(() {
                                      _imagePathText.text = _image.path;
                                    });
                                  }
                                });
                              },
                              child: Text(
                                'Upload Image',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              color: Theme.of(context).primaryColor,
                            ))
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: AbsorbPointer(
                              absorbing: _image != null ? false : true,
                              // ignore: deprecated_member_use
                              child: FlatButton(
                                onPressed: () {
                                  EasyLoading.show(status: 'Saving...');
                                  uploadBannerImage(
                                          _image.path, _provider.shopName)
                                      .then((url) {
                                    if (url != null) {
                                      //save banner url to firestore
                                      _controller.saveBanner(url);
                                      setState(() {
                                        _imagePathText.clear();
                                        _image = null;
                                      });
                                      EasyLoading.dismiss();
                                      _provider.alertDialog(
                                          context: context,
                                          title: 'Banner Upload',
                                          content:
                                              'Banner Image uploaded successfully...');
                                    } else {
                                      EasyLoading.dismiss();
                                      _provider.alertDialog(
                                          context: context,
                                          title: 'Banner Upload',
                                          content: 'Banner Upload failed!!!');
                                    }
                                  });
                                },
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                color: _image != null
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                            ))
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                // ignore: deprecated_member_use
                                child: FlatButton(
                              onPressed: () {
                                setState(() {
                                  _visible = false;
                                  _imagePathText.clear();
                                  _image = null;
                                });
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              color: Colors.black54,
                            ))
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<File> getBannerImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 10);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
    return _image;
  }

  Future<String> uploadBannerImage(filePath, shopName) async {
    File file =
        File(filePath); //need file to upload, we already have inside provider
    var timeStamp = Timestamp.now().microsecondsSinceEpoch;

    FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      await _storage.ref('vendorBanner/$shopName/$timeStamp').putFile(file);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print(e.code);
    }
    //now after upload file we need to file url path to save in database
    String downloadURL = await _storage
        .ref('vendorBanner/$shopName/$timeStamp')
        .getDownloadURL();
    return downloadURL;
  }
}
