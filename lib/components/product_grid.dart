// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/product_grid_item.dart';

import '../models/product.dart';
import '../models/product_list.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({required this.showFavorityOnly});

  final bool showFavorityOnly;
  @override
  Widget build(BuildContext context) {
    //! Carregando o Provider.
    final provider = Provider.of<ProductList>(context);

    //! Pegando a lista de items que obtemos do provider.
    final List<Product> loadedProducts =
        showFavorityOnly ? provider.itemsFavorite : provider.items;

    //! Retornando o Widget
    return GridView.builder(
      itemCount: loadedProducts.length,

      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: loadedProducts[index],
        child: const ProductGridItem(),
      ),
      //* itemBuilder => Define como cada registro (index) será exibido em tela.

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //*  SliverGridDelegateWithFixedCrossAxisCount => Cria layouts de grade com um número fixo de blocos no eixo cruzado. (Vertical é o eixo principal de um GridView)

        crossAxisCount: 2,
        //*   crossAxisCount => Define quantos elementos vão aparecer no eixo cruzado (Horizontal).
        childAspectRatio: 3 / 2,
        //*   childAspectRatio => Dimensão de cada elemento que será exposto.
        crossAxisSpacing: 10,
        //*   crossAxisSpacing => Número de pixels que desja que separe um filho do outro no eixo horizontal.
        mainAxisSpacing: 10,
        //*   mainAxisSpacing => Número de pixels que desja que separe um filho do outro no eixo vertical.
      ),
    );
  }
}
