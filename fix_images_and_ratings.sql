SELECT id, name, category, LEFT(image_url, 60) as current_image
FROM products
ORDER BY category, name;

-- ============================================
-- 2. ОБНОВЛЕНИЕ НА РАЗНЫЕ ИЗОБРАЖЕНИЯ
-- ============================================

-- КОРМА ДЛЯ СОБАК
UPDATE products 
SET image_url = 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=400&q=80'
WHERE category = 'Корма' AND (name LIKE '%собак%' OR name LIKE '%dog%')
  AND id = (SELECT id FROM products WHERE category = 'Корма' AND (name LIKE '%собак%' OR name LIKE '%dog%') ORDER BY id LIMIT 1 OFFSET 0);

UPDATE products 
SET image_url = 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=400&q=80'
WHERE category = 'Корма' AND (name LIKE '%собак%' OR name LIKE '%dog%')
  AND id = (SELECT id FROM products WHERE category = 'Корма' AND (name LIKE '%собак%' OR name LIKE '%dog%') ORDER BY id LIMIT 1 OFFSET 1);

-- КОРМА ДЛЯ КОШЕК
UPDATE products 
SET image_url = 'https://images.unsplash.com/photo-1548681528-6a5c45b66b42?w=400&q=80'
WHERE category = 'Корма' AND (name LIKE '%кош%' OR name LIKE '%cat%')
  AND id = (SELECT id FROM products WHERE category = 'Корма' AND (name LIKE '%кош%' OR name LIKE '%cat%') ORDER BY id LIMIT 1 OFFSET 0);

UPDATE products 
SET image_url = 'https://images.unsplash.com/photo-1611003228941-98852ba62227?w=400&q=80'
WHERE category = 'Корма' AND (name LIKE '%кош%' OR name LIKE '%cat%')
  AND id = (SELECT id FROM products WHERE category = 'Корма' AND (name LIKE '%кош%' OR name LIKE '%cat%') ORDER BY id LIMIT 1 OFFSET 1);

-- ИГРУШКИ ДЛЯ КОШЕК
UPDATE products 
SET image_url = 'https://images.unsplash.com/photo-1545249390-6bdfa286032f?w=400&q=80'
WHERE category = 'Игрушки' AND (name LIKE '%кош%' OR name LIKE '%cat%')
  AND id = (SELECT id FROM products WHERE category = 'Игрушки' AND (name LIKE '%кош%' OR name LIKE '%cat%') ORDER BY id LIMIT 1 OFFSET 0);

UPDATE products 
SET image_url = 'https://images.unsplash.com/photo-1591871937573-74dbba515c4c?w=400&q=80'
WHERE category = 'Игрушки' AND (name LIKE '%кош%' OR name LIKE '%cat%')
  AND id = (SELECT id FROM products WHERE category = 'Игрушки' AND (name LIKE '%кош%' OR name LIKE '%cat%') ORDER BY id LIMIT 1 OFFSET 1);

-- ИГРУШКИ ДЛЯ СОБАК
UPDATE products 
SET image_url = 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=400&q=80'
WHERE category = 'Игрушки' AND (name LIKE '%собак%' OR name LIKE '%dog%')
  AND id = (SELECT id FROM products WHERE category = 'Игрушки' AND (name LIKE '%собак%' OR name LIKE '%dog%') ORDER BY id LIMIT 1 OFFSET 0);

UPDATE products 
SET image_url = 'https://images.unsplash.com/photo-1535294435445-d7249524ef2e?w=400&q=80'
WHERE category = 'Игрушки' AND (name LIKE '%собак%' OR name LIKE '%dog%')
  AND id = (SELECT id FROM products WHERE category = 'Игрушки' AND (name LIKE '%собак%' OR name LIKE '%dog%') ORDER BY id LIMIT 1 OFFSET 1);

-- АКСЕССУАРЫ - ЛЕЖАНКИ
UPDATE products 
SET image_url = 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=400&q=80'
WHERE category = 'Аксессуары' AND name LIKE '%лежанк%'
  AND id = (SELECT id FROM products WHERE category = 'Аксессуары' AND name LIKE '%лежанк%' ORDER BY id LIMIT 1 OFFSET 0);

UPDATE products 
SET image_url = 'https://images.unsplash.com/photo-1615751072497-5f5169febe17?w=400&q=80'
WHERE category = 'Аксессуары' AND name LIKE '%лежанк%'
  AND id = (SELECT id FROM products WHERE category = 'Аксессуары' AND name LIKE '%лежанк%' ORDER BY id LIMIT 1 OFFSET 1);

