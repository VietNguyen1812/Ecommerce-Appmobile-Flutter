import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/controllers/customer/ratingVendorController.dart';
import 'package:grocery_app/controllers/vendor/firebaseVendorController.dart';
import 'package:grocery_app/providers/storeProvider.dart';
import 'package:provider/provider.dart';

class Rating extends StatefulWidget {
  final int maximumRating;
  final Function(int) onRatingSelected;

  Rating(this.onRatingSelected, [this.maximumRating = 5]);

  @override
  _Rating createState() => _Rating();
}

class _Rating extends State<Rating> {
  FirebaseVendorController _vendorController = FirebaseVendorController();
  User user = FirebaseAuth.instance.currentUser;
  FirebaseAuth _auth = FirebaseAuth.instance;
  RatingVendorController _ratingVendorController = RatingVendorController();

  int _currentRating = 0;
  int _yourVote = 0;

  @override
  void initState() {
    getStar();

    super.initState();
  }

  Future<void> getStar() async {
    var _store = Provider.of<StoreProvider>(context, listen: false);
    await _vendorController
        .getShopById(_store.storedetails['uid'])
        .then((value) {
      for (int i = 0; i < value.data()['totalRating']; i++) {
        // ignore: unnecessary_brace_in_string_interps
        if (value.data()['rating']['${i}']['customerId'] ==
            _auth.currentUser.uid) {
          setState(() {
            // ignore: unnecessary_brace_in_string_interps
            _yourVote = value.data()['rating']['${i}']['stars'];
          });
        }
      }
    });
  }

  Widget _buildRatingStar(int index) {
    if (index < _currentRating) {
      return Icon(Icons.star, color: Colors.yellow);
    } else {
      return Icon(Icons.star_border_outlined);
    }
  }

  Widget _buildBody() {
    final stars = List<Widget>.generate(this.widget.maximumRating, (index) {
      return GestureDetector(
        child: _buildRatingStar(index),
        onTap: () {
          setState(() {
            _currentRating = index + 1;
          });

          this.widget.onRatingSelected(_currentRating);
        },
      );
    });

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        'VOTE US TO MAKE US BETTER',
        style: TextStyle(
            color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
      ),
      SizedBox(
        height: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: stars,
      ),
      SizedBox(
        height: 10,
      ),
      _yourVote != 0
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Your vote recently: ',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  _yourVote != 1
                      ? '${_yourVote.toString()} stars'
                      : '${_yourVote.toString()} star',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                )
              ],
            )
          : Container(),
      SizedBox(
        height: 10,
      ),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        // ignore: deprecated_member_use
        FlatButton(
            onPressed: () {
              EasyLoading.show(status: 'Submiting your vote');
              _ratingVendorController.ratingStar(_currentRating, context).whenComplete(() {
                Navigator.pop(context);
              }).then((value) {
                _ratingVendorController.calculateStars(_currentRating, context);
              });
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: Theme.of(context).primaryColor,
            child: Text(
              'SUBMIT',
              style: TextStyle(color: Colors.white),
            )),
        SizedBox(
          width: 10,
        ),
        // ignore: deprecated_member_use
        FlatButton(
          color: Theme.of(context).primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Text("Clear", style: TextStyle(color: Colors.white)),
          onPressed: () {
            setState(() {
              _currentRating = 0;
            });
            this.widget.onRatingSelected(_currentRating);
          },
        )
      ])
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }
}
