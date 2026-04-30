-- ============================================
-- ПРОВЕРКА СУЩЕСТВУЮЩИХ ТАБЛИЦ
-- Выполните этот скрипт СНАЧАЛА
-- ============================================

-- 1. Проверка структуры promo_codes
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'promo_codes'
ORDER BY ordinal_position;

-- 2. Проверка структуры profiles
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'profiles'
ORDER BY ordinal_position;

-- 3. Проверка структуры promo_usages
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'promo_usages'
ORDER BY ordinal_position;

-- 4. Проверка данных в promo_codes
SELECT * FROM promo_codes LIMIT 5;

-- 5. Проверка RLS политик для promo_codes
SELECT tablename, policyname, permissive, roles, cmd
FROM pg_policies 
WHERE tablename = 'promo_codes';
