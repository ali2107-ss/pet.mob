# 🚀 Инструкция по настройке Supabase

## 1️⃣ Создание проекта Supabase

1. Зайдите на https://supabase.com
2. Нажмите "Start your project"
3. Создайте новый проект:
   - **Organization**: создайте новую или выберите существующую
   - **Project Name**: `petmob` (или любое имя)
   - **Database Password**: придумайте надежный пароль (сохраните его!)
   - **Region**: выберите ближайший регион (например, Frankfurt)
4. Дождитесь создания проекта (1-2 минуты)

## 2️⃣ Получение API ключей

1. В левом меню выберите **Settings** (⚙️)
2. Перейдите в **API**
3. Скопируйте:
   - **Project URL** (например: `https://xxxxx.supabase.co`)
   - **anon public** ключ (начинается с `eyJ...`)

## 3️⃣ Настройка Flutter приложения

Откройте файл `lib/main.dart` и найдите строки:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

Замените на ваши данные:

```dart
await Supabase.initialize(
  url: 'https://xxxxx.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
);
```

## 4️⃣ Создание таблиц в базе данных

### Вариант A: Через SQL Editor (рекомендуется)

1. В Supabase перейдите в **SQL Editor** (левое меню)
2. Нажмите **New query**
3. Выполните SQL файлы по порядку:

#### Шаг 1: Основные таблицы
Скопируйте содержимое файла `supabase_setup.sql` и выполните

#### Шаг 2: Партнерские таблицы
Скопируйте содержимое файла `supabase/migrations/partner_tables.sql` и выполните

#### Шаг 3: Рейтинги
Скопируйте содержимое файла `supabase_setup_ratings.sql` и выполните

#### Шаг 4: Тестовые данные (опционально)
Скопируйте содержимое файла `supabase_insert_products.sql` и выполните

### Вариант B: Через Table Editor

1. Перейдите в **Table Editor**
2. Создайте таблицы вручную согласно схеме в SQL файлах

## 5️⃣ Настройка Authentication

1. Перейдите в **Authentication** → **Providers**
2. Включите **Email** провайдер
3. Настройки:
   - ✅ Enable Email provider
   - ✅ Confirm email (опционально)
   - ✅ Secure email change (рекомендуется)

## 6️⃣ Настройка Storage (для изображений)

1. Перейдите в **Storage**
2. Создайте bucket с именем `product-images`
3. Настройки:
   - **Public bucket**: ✅ (чтобы изображения были доступны)
   - **File size limit**: 5MB
   - **Allowed MIME types**: `image/*`

### Политики доступа для Storage:

```sql
-- Разрешить всем читать изображения
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING (bucket_id = 'product-images');

-- Разрешить партнерам загружать изображения
CREATE POLICY "Partner Upload"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'product-images' 
  AND auth.role() = 'authenticated'
);
```

## 7️⃣ Проверка настройки

### Проверьте созданные таблицы:

В **Table Editor** должны быть таблицы:
- ✅ `products` - основные товары
- ✅ `product_ratings` - рейтинги товаров
- ✅ `partner_shops` - магазины партнеров
- ✅ `partner_products` - товары партнеров
- ✅ `partner_sales` - продажи партнеров
- ✅ `orders` - заказы
- ✅ `order_items` - позиции заказов
- ✅ `addresses` - адреса доставки
- ✅ `payment_methods` - способы оплаты
- ✅ `pets` - питомцы пользователей
- ✅ `notifications` - уведомления
- ✅ `promo_banners` - промо-баннеры

### Проверьте RLS (Row Level Security):

1. Перейдите в **Authentication** → **Policies**
2. Убедитесь, что для каждой таблицы есть политики доступа

## 8️⃣ Тестирование

1. Запустите Flutter приложение:
   ```bash
   flutter run
   ```

2. Попробуйте:
   - ✅ Зарегистрироваться
   - ✅ Войти в систему
   - ✅ Просмотреть товары
   - ✅ Добавить товар в корзину

## 🔧 Устранение проблем

### Ошибка: "Invalid API key"
- Проверьте правильность URL и anon key
- Убедитесь, что нет лишних пробелов

### Ошибка: "relation does not exist"
- Таблицы не созданы - выполните SQL скрипты

### Ошибка: "permission denied"
- Проверьте RLS политики
- Убедитесь, что пользователь авторизован

### Товары не загружаются
- Проверьте, что таблица `products` содержит данные
- Выполните `supabase_insert_products.sql` для добавления тестовых товаров

## 📚 Дополнительные ресурсы

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)

## 🎯 Следующие шаги

После настройки Supabase:

1. ✅ Добавьте тестовые товары через SQL
2. ✅ Настройте изображения товаров в Storage
3. ✅ Протестируйте регистрацию и авторизацию
4. ✅ Проверьте работу корзины и заказов
5. ✅ Настройте партнерский функционал
