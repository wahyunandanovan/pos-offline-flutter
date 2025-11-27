import '../../product/models/product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;
  double discount;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.discount = 0,
  });

  double get price => product.sellPrice;
  double get subtotal => (price * quantity) - discount;
}
