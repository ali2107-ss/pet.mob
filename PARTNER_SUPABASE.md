# Интеграция Supabase для режима партнера

## Описание

Этот документ описывает, как использовать интеграцию Supabase для сохранения данных партнера (товары, продажи, информация о магазине).

## Таблицы Supabase

### 1. partner_shops
Хранит информацию о магазинах партнеров:
- `id` - UUID магазина
- `partner_id` - ID пользователя (из auth.users)
- `shop_name` - Название магазина
- `shop_description` - Описание магазина
- `balance` - Баланс партнера (накопленные средства)
- `created_at`, `updated_at` - Время создания/обновления

### 2. partner_products
Хранит товары партнеров:
- `id` - UUID товара
- `partner_id` - ID партнера
- `name` - Название товара
- `description` - Описание
- `price` - Цена
- `category` - Категория
- `image_url` - URL изображения
- `stock` - Количество на складе
- `sold` - Количество продано
- `is_active` - Активен ли товар
- `created_at`, `updated_at` - Время создания/обновления

### 3. partner_sales
Хранит историю продаж:
- `id` - UUID записи о продаже
- `partner_id` - ID партнера
- `product_id` - ID товара
- `quantity` - Количество продано
- `amount` - Сумма продажи
- `description` - Описание продажи
- `created_at` - Время продажи

## Методы в PartnerProvider

### Инициализация
```dart
// Загрузить данные из Supabase при входе партнера
await partnerProvider.initializePartner();
```

### Работа с товарами
```dart
// Добавить товар и сохранить в Supabase
await partnerProvider.addProductWithSupabase(product);

// Обновить товар и синхронизировать с Supabase
await partnerProvider.updateProductWithSupabase(id, name: 'Новое название');

// Удалить товар и синхронизировать с Supabase
await partnerProvider.deleteProductWithSupabase(id);
```

### Работа с продажами
```dart
// Сохранить продажу в Supabase
await partnerProvider.simulateSaleWithSupabase(productId, quantity);
```

### Информация о магазине
```dart
// Обновить информацию о магазине
await partnerProvider.updateShopInfoWithSupabase(
  name: 'Новое название',
  description: 'Новое описание'
);

// Синхронизировать баланс
await partnerProvider.syncBalance();
```

## Использование в экранах

### partner_main_screen.dart
```dart
@override
void initState() {
  super.initState();
  // Загружаем данные из Supabase при первом входе
  Future.microtask(() async {
    final partnerProvider = Provider.of<PartnerProvider>(context, listen: false);
    await partnerProvider.initializePartner();
  });
}
```

### partner_products_screen.dart
При добавлении товара:
```dart
final newProduct = PartnerProduct(
  id: DateTime.now().toString(),
  name: _nameController.text,
  // ... другие поля
);

// Вместо addProduct используем:
await partnerProvider.addProductWithSupabase(newProduct);
```

При редактировании товара:
```dart
await partnerProvider.updateProductWithSupabase(
  productId,
  name: newName,
  price: newPrice,
  stock: newStock,
);
```

### partner_dashboard_screen.dart
При имитации продажи:
```dart
// Вместо simulateSale используем:
await partnerProvider.simulateSaleWithSupabase(productId, quantity);
```

## Установка в Supabase

1. Откройте SQL Editor в Supabase Dashboard
2. Выполните SQL из файла `supabase/migrations/partner_tables.sql`
3. Проверьте, что таблицы созданы успешно

## Безопасность

- Row Level Security (RLS) включён для всех таблиц
- Партнеры могут видеть и редактировать только свои данные
- Активные товары видны всем пользователям (для покупок)

## Обработка ошибок

Все методы включают обработку ошибок:
```dart
try {
  await partnerProvider.addProductWithSupabase(product);
} catch (e) {
  print('Ошибка при добавлении товара: $e');
}
```

Также при ошибке автоматически откатываются локальные изменения.

## Советы

1. Вызывайте `initializePartner()` сразу при входе партнера в режим
2. Используйте методы с суффиксом `WithSupabase` вместо обычных методов
3. Проверяйте логи в Debug Console для отладки
4. Убедитесь, что пользователь авторизован (auth.currentUser != null)
