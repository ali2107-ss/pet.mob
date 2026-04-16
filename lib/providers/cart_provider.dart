import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<String, CartItem> _items = {};
  bool _isFetching = false;
  bool _hasFetched = false;

  Map<String, CartItem> get items => {..._items};

  CartProvider() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        clear();
      }
    });
  }

  int get itemCount => _items.length;

  int get totalItemsCount {
    int count = 0;
    _items.forEach((key, cartItem) {
      count += cartItem.quantity;
    });
    return count;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      if (cartItem.product != null) {
        total += cartItem.product!.price * cartItem.quantity;
      }
    });
    return total;
  }

  Future<void> fetchCart(List<Product> allProducts) async {
    if (_isFetching) return;
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint('CartProvider: fetchCart skipped, no user');
      return;
    }

    _isFetching = true;
    try {
      debugPrint('CartProvider: Fetching cart from Supabase for user ${user.id}');
      final data = await _supabase
          .from('cart_items')
          .select()
          .eq('user_id', user.id);

      final Map<String, CartItem> newItems = {};
      for (var row in data) {
        final productId = row['product_id'] as String;
        final quantity = row['quantity'] as int;
        
        final product = allProducts.firstWhere(
          (p) => p.id == productId,
          orElse: () => Product(
            id: productId,
            name: 'Unknown',
            description: '',
            price: 0,
            category: '',
            imageUrl: '',
          ),
        );

        if (product.name != 'Unknown') {
          newItems[productId] = CartItem(
            id: productId,
            product: product,
            quantity: quantity,
          );
        }
      }
      
      _items.clear();
      _items.addAll(newItems);
      _hasFetched = true;
      debugPrint('CartProvider: fetchCart successful, loaded ${_items.length} items');
      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider: Error fetching cart: $e');
    } finally {
      _isFetching = false;
    }
  }

  Future<void> addItem(Product product) async {
    final user = _supabase.auth.currentUser;

    // Проверяем наличие товара на складе
    try {
      final stockData = await _supabase
          .from('partner_products')
          .select('stock')
          .eq('id', product.id)
          .maybeSingle();

      if (stockData != null) {
        final availableStock = stockData['stock'] as int;
        final currentQuantity = _items.containsKey(product.id)
            ? _items[product.id]!.quantity
            : 0;

        if (availableStock <= currentQuantity) {
          debugPrint('Error: Not enough stock for product ${product.id}.');
          throw Exception('Недостаточно товара на складе');
        }
      }
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('Недостаточно')) {
        rethrow; // Пробрасываем ошибку о нехватке на склад
      }
      // Если таблицы нет или сетевая ошибка - пропускаем
      debugPrint('Stock check skipped: $e');
    }

    if (_items.containsKey(product.id)) {
      debugPrint('CartProvider: Incrementing quantity for ${product.id}');
      _items.update(
        product.id,
        (existing) => CartItem(
          id: existing.id,
          product: existing.product,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      debugPrint('CartProvider: Adding new product to cart ${product.id}');
      _items.putIfAbsent(
        product.id,
        () => CartItem(id: DateTime.now().toString(), product: product),
      );
    }

    if (user != null) {
      debugPrint('CartProvider: Syncing with Supabase for user ${user.id}');
      try {
        await _supabase.from('cart_items').upsert({
          'user_id': user.id,
          'product_id': product.id,
          'quantity': _items[product.id]!.quantity,
        });
        debugPrint('CartProvider: Sync successful');
      } catch (e) {
        debugPrint('CartProvider: Failed to sync with Supabase: $e');
      }
    } else {
      debugPrint('CartProvider: User not logged in, local only');
    }

    notifyListeners();
  }

  Future<void> removeItem(String productId) async {
    final user = _supabase.auth.currentUser;
    _items.remove(productId);

    if (user != null) {
      await _supabase.from('cart_items').delete().match({
        'user_id': user.id,
        'product_id': productId,
      });
    }

    notifyListeners();
  }

  Future<void> removeSingleItem(String productId) async {
    if (!_items.containsKey(productId)) return;
    final user = _supabase.auth.currentUser;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
          id: existing.id,
          product: existing.product,
          quantity: existing.quantity - 1,
        ),
      );
      if (user != null) {
        await _supabase
            .from('cart_items')
            .update({'quantity': _items[productId]!.quantity})
            .match({'user_id': user.id, 'product_id': productId});
      }
    } else {
      _items.remove(productId);
      if (user != null) {
        await _supabase.from('cart_items').delete().match({
          'user_id': user.id,
          'product_id': productId,
        });
      }
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
