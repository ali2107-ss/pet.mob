-- Создание таблицы partner_shops для хранения информации о магазинах партнеров
CREATE TABLE IF NOT EXISTS partner_shops (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  shop_name VARCHAR(255) NOT NULL DEFAULT 'Мой магазин',
  shop_description TEXT DEFAULT '',
  balance DECIMAL(10, 2) NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Создание таблицы partner_products для хранения товаров партнеров
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

-- Создание таблицы partner_sales для хранения истории продаж
CREATE TABLE IF NOT EXISTS partner_sales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id VARCHAR(255) NOT NULL REFERENCES partner_products(id) ON DELETE SET NULL,
  quantity INTEGER NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  description VARCHAR(255),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Создание индексов для оптимизации запросов
CREATE INDEX IF NOT EXISTS idx_partner_products_partner_id ON partner_products(partner_id);
CREATE INDEX IF NOT EXISTS idx_partner_products_partner_active ON partner_products(partner_id, is_active);
CREATE INDEX IF NOT EXISTS idx_partner_sales_partner_id ON partner_sales(partner_id);
CREATE INDEX IF NOT EXISTS idx_partner_sales_created_at ON partner_sales(created_at DESC);

-- Включение RLS (Row Level Security) для безопасности
ALTER TABLE partner_shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_sales ENABLE ROW LEVEL SECURITY;

-- Политики RLS для partner_shops
CREATE POLICY "partner_shops_select" ON partner_shops
  FOR SELECT USING (auth.uid() = partner_id);

CREATE POLICY "partner_shops_update" ON partner_shops
  FOR UPDATE USING (auth.uid() = partner_id);

CREATE POLICY "partner_shops_insert" ON partner_shops
  FOR INSERT WITH CHECK (auth.uid() = partner_id);

-- Политики RLS для partner_products
CREATE POLICY "partner_products_select" ON partner_products
  FOR SELECT USING (partner_id = auth.uid() OR is_active = true);

CREATE POLICY "partner_products_update" ON partner_products
  FOR UPDATE USING (auth.uid() = partner_id);

CREATE POLICY "partner_products_insert" ON partner_products
  FOR INSERT WITH CHECK (auth.uid() = partner_id);

CREATE POLICY "partner_products_delete" ON partner_products
  FOR DELETE USING (auth.uid() = partner_id);

-- Политики RLS для partner_sales
CREATE POLICY "partner_sales_select" ON partner_sales
  FOR SELECT USING (auth.uid() = partner_id);

CREATE POLICY "partner_sales_insert" ON partner_sales
  FOR INSERT WITH CHECK (auth.uid() = partner_id);

-- Создание таблицы orders для хранения заказов покупателей
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  total_amount DECIMAL(10, 2) NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'pending', -- pending, completed, cancelled
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Создание таблицы order_items для хранения позиций заказов
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

-- Индексы для оптимизации
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_partner_id ON order_items(partner_id);

-- Включение RLS
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Политики RLS для orders
CREATE POLICY "orders_select" ON orders
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "orders_insert" ON orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Политики RLS для order_items
CREATE POLICY "order_items_select" ON order_items
  FOR SELECT USING (
    EXISTS(
      SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid()
    )
    OR auth.uid() = partner_id
  );

CREATE POLICY "order_items_insert" ON order_items
  FOR INSERT WITH CHECK (
    EXISTS(
      SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid()
    )
  );

-- Функция для обновления stock при создании заказов (триггер)
CREATE OR REPLACE FUNCTION update_product_stock()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE partner_products 
  SET stock = stock - NEW.quantity, sold = sold + NEW.quantity
  WHERE id = NEW.product_id AND stock >= NEW.quantity;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер для обновления stock при добавлении order_items
DROP TRIGGER IF EXISTS trigger_update_stock ON order_items;
CREATE TRIGGER trigger_update_stock
AFTER INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_product_stock();
