import 'dart:html';

import 'package:flutter/material.dart';
import 'package:grocery_app_admin/controller/firebaseController.dart';
import 'package:firebase/firebase.dart' as fb;

class BannerUploadWidget extends StatefulWidget {
  @override
  _BannerUploadWidgetState createState() => _BannerUploadWidgetState();
}

class _BannerUploadWidgetState extends State<BannerUploadWidget> {
  FirebaseController _controller = FirebaseController();
  var _fileNameTextController = TextEditingController();
  bool _visible = false;
  bool _imageSelected = true;
  String _url;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      width: MediaQuery.of(context).size.width,
      height: 80,
      child: Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Row(
          children: [
            Visibility(
              visible: _visible,
              child: Container(
                child: Row(
                  children: [
                    AbsorbPointer(
                      absorbing: true,
                      child: SizedBox(
                          width: 300,
                          height: 30,
                          child: TextField(
                            controller: _fileNameTextController,
                            decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1)),
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'No image selected',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.only(left: 20)),
                          )),
                    ),
                    // ignore: deprecated_member_use
                    FlatButton(
                      onPressed: () {
                        uploadStorage();
                      },
                      child: Text(
                        'Upload Image',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.black54,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    AbsorbPointer(
                      absorbing: _imageSelected,
                      // ignore: deprecated_member_use
                      child: FlatButton(
                        onPressed: () {
                          _controller
                              .uploadBannerImageToDb(_url)
                              .then((downloadUrl) {
                            if (downloadUrl != null) {
                              _controller.showMyDialog(
                                  title: 'New Banner Image',
                                  message: 'Saved Banner Image Succesfully',
                                  context: context);
                            }
                          });
                        },
                        child: Text(
                          'Save Image',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: _imageSelected ? Colors.black12 : Colors.black54,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Visibility(
              visible: _visible ? false : true,
              // ignore: deprecated_member_use
              child: FlatButton(
                onPressed: () {
                  setState(() {
                    _visible = true;
                  });
                },
                child: Text(
                  'Add New Banner',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.black54,
              ),
            )
          ],
        ),
      ),
    );
  }

  void uploadImage({@required Function(File file) onSelected}) {
    InputElement uploadInput = FileUploadInputElement()
      ..accept = 'image/*'; //it will upload image only
    uploadInput.click();
    uploadInput.onChange.listen((event) {
      final file = uploadInput.files.first;
      final reader = FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) {
        onSelected(file);
      });
    });
  }

  void uploadStorage() {
    //upload selected image to Firebase storage
    final dateTime = DateTime.now();
    final path = 'bannerImage/$dateTime';
    uploadImage(onSelected: (file) {
      if (file != null) {
        setState(() {
          _fileNameTextController.text = file.name;
          _imageSelected = false;
          _url = path;
        });
        fb
            .storage()
            .refFromURL('gs://flutter-grocery-app-9ddff.appspot.com')
            .child(path)
            .put(file);
      }
    });
  }
}
