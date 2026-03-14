import 'cart_item.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime dateTime;
  final String address;
  final String paymentMethod;
  final String status;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.dateTime,
    required this.address,
    required this.paymentMethod,
    this.status = 'processing',
  });
}
