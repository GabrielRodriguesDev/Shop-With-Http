// ignore_for_file: sort_child_properties_last, todo

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/utils/app_routes.dart';

import '../models/cart.dart';

class ProductGridItem extends StatelessWidget {
  const ProductGridItem({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: true);
    final cart = Provider.of<Cart>(context, listen: false);

    return ClipRRect(
      //* ClipRRect => Widget que recorta seu filho usando um retângulo arredondado.

      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        //* GridTile => Widget que representa um bloco na GridView.

        child: GestureDetector(
          //* GestureDetector => Widget que detecta gestos.
          //* Estamos colocando uma Image como widget filho, pois assim passamos a impressão que ao clicar na imagem uma ação será tomada.

          child: Image.network(product.imageUrl, fit: BoxFit.cover),
          onTap: () {
            //* Definindo o funcionamento ao selecionar (onTap) o Widget (claro dentro do limite de tamanho do componente).

            Navigator.of(context)
                .pushNamed(AppRoutes.PRODUCT_DETAIL, arguments: product);
          },
        ),
        footer: GridTileBar(
          //* GridTileBar =>  Usado para adicionar um cabeçalho ou rodapé de uma ou duas linhas em um GridTile.

          backgroundColor: Colors.black87,
          leading: IconButton(
            //* GridTileBar => leading => Um widget para ser exibido antes do título.

            onPressed: () {
              product.toggleFavorite();
            },
            icon: Icon(
              product.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          title: Text(product.name, textAlign: TextAlign.center),
          trailing: IconButton(
            //* GridTileBar => trailing => Um widget para ser exibido após o título.

            onPressed: () {
              cart.addItem(product);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Produto adicionado com sucess.'),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'Desfazer',
                  onPressed: () {
                    cart.removeSingleItem(product.id);
                  },
                ),
              ));
            },
            icon: Icon(
              Icons.shopping_cart,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