-- АКСЕССУАРЫ - КОГТЕТОЧКИ
UPDATE products 
SET image_url = 'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=400&q=80'
WHERE category = 'Аксессуары' AND name LIKE '%когтеточк%'
  AND id = (SELECT id FROM products WHERE category = 'Аксессуары' AND name LIKE '%когтеточк%' ORDER BY id LIMIT 1 OFFSET 0);

UPDATE products 
SET image_url = 'https://images.unsplash.com/photo-1513360371669-4adf3dd7dff8?w=400&q=80'
WHERE category = 'Аксессуары' AND name LIKE '%когтеточк%'
  AND id = (SELECT id FROM products WHERE category = 'Аксессуары' AND name LIKE '%когтеточк%' ORDER BY id LIMIT 1 OFFSET 1);

-- АКСЕССУАРЫ - МИСКИ
UPDATE products 
SET image_url = 'https://images.unsplash.com/photo-1591434134753-e5d8e7d0d4e5?w=400&q=80'
WHERE category = 'Аксессуары' AND (name LIKE '%миск%' OR name LIKE '%bowl%');

-- АКСЕССУАРЫ - ОШЕЙНИКИ/ПОВОДКИ
UPDATE products 
SET image_url = 'https://images.unsplash.com/photo-1601758125946-6ec2ef64daf8?w=400&q=80'
WHERE category = 'Аксессуары' AND (name LIKE '%ошейник%' OR name LIKE '%поводок%' OR name LIKE '%collar%');

-- ГИГИЕНА - ШАМПУНИ
UPDATE products 
SET image_url = 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400&q=80'
WHERE category = 'Гигиена' AND name LIKE '%шампун%';

-- ГИГИЕНА - НАПОЛНИТЕЛИ
UPDATE products 
SET image_url = 'https://images.unsplash.com/photo-1611003228941-98852ba62227?w=400&q=80'
WHERE category = 'Гигиена' AND name LIKE '%наполнител%';

-- ОДЕЖДА
UPDATE products 
SET image_url = 'https://images.unsplash.com/photo-1530281700549-e82e7bf110d6?w=400&q=80'
WHERE category = 'Одежда' AND name LIKE '%куртк%';

UPDATE products 
SET image_url = 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=400&q=80'
WHERE category = 'Одежда' AND name LIKE '%свитер%';

-- ============================================
-- 3. ДОБАВЛЕНИЕ ТЕСТОВЫХ ОТЗЫВОВ
-- ============================================

-- Добавляем тестовые отзывы для первых 3 товаров
-- (замените user_id на реальный ID пользователя после регистрации)

-- Для товара prod_001 (если существует)
INSERT INTO product_ratings (product_id, user_id, rating)
SELECT 'prod_001', id, 5
FROM auth.users
LIMIT 1
ON CONFLICT (product_id, user_id) DO NOTHING;

INSERT INTO product_ratings (product_id, user_id, rating)
SELECT 'prod_001', id, 4
FROM auth.users
LIMIT 1 OFFSET 1
ON CONFLICT (product_id, user_id) DO NOTHING;

-- Для товара prod_002
INSERT INTO product_ratings (product_id, user_id, rating)
SELECT 'prod_002', id, 5
FROM auth.users
LIMIT 1
ON CONFLICT (product_id, user_id) DO NOTHING;

-- Для товара prod_003
INSERT INTO product_ratings (product_id, user_id, rating)
SELECT 'prod_003', id, 4
FROM auth.users
LIMIT 1
ON CONFLICT (product_id, user_id) DO NOTHING;

INSERT INTO product_ratings (product_id, user_id, rating)
SELECT 'prod_003', id, 5
FROM auth.users
LIMIT 1 OFFSET 1
ON CONFLICT (product_id, user_id) DO NOTHING;

INSERT INTO product_ratings (product_id, user_id, rating)
SELECT 'prod_003', id, 3
FROM auth.users
LIMIT 1 OFFSET 2
ON CONFLICT (product_id, user_id) DO NOTHING;

-- ============================================
-- 4. ПРОВЕРКА РЕЗУЛЬТАТА
-- ============================================

-- Проверка изображений
SELECT 
  id, 
  name, 
  category,
  LEFT(image_url, 60) as updated_image,
  CASE 
    WHEN image_url LIKE 'https://images.unsplash.com%' THEN '✅ Обновлено'
    ELSE '⚠️ Требует внимания'
  END as status
FROM products
ORDER BY category, name;

-- Проверка рейтингов
SELECT 
  p.id,
  p.name,
  COUNT(pr.id) as reviews_count,
  ROUND(AVG(pr.rating), 1) as avg_rating
FROM products p
LEFT JOIN product_ratings pr ON p.id = pr.product_id
GROUP BY p.id, p.name
ORDER BY reviews_count DESC, p.name;
