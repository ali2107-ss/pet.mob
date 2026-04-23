import 'cart_item.dart';
import 'product.dart';

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

  factory Order.fromSupabase(
    Map<String, dynamic> row,
    List<Map<String, dynamic>> itemRows,
    List<Product> allProducts,
  ) {
    final cartItems = itemRows.map((item) {
      final productId = item['product_id'] as String;
      final product = allProducts.firstWhere(
        (p) => p.id == productId,
        orElse: () => Product(
          id: productId,
          name: item['product_name'] ?? 'Товар',
          description: '',
          price: (item['price_at_purchase'] as num?)?.toDouble() ?? 0.0,
          category: '',
          imageUrl: '',
        ),
      );
      return CartItem(
        id: item['id'] ?? productId,
        product: product,
        quantity: item['quantity'] as int? ?? 1,
      );
    }).toList();

    return Order(
      id: row['id'] as String,
      items: cartItems,
      totalAmount: (row['total_amount'] as num).toDouble(),
      dateTime: DateTime.parse(row['created_at'] as String),
      address: row['shipping_address'] ?? '',
      paymentMethod: row['payment_method'] ?? '',
      status: row['status'] ?? 'processing',
    );
  }
}
