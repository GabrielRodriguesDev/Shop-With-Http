// ignore_for_file: prefer_final_fields, unused_field, avoid_print, unnecessary_brace_in_string_interps

import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/models/product.dart';

import '../utils/constants.dart';

class ProductList with ChangeNotifier {
  //! Uma classe que estende ou usa como mixing o ChangeNotifier pode chamar a notifyListeners() qualquer momento que os dados
  //! dessa classe foram atualizados e você deseja informar um ouvinte sobre essa atualização.
  //! Isso geralmente é feito em um modelo de exibição para notificar a interface do usuário para reconstruir o layout com base
  //! nos novos dados.

  List<Product> _items = [];

  List<Product> get items => _items.toList();

  List<Product> get itemsFavorite =>
      _items.where((product) => product.isFavorite).toList();

  Future<void> loadProducts() async {
    _items.clear();
    final response =
        await http.get(Uri.parse('${Constants.PRODUCT_BASE_URL}.json'));
    if (response.body == 'null') return;
    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach(
      (productId, productData) {
        print('${productId} : ${productData}');
        print(_items);
        _items.add(
          Product(
            id: productId,
            name: productData['name'],
            description: productData['description'],
            price: productData['price'],
            imageUrl: productData['imageUrl'],
            isFavorite: productData['isFavorite'],
          ),
        );
      },
    );
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('${Constants.PRODUCT_BASE_URL}.json'),
      body: jsonEncode(
        {
          "name": product.name,
          "price": product.price,
          "description": product.description,
          "imageUrl": product.imageUrl,
          "isFavorite": product.isFavorite,
        },
      ),
    );

    final id = jsonDecode(response.body)['name'];
    _items.add(
      Product(
          id: id,
          name: product.name,
          price: product.price,
          description: product.description,
          imageUrl: product.imageUrl,
          isFavorite: product.isFavorite),
    );
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    int index = _items.indexWhere((prod) => prod.id == product.id);

    if (index >= 0) {
      await http.patch(
        Uri.parse('$Constants.PRODUCT_BASE_URL/${product.id}.json'),
        body: jsonEncode(
          {
            "name": product.name,
            "price": product.price,
            "description": product.description,
            "imageUrl": product.imageUrl,
          },
        ),
      );
      _items[index] = product;
      notifyListeners();
    }
    return Future.value();
  }

  Future<void> removeProduct(Product product) async {
    int index = _items.indexWhere((prod) => prod.id == product.id);
    if (index >= 0) {
      final product = _items[index];
      _items.remove(product);

      final response = await http.delete(
        Uri.parse('${Constants.PRODUCT_BASE_URL}/${product.id}.json'),
      );
      if (response.statusCode >= 400) {
        _items.insert(index, product);
        throw HttpException(
            msg: 'Não foi possível excluir o produto.',
            statusCode: response.statusCode);
      }
    }
    notifyListeners();
  }

  Future<void> saveProduct(Map<String, Object> data) {
    bool hasId = data['id'] != null;
    final product = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      name: data['name'] as String,
      description: data['description'] as String,
      price: data['price'] as double,
      imageUrl: data['imageUrl'] as String,
    );

    if (hasId) {
      return updateProduct(product);
    } else {
      return addProduct(product);
    }
  }

  int get itemsCount {
    return _items.length;
  }

  // ! Controlando o Favorite globalmente
  // List<Product> get items {
  //   if (_showFavorityOnly) {
  //     return _items.where((product) => product.isFavorite).toList();
  //   }
  //   return items.toList();
  // } //! Implementando get que retorna uma cópia da lista e não a referencia.
  // //! Se retornarmos a referencia, a lista poderá ser manipulada e esse não é o objetivo.

  // void showFavorityOnly() {
  //   _showFavorityOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavorityOnly = false;
  //   notifyListeners();
  // }
}
