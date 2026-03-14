import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => [..._orders];

  int get orderCount => _orders.length;

  void addOrder(List<CartItem> cartItems, double total, String address, String paymentMethod) {
    _orders.insert(
      0,
      Order(
        id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        items: cartItems,
        totalAmount: total,
        dateTime: DateTime.now(),
        address: address,
        paymentMethod: paymentMethod,
        status: 'processing',
      ),
    );
    notifyListeners();
  }
}
