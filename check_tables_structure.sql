-- ============================================
-- ПРОВЕРКА СТРУКТУРЫ ТАБЛИЦ
-- Выполните этот скрипт в SQL Editor
-- ============================================

-- 1. Проверка всех таблиц
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;

-- 2. Проверка структуры таблицы PRODUCTS
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'products'
ORDER BY ordinal_position;

-- 3. Проверка количества товаров
SELECT COUNT(*) as total_products FROM products;

-- 4. Проверка первых 5 товаров
SELECT id, name, price, category FROM products LIMIT 5;

-- 5. Проверка RLS политик
SELECT tablename, policyname, permissive, roles, cmd
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- 6. Проверка структуры PRODUCT_RATINGS
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'product_ratings'
ORDER BY ordinal_position;

-- 7. Проверка структуры PARTNER_PRODUCTS
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'partner_products'
ORDER BY ordinal_position;

-- 8. Проверка структуры ORDERS
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'orders'
ORDER BY ordinal_position;

-- 9. Проверка структуры CART_ITEMS (если используется)
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'cart_items'
ORDER BY ordinal_position;

-- 10. Проверка структуры FAVORITES (если используется)
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'favorites'
ORDER BY ordinal_position;
