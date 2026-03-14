import 'package:flutter/foundation.dart';
import '../models/product.dart';

class PartnerProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  int stock;
  int sold;

  PartnerProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.stock = 0,
    this.sold = 0,
  });

  double get revenue => sold * price;

  Product toProduct() => Product(
        id: id,
        name: name,
        description: description,
        price: price,
        category: category,
        imageUrl: imageUrl,
        rating: 0.0,
      );
}

class PartnerProvider with ChangeNotifier {
  bool _isPartnerMode = false;
  double _balance = 0;

  final List<PartnerProduct> _products = [];

  bool get isPartnerMode => _isPartnerMode;
  double get balance => _balance;
  List<PartnerProduct> get products => [..._products];

  int get totalSold => _products.fold(0, (sum, p) => sum + p.sold);
  int get totalStock => _products.fold(0, (sum, p) => sum + p.stock);
  double get totalRevenue => _products.fold(0.0, (sum, p) => sum + p.revenue);

  void togglePartnerMode() {
    _isPartnerMode = !_isPartnerMode;
    notifyListeners();
  }

  void addProduct(PartnerProduct product) {
    _products.add(product);
    notifyListeners();
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // Симуляция продажи — вызывается когда клиент оформляет заказ
  void simulateSale(String productId, int quantity) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final q = quantity.clamp(0, _products[index].stock);
      _products[index].sold += q;
      _products[index].stock -= q;
      _balance += _products[index].price * q;
      notifyListeners();
    }
  }
}
