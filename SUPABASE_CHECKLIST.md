# ✅ Чек-лист проверки Supabase

## 🔍 Шаг 1: Проверьте наличие таблиц

Зайдите в **Table Editor** в Supabase и убедитесь, что есть все таблицы:

### Основные таблицы:
- [ ] `products` - товары
- [ ] `product_ratings` - рейтинги товаров
- [ ] `addresses` - адреса доставки
- [ ] `payment_methods` - способы оплаты
- [ ] `pets` - питомцы пользователей
- [ ] `notifications` - уведомления
- [ ] `promo_banners` - промо-баннеры

### Партнерские таблицы:
- [ ] `partner_shops` - магазины партнеров
- [ ] `partner_products` - товары партнеров
- [ ] `partner_sales` - продажи партнеров
- [ ] `orders` - заказы
- [ ] `order_items` - позиции заказов

---

## 📋 Шаг 2: Проверьте структуру таблицы `products`

Таблица `products` должна иметь следующие колонки:

```
id              | text (Primary Key)
name            | text
description     | text
price           | numeric
category        | text
image_url       | text
created_at      | timestamp with time zone
```

### Если таблицы НЕТ или структура неправильная:

Выполните в **SQL Editor**:

```sql
-- Удалить старую таблицу (если нужно)
DROP TABLE IF EXISTS products CASCADE;

-- Создать правильную таблицу
CREATE TABLE products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  price NUMERIC NOT NULL,
  category TEXT NOT NULL,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Включить RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Разрешить всем читать товары
CREATE POLICY "products_select_all" ON products
  FOR SELECT USING (true);
```

---

## 📋 Шаг 3: Проверьте таблицу `product_ratings`

Структура:

```
id              | uuid (Primary Key)
product_id      | text (Foreign Key -> products.id)
user_id         | uuid (Foreign Key -> auth.users.id)
rating          | integer (1-5)
created_at      | timestamp with time zone
```

### Если таблицы НЕТ:

```sql
CREATE TABLE product_ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(product_id, user_id)
);

ALTER TABLE product_ratings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "product_ratings_select_all" ON product_ratings
  FOR SELECT USING (true);

CREATE POLICY "product_ratings_insert_own" ON product_ratings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "product_ratings_update_own" ON product_ratings
  FOR UPDATE USING (auth.uid() = user_id);
```

---

## 📋 Шаг 4: Проверьте партнерские таблицы

Если их нет, выполните файл: `supabase/migrations/partner_tables.sql`

Или скопируйте содержимое в **SQL Editor** и выполните.

---

## 📋 Шаг 5: Проверьте таблицу `addresses`

```sql
CREATE TABLE IF NOT EXISTS addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  address TEXT NOT NULL,
  city TEXT NOT NULL,
  postal_code TEXT,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "addresses_select_own" ON addresses
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "addresses_insert_own" ON addresses
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "addresses_update_own" ON addresses
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "addresses_delete_own" ON addresses
  FOR DELETE USING (auth.uid() = user_id);
```

---

## 📋 Шаг 6: Проверьте таблицу `payment_methods`

```sql
CREATE TABLE IF NOT EXISTS payment_methods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  card_number TEXT NOT NULL,
  card_holder TEXT NOT NULL,
  expiry_date TEXT NOT NULL,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;

CREATE POLICY "payment_methods_select_own" ON payment_methods
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "payment_methods_insert_own" ON payment_methods
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "payment_methods_update_own" ON payment_methods
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "payment_methods_delete_own" ON payment_methods
  FOR DELETE USING (auth.uid() = user_id);
```

---

## 📋 Шаг 7: Проверьте таблицу `pets`

```sql
CREATE TABLE IF NOT EXISTS pets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  breed TEXT,
  age INTEGER,
  weight NUMERIC,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE pets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "pets_select_own" ON pets
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "pets_insert_own" ON pets
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "pets_update_own" ON pets
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "pets_delete_own" ON pets
  FOR DELETE USING (auth.uid() = user_id);
```

---

## 📋 Шаг 8: Проверьте таблицу `notifications`

```sql
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "notifications_select_own" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "notifications_insert_own" ON notifications
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "notifications_update_own" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);
```

---

## 📋 Шаг 9: Проверьте таблицу `promo_banners`

```sql
CREATE TABLE IF NOT EXISTS promo_banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT NOT NULL,
  link TEXT,
  is_active BOOLEAN DEFAULT true,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE promo_banners ENABLE ROW LEVEL SECURITY;

CREATE POLICY "promo_banners_select_all" ON promo_banners
  FOR SELECT USING (is_active = true);
```

---

## 📋 Шаг 10: Добавьте тестовые данные

### Если в таблице `products` нет товаров:

Выполните файл `supabase_insert_products.sql` в **SQL Editor**.

Или добавьте несколько товаров вручную:

```sql
INSERT INTO products (id, name, description, price, category, image_url) VALUES
('prod_001', 'Корм для собак Royal Canin', 'Сухой корм для взрослых собак средних пород', 8500, 'Корма', 'https://example.com/dog-food.jpg'),
('prod_002', 'Игрушка для кошек', 'Интерактивная игрушка-мышка', 1200, 'Игрушки', 'https://example.com/cat-toy.jpg'),
('prod_003', 'Лежанка для собак', 'Мягкая лежанка 60x80 см', 5500, 'Аксессуары', 'https://example.com/dog-bed.jpg');
```

---

## 📋 Шаг 11: Проверьте Authentication

1. Зайдите в **Authentication** → **Providers**
2. Убедитесь, что включен **Email** провайдер
3. Настройки:
   - ✅ Enable Email provider
   - ✅ Confirm email: OFF (для тестирования)

---

## 📋 Шаг 12: Проверьте Storage (опционально)

Если хотите загружать изображения:

1. Зайдите в **Storage**
2. Создайте bucket `product-images`
3. Сделайте его публичным (Public bucket: ON)

---

## 🚀 Шаг 13: Запустите приложение

```bash
flutter clean
flutter pub get
flutter run
```

---

## 🔧 Если возникают ошибки:

### Ошибка: "relation does not exist"
➡️ Таблица не создана. Выполните SQL скрипты выше.

### Ошибка: "permission denied"
➡️ Проблема с RLS политиками. Проверьте, что политики созданы.

### Ошибка: "Invalid API key"
➡️ Проверьте URL и anon key в `lib/main.dart`

### Товары не загружаются
➡️ Добавьте тестовые данные в таблицу `products`

---

## ✅ Быстрая проверка через SQL

Выполните в **SQL Editor**:

```sql
-- Проверка наличия таблиц
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;

-- Проверка количества товаров
SELECT COUNT(*) as total_products FROM products;

-- Проверка RLS политик
SELECT tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename;
```

---

## 📞 Нужна помощь?

Если что-то не работает:
1. Скопируйте текст ошибки
2. Проверьте логи в Supabase Dashboard → Logs
3. Убедитесь, что все таблицы созданы
