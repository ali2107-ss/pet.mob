-- ============================================
-- СОЗДАНИЕ/ПРОВЕРКА ТАБЛИЦ CART_ITEMS И FAVORITES
-- Выполните этот скрипт в SQL Editor
-- ============================================

-- ============================================
-- 1. ТАБЛИЦА CART_ITEMS (Корзина)
-- ============================================

-- Удалить старую таблицу если структура неправильная (опционально)
-- DROP TABLE IF EXISTS cart_items CASCADE;

CREATE TABLE IF NOT EXISTS cart_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- Индексы для оптимизации
CREATE INDEX IF NOT EXISTS idx_cart_items_user_id ON cart_items(user_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_product_id ON cart_items(product_id);

-- Включить RLS
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;

-- Удалить старые политики
DROP POLICY IF EXISTS "cart_items_select_own" ON cart_items;
DROP POLICY IF EXISTS "cart_items_insert_own" ON cart_items;
DROP POLICY IF EXISTS "cart_items_update_own" ON cart_items;
DROP POLICY IF EXISTS "cart_items_delete_own" ON cart_items;

-- Создать новые политики
CREATE POLICY "cart_items_select_own" ON cart_items
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "cart_items_insert_own" ON cart_items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "cart_items_update_own" ON cart_items
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "cart_items_delete_own" ON cart_items
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- 2. ТАБЛИЦА FAVORITES (Избранное)
-- ============================================

-- Удалить старую таблицу если структура неправильная (опционально)
-- DROP TABLE IF EXISTS favorites CASCADE;

CREATE TABLE IF NOT EXISTS favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- Индексы для оптимизации
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_product_id ON favorites(product_id);

-- Включить RLS
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

-- Удалить старые политики
DROP POLICY IF EXISTS "favorites_select_own" ON favorites;
DROP POLICY IF EXISTS "favorites_insert_own" ON favorites;
DROP POLICY IF EXISTS "favorites_delete_own" ON favorites;

-- Создать новые политики
CREATE POLICY "favorites_select_own" ON favorites
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "favorites_insert_own" ON favorites
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "favorites_delete_own" ON favorites
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- 3. ПРОВЕРКА СОЗДАННЫХ ТАБЛИЦ
-- ============================================

-- Проверка структуры cart_items
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'cart_items'
ORDER BY ordinal_position;

-- Проверка структуры favorites
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'favorites'
ORDER BY ordinal_position;

-- Проверка политик
SELECT tablename, policyname, cmd
FROM pg_policies 
WHERE tablename IN ('cart_items', 'favorites')
ORDER BY tablename, policyname;

-- ============================================
-- ГОТОВО! ✅
-- ============================================
