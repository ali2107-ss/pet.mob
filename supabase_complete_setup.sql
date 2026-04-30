-- ============================================
-- ПОЛНАЯ НАСТРОЙКА БАЗЫ ДАННЫХ SUPABASE
-- Выполните этот скрипт в SQL Editor
-- ============================================

-- ============================================
-- 1. ТАБЛИЦА PRODUCTS (Товары)
-- ============================================

CREATE TABLE IF NOT EXISTS products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  price NUMERIC NOT NULL,
  category TEXT NOT NULL,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE products ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "products_select_all" ON products;
CREATE POLICY "products_select_all" ON products
  FOR SELECT USING (true);

-- ============================================
-- 2. ТАБЛИЦА PRODUCT_RATINGS (Рейтинги)
-- ============================================

CREATE TABLE IF NOT EXISTS product_ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(product_id, user_id)
);

ALTER TABLE product_ratings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "product_ratings_select_all" ON product_ratings;
CREATE POLICY "product_ratings_select_all" ON product_ratings
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "product_ratings_insert_own" ON product_ratings;
CREATE POLICY "product_ratings_insert_own" ON product_ratings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "product_ratings_update_own" ON product_ratings;
CREATE POLICY "product_ratings_update_own" ON product_ratings
  FOR UPDATE USING (auth.uid() = user_id);

-- ============================================
-- 3. ТАБЛИЦА ADDRESSES (Адреса доставки)
-- ============================================

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

DROP POLICY IF EXISTS "addresses_select_own" ON addresses;
CREATE POLICY "addresses_select_own" ON addresses
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "addresses_insert_own" ON addresses;
CREATE POLICY "addresses_insert_own" ON addresses
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "addresses_update_own" ON addresses;
CREATE POLICY "addresses_update_own" ON addresses
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "addresses_delete_own" ON addresses;
CREATE POLICY "addresses_delete_own" ON addresses
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- 4. ТАБЛИЦА PAYMENT_METHODS (Способы оплаты)
-- ============================================

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

DROP POLICY IF EXISTS "payment_methods_select_own" ON payment_methods;
CREATE POLICY "payment_methods_select_own" ON payment_methods
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "payment_methods_insert_own" ON payment_methods;
CREATE POLICY "payment_methods_insert_own" ON payment_methods
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "payment_methods_update_own" ON payment_methods;
CREATE POLICY "payment_methods_update_own" ON payment_methods
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "payment_methods_delete_own" ON payment_methods;
CREATE POLICY "payment_methods_delete_own" ON payment_methods
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- 5. ТАБЛИЦА PETS (Питомцы)
-- ============================================

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

DROP POLICY IF EXISTS "pets_select_own" ON pets;
CREATE POLICY "pets_select_own" ON pets
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "pets_insert_own" ON pets;
CREATE POLICY "pets_insert_own" ON pets
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "pets_update_own" ON pets;
CREATE POLICY "pets_update_own" ON pets
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "pets_delete_own" ON pets;
CREATE POLICY "pets_delete_own" ON pets
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- 6. ТАБЛИЦА NOTIFICATIONS (Уведомления)
-- ============================================

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

DROP POLICY IF EXISTS "notifications_select_own" ON notifications;
CREATE POLICY "notifications_select_own" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "notifications_insert_own" ON notifications;
CREATE POLICY "notifications_insert_own" ON notifications
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "notifications_update_own" ON notifications;
CREATE POLICY "notifications_update_own" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- ============================================
-- 7. ТАБЛИЦА PROMO_BANNERS (Промо-баннеры)
-- ============================================

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

DROP POLICY IF EXISTS "promo_banners_select_all" ON promo_banners;
CREATE POLICY "promo_banners_select_all" ON promo_banners
  FOR SELECT USING (is_active = true);

-- ============================================
-- 8. ПАРТНЕРСКИЕ ТАБЛИЦЫ
-- ============================================

