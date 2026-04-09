import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<String, CartItem> _items = {};

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
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  /// Загрузка корзины из Supabase
  Future<void> fetchCart(List<Product> allProducts) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _supabase
          .from('cart_items')
          .select()
          .eq('user_id', user.id);

      _items.clear();
      for (var row in data) {
        final productId = row['product_id'] as String;
        final quantity = row['quantity'] as int;
        final product = allProducts.firstWhere(
          (p) => p.id == productId,
          orElse: () => Product(id: productId, name: 'Unknown', description: '', price: 0, category: '', imageUrl: ''),
        );
        if (product.name != 'Unknown') {
          _items[productId] = CartItem(
            id: productId,
            product: product,
            quantity: quantity,
          );
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching cart: $e');
    }
  }

  Future<void> addItem(Product product) async {
    final user = _supabase.auth.currentUser;
    
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existing) => CartItem(
          id: existing.id,
          product: existing.product,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          id: DateTime.now().toString(),
          product: product,
        ),
      );
    }

    if (user != null) {
      await _supabase.from('cart_items').upsert({
        'user_id': user.id,
        'product_id': product.id,
        'quantity': _items[product.id]!.quantity,
      });
    }

    notifyListeners();
  }

  Future<void> removeItem(String productId) async {
    final user = _supabase.auth.currentUser;
    _items.remove(productId);
    
    if (user != null) {
      await _supabase
          .from('cart_items')
          .delete()
          .match({'user_id': user.id, 'product_id': productId});
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
        await _supabase.from('cart_items').update({
          'quantity': _items[productId]!.quantity,
        }).match({'user_id': user.id, 'product_id': productId});
      }
    } else {
      _items.remove(productId);
      if (user != null) {
        await _supabase
            .from('cart_items')
            .delete()
            .match({'user_id': user.id, 'product_id': productId});
      }
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
