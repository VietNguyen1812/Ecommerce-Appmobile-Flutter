import 'package:flutter/cupertino.dart';

class OrderProvider with ChangeNotifier {
  String status;
  String amount;
  String subTotal;
  String firstName;
  String lastName;
  String address;
  bool success = false;

  filterOrder(status) {
    this.status = status;
    notifyListeners();
  }

  totalAmount(amount) {
    this.amount = amount.toStringAsFixed(0);
    notifyListeners();
  }

  getFirstName(firstName) {
    this.firstName = firstName;
    notifyListeners();
  }

  getLastName(lastName) {
    this.lastName = lastName;
    notifyListeners();
  }

  getAddress(address) {
    this.address = address;
    notifyListeners();
  }

  paymentStatus(success) {
    this.success = success;
    notifyListeners();
  }
}