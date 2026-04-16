import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class FavoriteProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<String, Product> _items = {};

  Map<String, Product> get items => {..._items};

  FavoriteProvider() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        clear();
      }
    });
  }

  bool isFavorite(String id) {
    return _items.containsKey(id);
  }
  bool _isFetching = false;

  /// Загрузка избранного из Supabase
  Future<void> fetchFavorites(List<Product> allProducts) async {
    if (_isFetching) return;
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _isFetching = true;
    try {
      debugPrint('FavoriteProvider: Fetching favorites for ${user.id}');
      final data = await _supabase
          .from('favorites')
          .select('product_id')
          .eq('user_id', user.id);

      final Map<String, Product> newItems = {};
      for (var row in data) {
        final productId = row['product_id'] as String;
        final product = allProducts.firstWhere(
          (p) => p.id == productId,
          orElse: () => Product(id: productId, name: 'Unknown', description: '', price: 0, category: '', imageUrl: ''),
        );
        if (product.name != 'Unknown') {
          newItems[productId] = product;
        }
      }
      
      _items.clear();
      _items.addAll(newItems);
      debugPrint('FavoriteProvider: Loaded ${_items.length} favorites');
      notifyListeners();
    } catch (e) {
      debugPrint('FavoriteProvider: Error fetching favorites: $e');
    } finally {
      _isFetching = false;
    }
  }

  Future<void> toggleFavorite(Product product) async {
    final user = _supabase.auth.currentUser;
    final productId = product.id;

    if (_items.containsKey(productId)) {
      _items.remove(productId);
      if (user != null) {
        await _supabase
            .from('favorites')
            .delete()
            .match({'user_id': user.id, 'product_id': productId});
      }
    } else {
      _items[productId] = product;
      if (user != null) {
        await _supabase.from('favorites').insert({
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
