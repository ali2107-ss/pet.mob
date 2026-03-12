import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FavoriteProvider with ChangeNotifier {
  final Map<String, Product> _items = {};

  Map<String, Product> get items => {..._items};

  bool isFavorite(String id) {
    return _items.containsKey(id);
  }

  void toggleFavorite(Product product) {
    if (_items.containsKey(product.id)) {
      _items.remove(product.id);
    } else {
      _items.putIfAbsent(product.id, () => product);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
