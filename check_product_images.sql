-- Проверка изображений товаров
SELECT 
  id, 
  name, 
  LEFT(image_url, 50) as image_url_preview,
  LENGTH(image_url) as url_length,
  CASE 
    WHEN image_url LIKE 'http%' THEN 'URL'
    WHEN image_url LIKE 'data:image%' THEN 'Base64'
    ELSE 'Unknown'
  END as image_type
FROM products
LIMIT 10;
