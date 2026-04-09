import 'product.dart';

class CartItem {
  final String id;
  final Product? product;
  int quantity;

  CartItem({required this.id, this.product, this.quantity = 1});
}
