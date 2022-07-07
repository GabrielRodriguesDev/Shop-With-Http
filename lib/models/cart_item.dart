class CartItem {
  String id;
  String productId;
  String name;
  int quantity;
  double price;

  CartItem(
      {required this.id,
      required this.productId,
      required this.name,
      required this.quantity,
      required this.price});

  String totalValueText() {
    var result = price * quantity;
    return result.toStringAsFixed(2);
  }
}