-- 8.1 PARTNER_SHOPS (Магазины партнеров)
CREATE TABLE IF NOT EXISTS partner_shops (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  shop_name VARCHAR(255) NOT NULL DEFAULT 'Мой магазин',
  shop_description TEXT DEFAULT '',
  balance DECIMAL(10, 2) NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE partner_shops ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "partner_shops_select" ON partner_shops;
CREATE POLICY "partner_shops_select" ON partner_shops
  FOR SELECT USING (auth.uid() = partner_id);

DROP POLICY IF EXISTS "partner_shops_update" ON partner_shops;
CREATE POLICY "partner_shops_update" ON partner_shops
  FOR UPDATE USING (auth.uid() = partner_id);

DROP POLICY IF EXISTS "partner_shops_insert" ON partner_shops;
CREATE POLICY "partner_shops_insert" ON partner_shops
  FOR INSERT WITH CHECK (auth.uid() = partner_id);

-- 8.2 PARTNER_PRODUCTS (Товары партнеров)
CREATE TABLE IF NOT EXISTS partner_products (
  id VARCHAR(255) PRIMARY KEY,
  partner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  category VARCHAR(100) NOT NULL,
  image_url TEXT,
  stock INTEGER NOT NULL DEFAULT 0,
  sold INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_partner_products_partner_id ON partner_products(partner_id);
CREATE INDEX IF NOT EXISTS idx_partner_products_partner_active ON partner_products(partner_id, is_active);

ALTER TABLE partner_products ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "partner_products_select" ON partner_products;
CREATE POLICY "partner_products_select" ON partner_products
  FOR SELECT USING (partner_id = auth.uid() OR is_active = true);

DROP POLICY IF EXISTS "partner_products_update" ON partner_products;
CREATE POLICY "partner_products_update" ON partner_products
  FOR UPDATE USING (auth.uid() = partner_id);

DROP POLICY IF EXISTS "partner_products_insert" ON partner_products;
CREATE POLICY "partner_products_insert" ON partner_products
  FOR INSERT WITH CHECK (auth.uid() = partner_id);

DROP POLICY IF EXISTS "partner_products_delete" ON partner_products;
CREATE POLICY "partner_products_delete" ON partner_products
  FOR DELETE USING (auth.uid() = partner_id);

-- 8.3 PARTNER_SALES (Продажи партнеров)
CREATE TABLE IF NOT EXISTS partner_sales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id VARCHAR(255) NOT NULL REFERENCES partner_products(id) ON DELETE SET NULL,
  quantity INTEGER NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  description VARCHAR(255),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_partner_sales_partner_id ON partner_sales(partner_id);
CREATE INDEX IF NOT EXISTS idx_partner_sales_created_at ON partner_sales(created_at DESC);

ALTER TABLE partner_sales ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "partner_sales_select" ON partner_sales;
CREATE POLICY "partner_sales_select" ON partner_sales
  FOR SELECT USING (auth.uid() = partner_id);

DROP POLICY IF EXISTS "partner_sales_insert" ON partner_sales;
CREATE POLICY "partner_sales_insert" ON partner_sales
  FOR INSERT WITH CHECK (auth.uid() = partner_id);

-- 8.4 ORDERS (Заказы)
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  total_amount DECIMAL(10, 2) NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at DESC);

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "orders_select" ON orders;
CREATE POLICY "orders_select" ON orders
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "orders_insert" ON orders;
CREATE POLICY "orders_insert" ON orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 8.5 ORDER_ITEMS (Позиции заказов)
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id VARCHAR(255) NOT NULL,
  partner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
  quantity INTEGER NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  total DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_partner_id ON order_items(partner_id);

ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "order_items_select" ON order_items;
CREATE POLICY "order_items_select" ON order_items
  FOR SELECT USING (
    EXISTS(
      SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid()
    )
    OR auth.uid() = partner_id
  );

DROP POLICY IF EXISTS "order_items_insert" ON order_items;
CREATE POLICY "order_items_insert" ON order_items
  FOR INSERT WITH CHECK (
    EXISTS(
      SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid()
    )
  );

-- ============================================
-- 9. ТРИГГЕРЫ И ФУНКЦИИ
-- ============================================

-- Функция для обновления stock при создании заказов
CREATE OR REPLACE FUNCTION update_product_stock()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE partner_products 
  SET stock = stock - NEW.quantity, sold = sold + NEW.quantity
  WHERE id = NEW.product_id AND stock >= NEW.quantity;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер для обновления stock
DROP TRIGGER IF EXISTS trigger_update_stock ON order_items;
CREATE TRIGGER trigger_update_stock
AFTER INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_product_stock();

-- ============================================
-- 10. ТЕСТОВЫЕ ДАННЫЕ (опционально)
-- ============================================

-- Добавить несколько тестовых товаров
INSERT INTO products (id, name, description, price, category, image_url) VALUES
('prod_001', 'Корм для собак Royal Canin', 'Сухой корм для взрослых собак средних пород, 15 кг', 8500, 'Корма', 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=400'),
('prod_002', 'Игрушка для кошек', 'Интерактивная игрушка-мышка с датчиком движения', 1200, 'Игрушки', 'https://images.unsplash.com/photo-1545249390-6bdfa286032f?w=400'),
('prod_003', 'Лежанка для собак', 'Мягкая ортопедическая лежанка 60x80 см', 5500, 'Аксессуары', 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=400'),
('prod_004', 'Когтеточка', 'Высокая когтеточка с домиком, 120 см', 12000, 'Аксессуары', 'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=400'),
('prod_005', 'Корм для кошек Whiskas', 'Влажный корм с курицей, 24 пакетика', 3200, 'Корма', 'https://images.unsplash.com/photo-1548681528-6a5c45b66b42?w=400')
ON CONFLICT (id) DO NOTHING;

-- Добавить тестовый промо-баннер
INSERT INTO promo_banners (title, description, image_url, is_active, order_index) VALUES
('Скидка 20% на корма!', 'Специальное предложение на все корма премиум класса', 'https://images.unsplash.com/photo-1450778869180-41d0601e046e?w=800', true, 1),
('Новая коллекция игрушек', 'Интерактивные игрушки для ваших питомцев', 'https://images.unsplash.com/photo-1415369629372-26f2fe60c467?w=800', true, 2)
ON CONFLICT DO NOTHING;

-- ============================================
-- ГОТОВО! ✅
-- ============================================

-- Проверка созданных таблиц
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;
