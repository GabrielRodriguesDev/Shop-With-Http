// ignore_for_file: prefer_final_fields, empty_statements

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:shop/models/cart_item.dart';

import 'package:shop/utils/constants.dart';
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

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();
    final response = await http.post(
      Uri.parse('${Constants.ORDER_BASE_URL}.json'),
      body: jsonEncode(
        {
          'total': cart.totalAmount,
          'date': date.toIso8601String(),
          'products': cart.cartItems.values
              .map(
                (items) => {
                  'id': items.id,
                  'product': items.productId,
                  'name': items.name,
                  'quantity': items.quantity,
                  'price': items.price,
                },
              )
              .toList()
        },
      ),
    );

    final id = jsonDecode(response.body)['name'];
    _orders.insert(
      0,
      Order(
        id: id,
        total: cart.totalAmount,
        date: date,
        products: cart.cartItems.values.toList(),
      ),
    );

    notifyListeners();
  }

  Future<void> loadOrders() async {
    _orders.clear();
    final response =
        await http.get(Uri.parse('${Constants.ORDER_BASE_URL}.json'));
    if (response.body == 'null') return;
    Map<String, dynamic> data = jsonDecode(response.body);
    print(data);
    data.forEach(
      (orderId, orderData) {
        _orders.add(
          Order(
            id: orderId,
            date: DateTime.parse(orderData['date']),
            total: orderData['total'],
            products: (orderData['products'] as List<dynamic>).map((product) {
              return CartItem(
                  id: product['id'],
                  productId: product['product'],
                  name: product['name'],
                  quantity: product['quantity'],
                  price: product['price']);
            }).toList(),
          ),
        );
      },
    );
    notifyListeners();
  }
}
