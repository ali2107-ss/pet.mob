import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class OrderProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final List<Order> _orders = [];

  List<Order> get orders => [..._orders];

  int get orderCount => _orders.length;

  OrderProvider() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        _orders.clear();
        notifyListeners();
      }
    });
  }

  /// Загрузить заказы из Supabase (нужен список товаров для сопоставления)
  Future<void> fetchOrders(List<Product> allProducts) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _supabase
          .from('orders')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      _orders.clear();

      for (final row in data) {
        // Загружаем позиции заказа
        final List<dynamic> itemsRaw = await _supabase
            .from('order_items')
            .select()
            .eq('order_id', row['id'] as String);

        final itemRows = itemsRaw.cast<Map<String, dynamic>>();

        _orders.add(
          Order.fromSupabase(row, itemRows, allProducts),
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('OrderProvider: Error fetching orders: $e');
    }
  }

  /// Создать новый заказ в Supabase
  Future<void> addOrder(
    List<CartItem> cartItems,
    double total,
    String address,
    String paymentMethod,
  ) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Проверяем наличие партнёрских товаров на складе
      for (final item in cartItems) {
        if (item.product == null) continue;
        final available = await checkStockAvailability(
          item.product!.id,
          item.quantity,
        );
        if (!available) {
          throw Exception('Недостаточно товара на складе: ${item.product!.name}');
        }
      }

      // Создаём запись заказа
      final orderResponse = await _supabase
          .from('orders')
          .insert({
            'user_id': user.id,
            'total_amount': total,
            'status': 'processing',
            'shipping_address': address,
            'payment_method': paymentMethod,
          })
          .select('id')
          .single();

      final orderId = orderResponse['id'] as String;

      // Добавляем позиции в order_items
      for (final item in cartItems) {
        if (item.product == null) continue;

        await _supabase.from('order_items').insert({
          'order_id': orderId,
          'product_id': item.product!.id,
          'quantity': item.quantity,
          'price_at_purchase': item.product!.price,
          'product_name': item.product!.name,
        });

        // Обновляем партнёрскую статистику (если применимо)
        try {
          final partnerProduct = await _supabase
              .from('partner_products')
              .select('stock, partner_id')
              .eq('id', item.product!.id)
              .maybeSingle();

          if (partnerProduct != null) {
            await _supabase.from('partner_sales').insert({
              'partner_id': partnerProduct['partner_id'],
              'product_id': item.product!.id,
              'quantity': item.quantity,
              'amount': item.product!.price * item.quantity,
              'description': 'Заказ: ${item.product!.name} x${item.quantity}',
            });
          }
        } catch (_) {
          // Не партнёрский товар — пропускаем без ошибки
        }
      }

      // Добавляем в локальный список
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
      debugPrint('OrderProvider: Error adding order: $e');
      rethrow;
    }
  }

  /// Проверить наличие партнёрского товара на складе
  Future<bool> checkStockAvailability(String productId, int quantity) async {
    try {
      final data = await _supabase
          .from('partner_products')
          .select('stock')
          .eq('id', productId)
          .maybeSingle();

      // Если товара нет в partner_products — это обычный товар (неограниченный склад)
      if (data == null) return true;
      return (data['stock'] as int) >= quantity;
    } catch (_) {
      return true; // Ошибка UUID или сети — разрешаем покупку
    }
  }
}
