// ignore_for_file: avoid_print, prefer_collection_literals, no_leading_underscores_for_local_identifiers

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';

import '../models/product_list.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({Key? key}) : super(key: key);

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _priceFocus = FocusNode(); //! Criando referencia de foco.
  final _descriptionFocus = FocusNode();
  final _imageUrlFocus = FocusNode();
  final _imageUrlController =
      TextEditingController(); //! Criando a controler para ter acesso ao campo antes de submeter o form

  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();

  bool isValidImageUrl(String url) {
    bool isValidUrl = Uri.tryParse(url)?.hasAbsolutePath ?? false;
    bool endsWithFile = url.toLowerCase().endsWith('.png') ||
        url.endsWith('jpg') ||
        url.endsWith('jpeg');
    return isValidUrl && endsWithFile;
  }

  @override
  void initState() {
    super.initState();
    _imageUrlFocus.addListener(
        updateImage); //!Registrando um ouivinte ao focu do campo -> Quando eu selecionar ou tirar o foco será chamado uma função updateImage
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_formData.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg != null) {
        final product = arg as Product;
        _formData['id'] = product.id;
        _formData['name'] = product.name;
        _formData['price'] = product.price;
        _formData['description'] = product.description;
        _formData['imageUrl'] = product.imageUrl;
        _imageUrlController.text = product.imageUrl;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _priceFocus.dispose();
    _descriptionFocus.dispose();
    _imageUrlFocus.dispose();
    _imageUrlFocus.removeListener(
        updateImage); //! Ao remover listener do campo chamar  a função.
  }

  void updateImage() {
    setState(() {});
  }

  void _submitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    _formKey.currentState?.save();

    Provider.of<ProductList>(context, listen: false).saveProduct(_formData);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulário de Produto'),
        actions: [
          IconButton(onPressed: _submitForm, icon: const Icon(Icons.save))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _formData['name'] as String,
                decoration: const InputDecoration(labelText: 'Nome'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(
                      _priceFocus); //! Setando o focu ao submeter o campo
                },
                validator: (name) {
                  final _name = name ?? '';

                  if (_name.trim().isEmpty) {
                    return 'Nome é obrigatório.';
                  }

                  if (_name.trim().length < 3) {
                    return 'Nome precisa de no mínimo 3 letras.';
                  }
                },
                onSaved: (name) => _formData['name'] = name ?? '',
              ),
              TextFormField(
                  initialValue: _formData['price']?.toString(),
                  decoration: const InputDecoration(labelText: 'Preço'),
                  textInputAction: TextInputAction.next,
                  focusNode:
                      _priceFocus, //! Vinculando essa referencia de focu a esse Widget
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_descriptionFocus);
                  },
                  validator: (price) {
                    final _price = price ?? '';
                    if (_price.trim().isEmpty) {
                      return 'Preço é obrigatório.';
                    }
                  },
                  onSaved: (price) =>
                      _formData['price'] = double.parse(price ?? '0')),
              TextFormField(
                initialValue: _formData['description']?.toString(),
                decoration: const InputDecoration(labelText: 'Descrição'),
                focusNode: _descriptionFocus,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                validator: (description) {
                  final _description = description ?? '';

                  if (_description.trim().isEmpty) {
                    return 'Descrição é obrigatória.';
                  }

                  if (_description.trim().length < 10) {
                    return 'Descriçãp precisa de no mínimo 10 letras.';
                  }
                },
                onSaved: (description) =>
                    _formData['description'] = description ?? '',
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Url da Imagem'),
                      focusNode: _imageUrlFocus,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.url,
                      controller: _imageUrlController,
                      onFieldSubmitted: (_) => _submitForm(),
                      validator: (imageUrl) {
                        final _imageUrl = imageUrl ?? '';
                        if (!isValidImageUrl(_imageUrl)) {
                          return 'Informe uma url válida.';
                        }
                      },
                      onSaved: (imageUrl) =>
                          _formData['imageUrl'] = imageUrl ?? '',
                    ),
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    margin: const EdgeInsets.only(top: 10, left: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: SizedBox.expand(
                      child: _imageUrlController.text.isEmpty
                          ? const Center(
                              child: Text(
                                'Informe a Url',
                                textAlign: TextAlign.center,
                              ),
                            )
                          : FittedBox(
                              child: Image.network(
                                _imageUrlController.text,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
