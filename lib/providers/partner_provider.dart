import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../utils/product_rating_helper.dart';

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
    rating: 0.0, // Рейтинг будет загружен из БД
    ratingCount: 0,
  );
}

class PartnerProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isPartnerMode = false;
  double _balance = 0;
  String _shopName = 'Мой магазин';
  String _shopDescription = 'Описание вашего магазина';
  String? _partnerId;

  final List<PartnerProduct> _products = [];

  PartnerProvider() {
    initializePartner();
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        initializePartner();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _partnerId = null;
        _products.clear();
        _transactions.clear();
        _balance = 0;
        _isPartnerMode = false;
        notifyListeners();
      }
    });
  }

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
    _transactions.add(
      PartnerTransaction(
        type: TransactionType.productAdded,
        description: 'Добавлен товар: ${product.name}',
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void updateProduct(
    String id, {
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
    _transactions.add(
      PartnerTransaction(
        type: TransactionType.productRemoved,
        description: 'Удалён товар: ${product.name}',
        timestamp: DateTime.now(),
      ),
    );
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
      _transactions.add(
        PartnerTransaction(
          type: TransactionType.sale,
          description: 'Продажа: ${_products[index].name} x$q',
          amount: _products[index].price * q,
          timestamp: DateTime.now(),
        ),
      );
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
        _transactions.add(
          PartnerTransaction(
            type: TransactionType.sale,
            description: 'Продажа: ${product.name} x$qty',
            amount: product.price * qty,
            timestamp: DateTime.now(),
          ),
        );
      }
    }
    notifyListeners();
  }

  /// Инициализация партнера (загрузка данных из Supabase)
  Future<void> initializePartner() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _partnerId = user.id;

    try {
      // Загрузка информации о магазине
      await _loadShopInfo();
      // Загрузка товаров
      await _loadProducts();
      // Загрузка продаж
      await _loadSales();
    } catch (e) {
      debugPrint('Error initializing partner: $e');
    }
  }

  /// Загрузка информации о магазине из Supabase
  Future<void> _loadShopInfo() async {
    if (_partnerId == null) return;

    try {
      final data = await _supabase
          .from('partner_shops')
          .select()
          .eq('partner_id', _partnerId!)
          .maybeSingle();

      if (data != null) {
        _shopName = data['shop_name'] ?? 'Мой магазин';
        _shopDescription = data['shop_description'] ?? '';
        _balance = (data['balance'] as num?)?.toDouble() ?? 0;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading shop info: $e');
    }
  }

  /// Загрузка товаров из Supabase
  Future<void> _loadProducts() async {
    if (_partnerId == null) return;

    try {
      final data = await _supabase
          .from('partner_products')
          .select()
          .eq('partner_id', _partnerId!)
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(100); // Оптимизация: ограничиваем количество товаров

      _products.clear();
      for (var row in data) {
        _products.add(
          PartnerProduct(
            id: row['id'],
            name: row['name'],
            description: row['description'],
            price: (row['price'] as num).toDouble(),
            category: row['category'],
            imageUrl: row['image_url'],
            stock: row['stock'] ?? 0,
            sold: row['sold'] ?? 0,
            createdAt: DateTime.parse(row['created_at']),
            isActive: row['is_active'] ?? true,
          ),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }

  /// Загрузка истории продаж из Supabase
  Future<void> _loadSales() async {
    if (_partnerId == null) return;

    try {
      final data = await _supabase
          .from('partner_sales')
          .select()
          .eq('partner_id', _partnerId!)
          .order('created_at', ascending: false)
          .limit(100);

      _transactions.clear();
      for (var row in data) {
        _transactions.add(
          PartnerTransaction(
            type: TransactionType.sale,
            description: row['description'],
            amount: (row['amount'] as num).toDouble(),
            timestamp: DateTime.parse(row['created_at']),
          ),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading sales: $e');
    }
  }

  /// Добавить товар и сохранить в Supabase
  Future<void> addProductWithSupabase(PartnerProduct product) async {
    if (_partnerId == null) return;

    try {
      // Добавить в локальный список
      addProduct(product);

      // Сохранить в Supabase
      await _supabase.from('partner_products').insert({
        'id': product.id,
        'partner_id': _partnerId,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'category': product.category,
        'image_url': product.imageUrl,
        'stock': product.stock,
        'sold': product.sold,
        'is_active': product.isActive,
        'created_at': product.createdAt.toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error adding product: $e');
      // Откатить локальное добавление при ошибке
      _products.removeWhere((p) => p.id == product.id);
      notifyListeners();
    }
  }

  /// Обновить товар и синхронизировать с Supabase
  Future<void> updateProductWithSupabase(
    String id, {
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    int? stock,
    bool? isActive,
  }) async {
    if (_partnerId == null) return;

    try {
      // Обновить локально
      updateProduct(
        id,
        name: name,
        description: description,
        price: price,
        category: category,
        imageUrl: imageUrl,
        stock: stock,
        isActive: isActive,
      );

      // Обновить в Supabase
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (price != null) updateData['price'] = price;
      if (category != null) updateData['category'] = category;
      if (imageUrl != null) updateData['image_url'] = imageUrl;
      if (stock != null) updateData['stock'] = stock;
      if (isActive != null) updateData['is_active'] = isActive;

      await _supabase
          .from('partner_products')
          .update(updateData)
          .eq('id', id)
          .eq('partner_id', _partnerId!);
    } catch (e) {
      debugPrint('Error updating product: $e');
    }
  }

  /// Удалить товар и синхронизировать с Supabase
  Future<void> deleteProductWithSupabase(String id) async {
    if (_partnerId == null) return;

    try {
      deleteProduct(id);

      await _supabase
          .from('partner_products')
          .delete()
          .eq('id', id)
          .eq('partner_id', _partnerId!);
    } catch (e) {
      debugPrint('Error deleting product: $e');
    }
  }

  /// Переключить статус активности товара и синхронизировать с Supabase
  Future<void> toggleProductActiveWithSupabase(String id) async {
    if (_partnerId == null) return;

    try {
      toggleProductActive(id);

      final product = _products.firstWhere((p) => p.id == id);
      await _supabase
          .from('partner_products')
          .update({'is_active': product.isActive})
          .eq('id', id)
          .eq('partner_id', _partnerId!);
    } catch (e) {
      debugPrint('Error toggling product active: $e');
    }
  }

  /// Сохранить продажу в Supabase
  Future<void> simulateSaleWithSupabase(String productId, int quantity) async {
    if (_partnerId == null) return;

    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final q = quantity.clamp(0, _products[index].stock);
      final product = _products[index];

      try {
        // Обновить локально
        product.sold += q;
        product.stock -= q;
        _balance += product.price * q;

        final transaction = PartnerTransaction(
          type: TransactionType.sale,
          description: 'Продажа: ${product.name} x$q',
          amount: product.price * q,
          timestamp: DateTime.now(),
        );
        _transactions.add(transaction);

        // Сохранить в Supabase
        await _supabase.from('partner_sales').insert({
          'partner_id': _partnerId,
          'product_id': productId,
          'quantity': q,
          'amount': product.price * q,
          'description': transaction.description,
          'created_at': DateTime.now().toIso8601String(),
        });

        // Обновить stock и sold в таблице products
        await _supabase
            .from('partner_products')
            .update({'stock': product.stock, 'sold': product.sold})
            .eq('id', productId);

        notifyListeners();
      } catch (e) {
        debugPrint('Error recording sale: $e');
        // Откатить изменения при ошибке
        product.sold -= q;
        product.stock += q;
        _balance -= product.price * q;
        _transactions.removeLast();
        notifyListeners();
      }
    }
  }

  /// Обновить информацию о магазине и синхронизировать с Supabase
  Future<void> updateShopInfoWithSupabase({
    String? name,
    String? description,
  }) async {
    if (_partnerId == null) return;

    try {
      updateShopInfo(name: name, description: description);

      // Получить или создать запись о магазине
      final existing = await _supabase
          .from('partner_shops')
          .select()
          .eq('partner_id', _partnerId!)
          .maybeSingle();

      if (existing != null) {
        final updateData = <String, dynamic>{};
        if (name != null) updateData['shop_name'] = name;
        if (description != null) updateData['shop_description'] = description;

        await _supabase
            .from('partner_shops')
            .update(updateData)
            .eq('partner_id', _partnerId!);
      } else {
        await _supabase.from('partner_shops').insert({
          'partner_id': _partnerId,
          'shop_name': name ?? _shopName,
          'shop_description': description ?? _shopDescription,
          'balance': _balance,
        });
      }
    } catch (e) {
      debugPrint('Error updating shop info: $e');
    }
  }

  /// Синхронизировать баланс в Supabase
  Future<void> syncBalance() async {
    if (_partnerId == null) return;

    try {
      await _supabase
          .from('partner_shops')
          .update({'balance': _balance})
          .eq('partner_id', _partnerId!);
    } catch (e) {
      debugPrint('Error syncing balance: $e');
    }
  }

  /// Обновить товары из Supabase (refresh после заказа)
  Future<void> refreshProductsFromSupabase() async {
    if (_partnerId == null) return;

    try {
      await _loadProducts();
      await _loadSales();
      await _loadShopInfo();
    } catch (e) {
      debugPrint('Error refreshing products: $e');
    }
  }

  /// Обновить конкретный товар из Supabase
  Future<void> refreshProductStock(String productId) async {
    if (_partnerId == null) return;

    try {
      final data = await _supabase
          .from('partner_products')
          .select()
          .eq('id', productId)
          .eq('partner_id', _partnerId!)
          .maybeSingle();

      if (data != null) {
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          _products[index] = PartnerProduct(
            id: data['id'],
            name: data['name'],
            description: data['description'],
            price: (data['price'] as num).toDouble(),
            category: data['category'],
            imageUrl: data['image_url'],
            stock: data['stock'] ?? 0,
            sold: data['sold'] ?? 0,
            createdAt: DateTime.parse(data['created_at']),
            isActive: data['is_active'] ?? true,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error refreshing product stock: $e');
    }
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
