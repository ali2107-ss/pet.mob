# Структура товаров из коммита 83ee1bb^ (перед миграцией)

## Общая структура файла lib/providers/product_provider.dart

### Начало файла (импорты):
```dart
import 'package:flutter/foundation.dart';
import '../models/product.dart';
```

### Структура класса ProductProvider:
```dart
class ProductProvider extends ChangeNotifier {
  // Приватное поле со списком жестко закодированных товаров
  final List<Product> _items = [
    // ~76 товаров ниже...
  ];
  
  // Методы для работы с локальным списком
  List<Product> get items => [..._items];
  
  // Методы поиска и фильтрации
  void searchProducts(String query) { ... }
  List<Product> getProductsByCategory(String category) { ... }
  void updateRating(String productId, double rating) { ... }
  // и т.д.
}
```

---

## Примеры товаров из разных категорий

### Категория: КОРМА (Feeds/Food)

#### Пример 1: Royal Canin Maxi Adult
```dart
Product(
  id: 'p1',
  name: 'Royal Canin Maxi Adult',
  description: 'Сухой корм для взрослых собак крупных пород. Укрепляет сустава и поддерживает оптимальный вес.',
  price: 25500,
  category: 'Корма',
  imageUrl: 'https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcTXhBQqGOCEx8cGaL0TmupDcrAmLab1wYW68fSKeemK2l80e13PZ7UAqA4z5SIpaCWptl6_X5nN0UGoKuHZPR8I3-J0oopFsf93q4tIqz8QuRq20mTmeY1Lw_G3-uoE&usqp=CAc',
  rating: 4.8,
),
```

#### Пример 2: Purina Pro Plan Sterilised (использует Base64 картинку)
```dart
Product(
  id: 'p2',
  name: 'Purina Pro Plan Sterilised',
  description: 'Сухой корм для стерилизованные кошек с лососем. Поддерживает здоровье почечек.',
  price: 8500,
  category: 'Корма',
  imageUrl: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBxISEhUREhIWFRUVFRUVFRYVFRUXFxUXFRUWFhUYGBcYHSggGholGxYYITIhJSkrLi4uFyAzODMsNygtLisBCgoKDg0OGxAQGi4eIB8tLSstKy0rKy0tLSsrKy0tLS0tLS0yLS0tLSstKy0tKy0tLS0tKy0tLS0rLS0rKy0tLf/AABEIATQApAMBIgACEQEDEQH/xAAcAAABBQEBAQAAAAAAAAAAAAAYGAUCBAYABwj/xABPEAAC...',
  rating: 4.5,
),
```

---

## Различия в хранении изображений

### 1. HTTPS URL (прямая ссылка)
```
imageUrl: 'https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcTXhBQqGOCEx8cGaL0...'
```
- Преимущества: экономит память кода
- Недостатки: зависит от внешнего хоста, может быть недоступно

### 2. Base64 Encoded (встроено в код)
```
imageUrl: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBxISEhUREh...'
```
- Преимущества: картинка всегда доступна с приложением
- Недостатки: занимает много места в коде (обычно 10KB+ на картинку)

### 3. НЕ ИСПОЛЬЗОВАЛОСЬ: Локальные assets
Картинки никогда не хранились в `assets/images/` как обычные файлы

---

## Цифры по статистике

| Параметр | Значение |
|----------|----------|
| Всего товаров | ~76 |
| Строк кода (product_provider.dart) | 833 |
| Строк удалено | 827 |
| Строк добавлено | 122 |
| Категорий | 5 |
| Полей в Product | 7 (id, name, description, price, category, imageUrl, rating) |

---

## Какие методы были в старой версии

```dart
class ProductProvider extends ChangeNotifier {
  // Получение товаров
  List<Product> get items;
  
  // Поиск товаров
  void searchProducts(String query);
  
  // Фильтрация по категориям
  List<Product> getProductsByCategory(String category);
  
  // Рейтинги
  void updateRating(String productId, double rating);
  
  // Локальные операции без синхронизации с БД
}
```

---

## После миграции (коммит 83ee1bb)

Все эти жестко закодированные данные были:
1. **Удалены из кода**
2. **Загружены в Supabase**
3. **Заменены на динамическую загрузку из БД**

Новая версия использует:
```dart
Future<void> fetchProducts() async {
  // Загрузка из Supabase вместо работы со статическим списком
}
```

---

## Полный файл

**Полное содержимое старого product_provider.dart находится в файле:**
`OLD_product_provider_from_83ee1bb_parents.dart`

Файл содержит все 76 товаров с полными данными и может быть использован для:
- Восстановления данных
- Анализа миграции
- Проверки целостности переноса в БД
