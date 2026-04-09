import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final List<Order> _orders = [];

  List<Order> get orders => [..._orders];

  int get orderCount => _orders.length;

  OrderProvider() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        _orders.clear();
      }
    });
  }

  /// Загрузить заказы из Supabase
  Future<void> fetchOrders() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _supabase
          .from('orders')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      _orders.clear();
      for (var row in data) {
        // Загружаем items для каждого заказа
        final items = await _supabase
            .from('order_items')
            .select()
            .eq('order_id', row['id']);

        final cartItems = <CartItem>[];
        for (var item in items) {
          // Здесь нужно получить Product по product_id
          // Для упрощения используем mock
          cartItems.add(
            CartItem(
              id: item['id'],
              product: null, // Будет заполнено после загрузки товаров
              quantity: item['quantity'],
            ),
          );
        }

        _orders.add(
          Order(
            id: row['id'],
            items: cartItems,
            totalAmount: (row['total_amount'] as num).toDouble(),
            dateTime: DateTime.parse(row['created_at']),
            address: 'Address', // Можно добавить в таблицу
            paymentMethod: 'Supabase', // Можно добавить в таблицу
            status: row['status'],
          ),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    }
  }

  /// Добавить заказ (локально и в Supabase)
  Future<void> addOrder(
    List<CartItem> cartItems,
    double total,
    String address,
    String paymentMethod,
  ) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Сначала проверяем наличие товаров на складе
      for (var item in cartItems) {
        if (item.product == null) continue;
        final available = await checkStockAvailability(
          item.product!.id,
          item.quantity,
        );
        if (!available) {
          throw Exception(
            'Недостаточно товара на складе: ${item.product!.name}',
          );
        }
      }

      // Создаём заказ в Supabase (БД сама генерирует UUID)
      final orderResponse = await _supabase
          .from('orders')
          .insert({
            'user_id': user.id,
            'total_amount': total,
            'status': 'processing',
          })
          .select('id')
          .single();

      final orderId = orderResponse['id'] as String;

      // Добавляем positions в order_items
      for (var item in cartItems) {
        if (item.product == null) continue;
        final productCheck = await _supabase
            .from('partner_products')
            .select('stock, partner_id')
            .eq('id', item.product!.id)
            .maybeSingle();

        if (productCheck != null && productCheck['stock'] >= item.quantity) {
          // Добавляем item в заказ
          await _supabase.from('order_items').insert({
            'order_id': orderId,
            'product_id': item.product!.id,
            'partner_id': productCheck['partner_id'],
            'quantity': item.quantity,
            'price': item.product!.price,
            'total': item.product!.price * item.quantity,
          });

          // Добавляем запись в partner_sales для партнерского статистики
          await _supabase.from('partner_sales').insert({
            'partner_id': productCheck['partner_id'],
            'product_id': item.product!.id,
            'quantity': item.quantity,
            'amount': item.product!.price * item.quantity,
            'description': 'Заказ: ${item.product!.name} x${item.quantity}',
          });
        }
      }

      // Добавляем локально
      _orders.insert(
        0,
        Order(
          id: orderId,
          items: cartItems,
          totalAmount: total,
          dateTime: DateTime.now(),
          address: address,
          paymentMethod: paymentMethod,
          status: 'processing',
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding order: $e');
      rethrow;
    }
  }

  /// Проверить наличие товара на складе
  Future<bool> checkStockAvailability(String productId, int quantity) async {
    try {
      final data = await _supabase
          .from('partner_products')
          .select('stock')
          .eq('id', productId)
          .maybeSingle();

      if (data == null) return false;
      return (data['stock'] as int) >= quantity;
    } catch (e) {
      debugPrint('Error checking stock: $e');
      return false;
    }
  }
}
