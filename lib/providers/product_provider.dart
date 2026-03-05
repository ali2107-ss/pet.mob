import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final List<Product> _items = [
    Product(
      id: 'p1',
      name: 'Purina Pro Plan',
      description: 'Сухой корм для взрослых котов с лососем. Богатый витаминами и минералами, поддерживает иммунную систему и здоровье шерсти.',
      price: 15.99,
      category: 'Корм',
      imageUrl: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      rating: 4.8,
    ),
    Product(
      id: 'p2',
      name: 'Когтеточка с игрушкой',
      description: 'Отличная когтеточка, которая спасет вашу мебель. Встроенная игрушка-мышка привлечет внимание вашего питомца на долгое время.',
      price: 25.50,
      category: 'Игрушки',
      imageUrl: 'https://images.unsplash.com/photo-1545249390-6bdfa286032f?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      rating: 4.5,
    ),
    Product(
      id: 'p3',
      name: 'Ошейник кожаный',
      description: 'Прочный кожаный ошейник для собак средних пород. Длина регулируется, надежная застежка.',
      price: 12.00,
      category: 'Аксессуары',
      imageUrl: 'https://images.unsplash.com/photo-1605386762369-026c9217a61d?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      rating: 4.2,
    ),
    Product(
      id: 'p4',
      name: 'Royal Canin Maxi',
      description: 'Корм для собак крупных пород. Укрепляет суставы и поддерживает оптимальный вес животного.',
      price: 45.99,
      category: 'Корм',
      imageUrl: 'https://plus.unsplash.com/premium_photo-1664300900349-afb72225dc26?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      rating: 4.9,
    ),
    Product(
      id: 'p5',
      name: 'Мячик для собак',
      description: 'Неубиваемый мячик с пищалкой для веселых игр. Подходит для активных собак мелких и средних пород.',
      price: 5.99,
      category: 'Игрушки',
      imageUrl: 'https://images.unsplash.com/photo-1581467655410-0c2bf55d9d6c?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      rating: 4.6,
    ),
  ];

  List<Product> get items => [..._items];

  List<Product> getProductsByCategory(String category) {
    if (category == 'Все') return items;
    return _items.where((prod) => prod.category == category).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  List<Product> search(String query) {
    if (query.isEmpty) return items;
    return _items.where((prod) => prod.name.toLowerCase().contains(query.toLowerCase())).toList();
  }
}
