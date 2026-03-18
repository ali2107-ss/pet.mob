import 'package:flutter/foundation.dart';
import '../models/product.dart';

class PartnerProduct {
  final String id;
  String name;
  String description;
  double price;
  String category;
  String imageUrl;
  int stock;
  int sold;
  final DateTime createdAt;
  bool isActive;

  PartnerProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.stock = 0,
    this.sold = 0,
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

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
  String _shopName = 'Мой магазин';
  String _shopDescription = 'Описание вашего магазина';

  final List<PartnerProduct> _products = [];

  // История операций
  final List<PartnerTransaction> _transactions = [];

  bool get isPartnerMode => _isPartnerMode;
  double get balance => _balance;
  String get shopName => _shopName;
  String get shopDescription => _shopDescription;
  List<PartnerProduct> get products => [..._products];
  List<PartnerTransaction> get transactions => [..._transactions];

  int get totalSold => _products.fold(0, (sum, p) => sum + p.sold);
  int get totalStock => _products.fold(0, (sum, p) => sum + p.stock);
  double get totalRevenue => _products.fold(0.0, (sum, p) => sum + p.revenue);
  int get activeProducts => _products.where((p) => p.isActive).length;

  void enterPartnerMode() {
    _isPartnerMode = true;
    notifyListeners();
  }

  void exitPartnerMode() {
    _isPartnerMode = false;
    notifyListeners();
  }

  void togglePartnerMode() {
    _isPartnerMode = !_isPartnerMode;
    notifyListeners();
  }

  void updateShopInfo({String? name, String? description}) {
    if (name != null) _shopName = name;
    if (description != null) _shopDescription = description;
    notifyListeners();
  }

  void addProduct(PartnerProduct product) {
    _products.add(product);
    _transactions.add(PartnerTransaction(
      type: TransactionType.productAdded,
      description: 'Добавлен товар: ${product.name}',
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void updateProduct(String id, {
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    int? stock,
    bool? isActive,
  }) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      final p = _products[index];
      if (name != null) p.name = name;
      if (description != null) p.description = description;
      if (price != null) p.price = price;
      if (category != null) p.category = category;
      if (imageUrl != null) p.imageUrl = imageUrl;
      if (stock != null) p.stock = stock;
      if (isActive != null) p.isActive = isActive;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    final product = _products.firstWhere((p) => p.id == id);
    _transactions.add(PartnerTransaction(
      type: TransactionType.productRemoved,
      description: 'Удалён товар: ${product.name}',
      timestamp: DateTime.now(),
    ));
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void toggleProductActive(String id) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index].isActive = !_products[index].isActive;
      notifyListeners();
    }
  }

  // Симуляция продажи
  void simulateSale(String productId, int quantity) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final q = quantity.clamp(0, _products[index].stock);
      _products[index].sold += q;
      _products[index].stock -= q;
      _balance += _products[index].price * q;
      _transactions.add(PartnerTransaction(
        type: TransactionType.sale,
        description: 'Продажа: ${_products[index].name} x$q',
        amount: _products[index].price * q,
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  // Симуляция случайных продаж для демо
  void simulateRandomSales() {
    if (_products.isEmpty) return;
    for (final product in _products) {
      if (product.stock > 0) {
        final qty = (product.stock * 0.3).ceil().clamp(1, 5);
        product.sold += qty;
        product.stock -= qty;
        _balance += product.price * qty;
        _transactions.add(PartnerTransaction(
          type: TransactionType.sale,
          description: 'Продажа: ${product.name} x$qty',
          amount: product.price * qty,
          timestamp: DateTime.now(),
        ));
      }
    }
    notifyListeners();
  }
}

enum TransactionType { sale, productAdded, productRemoved, withdrawal }

class PartnerTransaction {
  final TransactionType type;
  final String description;
  final double amount;
  final DateTime timestamp;

  PartnerTransaction({
    required this.type,
    required this.description,
    this.amount = 0,
    required this.timestamp,
  });

  String get typeLabel {
    switch (type) {
      case TransactionType.sale:
        return '💰 Продажа';
      case TransactionType.productAdded:
        return '📦 Товар добавлен';
      case TransactionType.productRemoved:
        return '🗑️ Товар удалён';
      case TransactionType.withdrawal:
        return '💳 Вывод средств';
    }
  }
}
