import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final List<Product> _items = [
    Product(
      id: 'p1',
      name: 'Purina Pro Plan Қазақстан',
      description: 'Сухой корм для взрослых котов с лососем. Богатый витаминами и минералами, поддерживает иммунную систему и здоровье шерсти.',
      price: 7200,
      category: 'Тамақ',
      imageUrl: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?auto=format&fit=crop&w=500&q=60',
      rating: 4.8,
    ),
    Product(
      id: 'p2',
      name: 'Когтеточка с игрушкой',
      description: 'Отличная когтеточка, которая спасет вашу мебель. Встроенная игрушка-мышка привлечет внимание вашего питомца на долгое время.',
      price: 11500,
      category: 'Ойыншықтар',
      imageUrl: 'https://images.unsplash.com/photo-1545249390-6bdfa286032f?auto=format&fit=crop&w=500&q=60',
      rating: 4.5,
    ),
    Product(
      id: 'p3',
      name: 'Ошейник кожаный',
      description: 'Прочный кожаный ошейник для собак средних пород. Длина регулируется, надежная застежка.',
      price: 5400,
      category: 'Аксессуарлар',
      imageUrl: 'https://images.unsplash.com/photo-1605386762369-026c9217a61d?auto=format&fit=crop&w=500&q=60',
      rating: 4.2,
    ),
    Product(
      id: 'p4',
      name: 'Royal Canin Maxi',
      description: 'Корм для собак крупных пород. Укрепляет суставы и поддерживает оптимальный вес животного.',
      price: 20700,
      category: 'Тамақ',
      imageUrl: 'https://images.unsplash.com/photo-1589924691995-400dc9ceac12?auto=format&fit=crop&w=500&q=60',
      rating: 4.9,
    ),
    Product(
      id: 'p5',
      name: 'Мячик для собак',
      description: 'Неубиваемый мячик с пищалкой для веселых игр. Подходит для активных собак мелких и средних пород.',
      price: 2700,
      category: 'Ойыншықтар',
      imageUrl: 'https://images.unsplash.com/photo-1581467655410-0c2bf55d9d6c?auto=format&fit=crop&w=500&q=60',
      rating: 4.6,
    ),
    Product(
      id: 'p6',
      name: 'Қазақша ойыншық - Құйрықты мысық',
      description: 'Традиционная казахская игрушка для кошек. Изготовлена из натуральных материалов, безопасна для животных.',
      price: 3500,
      category: 'Ойыншықтар',
      imageUrl: 'https://images.unsplash.com/photo-1544568100-847a948585b9?auto=format&fit=crop&w=500&q=60',
      rating: 4.7,
    ),
    Product(
      id: 'p7',
      name: 'Шампунь для длинношерстных',
      description: 'Мягкий шампунь, который облегчает расчесывание и придает блеск шерсти вашего питомца.',
      price: 4200,
      category: 'Гигиена',
      imageUrl: 'https://images.unsplash.com/photo-1583900985737-6d0480838965?auto=format&fit=crop&w=500&q=60',
      rating: 4.4,
    ),
    Product(
      id: 'p8',
      name: 'Лоток закрытый',
      description: 'Закрытый лоток с угольным фильтром для кошек. Защищает от неприятных запахов и разбрасывания наполнителя.',
      price: 18500,
      category: 'Гигиена',
      imageUrl: 'https://images.unsplash.com/photo-1616782298284-754687e1f40d?auto=format&fit=crop&w=500&q=60',
      rating: 4.8,
    ),
    Product(
      id: 'p9',
      name: 'Дождевик для собак',
      description: 'Водонепроницаемый дождевик со светоотражающими элементами для безопасных прогулок в непогоду.',
      price: 8900,
      category: 'Киімдер',
      imageUrl: 'https://images.unsplash.com/photo-1574513197486-da5e510b64be?auto=format&fit=crop&w=500&q=60',
      rating: 4.6,
    ),
    Product(
      id: 'p10',
      name: 'Свитер вязаный',
      description: 'Теплый и уютный свитер для кошек и мелких собак. Идеально для прохладной погоды.',
      price: 6500,
      category: 'Киімдер',
      imageUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=500&q=60',
      rating: 4.3,
    ),
  ];

  List<Product> get items => [..._items];

  List<Product> getProductsByCategory(String category) {
    if (category == 'Барлығы') return items;
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
