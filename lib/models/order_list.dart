// ignore_for_file: prefer_final_fields

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'cart.dart';
import 'order.dart';

class OrderList with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders {
    return _orders.toList();
  }

  int get itemsCount {
    return _orders.length;
  }

  void addOrder(Cart cart) {
    _orders.insert(
      0,
      Order(
        id: Random().nextDouble().toString(),
        total: cart.totalAmount,
        date: DateTime.now(),
        products: cart.cartItems.values.toList(),
      ),
    );
    notifyListeners();
  }
}
