import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import 'partner_provider.dart';
import '../utils/product_rating_helper.dart';

class ProductProvider with ChangeNotifier {
  PartnerProvider? _partnerProvider;
  List<Product> _items = [];
  bool _isLoading = false;
  String? _error;

  void setPartnerProvider(PartnerProvider partnerProvider) {
    _partnerProvider = partnerProvider;
  }

  List<Product> get items {
    final List<Product> mainProducts = [..._items];
    if (_partnerProvider != null) {
      mainProducts.addAll(_partnerProvider!.products.map((p) => p.toProduct()));
    }
    return mainProducts;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client
          .from('products')
          .select()
          .order('name', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      _items = data.map((json) => Product.fromMap(json)).toList();

      print('Loaded ${_items.length} products from Supabase');
    } catch (e) {
      _error = e.toString();
      print('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProductRatingLocal(String productId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final response = await Supabase.instance.client
          .from('product_ratings')
          .select('rating')
          .eq('product_id', productId);

      final List<dynamic> ratings = response as List<dynamic>;
      final double? averageRating = ratings.isEmpty
          ? null
          : ratings
                  .map((row) => (row['rating'] as num).toDouble())
                  .reduce((a, b) => a + b) /
              ratings.length;

      final index = _items.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final old = _items[index];
        _items[index] = Product(
          id: old.id,
          name: old.name,
          description: old.description,
          price: old.price,
          category: old.category,
          imageUrl: old.imageUrl,
          rating: ProductRatingHelper.resolveInitialRating(
            productId: old.id,
            productName: old.name,
            currentRating: averageRating,
          ),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('ProductProvider: Error updating product rating: $e');
    }
  }

  Product findById(String id) {
    return items.firstWhere((prod) => prod.id == id);
  }

  List<Product> getProductsByCategory(String categoryName) {
    if (categoryName == 'Р’СЃРµ' || categoryName == 'Р‘Р°СЂР»С‹Т“С‹') {
      return items;
    }
    return items.where((prod) => prod.category == categoryName).toList();
  }

  List<Product> search(String query) {
    if (query.isEmpty) {
      return items;
    }
    return items.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase()) ||
          product.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<Product> filterProducts({
    List<String>? categories,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) {
    List<Product> filtered = items;

    if (categories != null && categories.isNotEmpty) {
      filtered = filtered.where((p) => categories.contains(p.category)).toList();
    }

    if (minPrice != null) {
      filtered = filtered.where((p) => p.price >= minPrice).toList();
    }

    if (maxPrice != null) {
      filtered = filtered.where((p) => p.price <= maxPrice).toList();
    }

    if (sortBy != null) {
      switch (sortBy) {
        case 'price_asc':
          filtered.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_desc':
          filtered.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'rating':
          filtered.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'newest':
          break;
      }
    }

    return filtered;
  }
}
