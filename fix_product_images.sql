SELECT 
  id, 
  name, 
  LEFT(image_url, 60) as current_image,
  CASE 
    WHEN image_url LIKE 'http%' THEN '✅ URL'
    WHEN image_url LIKE 'data:image%' THEN '⚠️ Base64'
    ELSE '❌ Пусто/Ошибка'
  END as status
FROM products
ORDER BY id;

UPDATE products SET image_url = 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=400&q=80' 
WHERE id = 'prod_001' OR (category = 'Корма' AND name LIKE '%собак%');

UPDATE products SET image_url = 'https://images.unsplash.com/photo-1545249390-6bdfa286032f?w=400&q=80' 
WHERE id = 'prod_002' OR (category = 'Игрушки' AND name LIKE '%кош%');

UPDATE products SET image_url = 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=400&q=80' 
WHERE id = 'prod_003' OR (category = 'Аксессуары' AND name LIKE '%лежанк%');

UPDATE products SET image_url = 'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=400&q=80' 
WHERE id = 'prod_004' OR (category = 'Аксессуары' AND name LIKE '%когтеточк%');

UPDATE products SET image_url = 'https://images.unsplash.com/photo-1548681528-6a5c45b66b42?w=400&q=80' 
WHERE id = 'prod_005' OR (category = 'Корма' AND name LIKE '%кош%');

-- Для остальных товаров по категориям
UPDATE products SET image_url = 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=400&q=80' 
WHERE category = 'Корма' AND (image_url IS NULL OR image_url = '' OR image_url NOT LIKE 'http%');

UPDATE products SET image_url = 'https://images.unsplash.com/photo-1545249390-6bdfa286032f?w=400&q=80' 
WHERE category = 'Игрушки' AND (image_url IS NULL OR image_url = '' OR image_url NOT LIKE 'http%');

UPDATE products SET image_url = 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=400&q=80' 
WHERE category = 'Аксессуары' AND (image_url IS NULL OR image_url = '' OR image_url NOT LIKE 'http%');

UPDATE products SET image_url = 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400&q=80' 
WHERE category = 'Гигиена' AND (image_url IS NULL OR image_url = '' OR image_url NOT LIKE 'http%');

UPDATE products SET image_url = 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=400&q=80' 
WHERE category = 'Одежда' AND (image_url IS NULL OR image_url = '' OR image_url NOT LIKE 'http%');


SELECT 
  id, 
  name, 
  category,
  LEFT(image_url, 60) as updated_image,
  CASE 
    WHEN image_url LIKE 'https://images.unsplash.com%' THEN '✅ Обновлено'
    WHEN image_url LIKE 'http%' THEN '✅ URL'
    ELSE '❌ Требует внимания'
  END as status
FROM products
ORDER BY category, name;

-- ============================================
-- 4. СТАТИСТИКА
-- ============================================

SELECT 
  category,
  COUNT(*) as total_products,
  COUNT(CASE WHEN image_url LIKE 'http%' THEN 1 END) as with_images,
  COUNT(CASE WHEN image_url IS NULL OR image_url = '' THEN 1 END) as without_images
FROM products
GROUP BY category
ORDER BY category;
