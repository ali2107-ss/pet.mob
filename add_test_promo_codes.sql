SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'promo_codes'
ORDER BY ordinal_position;

-- ============================================
-- ВАРИАНТ 1: Если есть колонка description
-- ============================================
-- Раскомментируйте, если в результате выше есть колонка description

/*
INSERT INTO promo_codes (code, discount_percent, description, is_active, expires_at) VALUES
('WELCOME10', 10, 'Скидка 10% для новых пользователей', true, NOW() + INTERVAL '30 days'),
('SUMMER20', 20, 'Летняя распродажа - скидка 20%', true, NOW() + INTERVAL '60 days'),
('VIP30', 30, 'VIP скидка 30%', true, NOW() + INTERVAL '90 days'),
('EXPIRED', 15, 'Истекший промокод (для теста)', true, NOW() - INTERVAL '1 day')
ON CONFLICT (code) DO NOTHING;
*/

-- ============================================
-- ВАРИАНТ 2: Если НЕТ колонки description
-- ============================================
-- Раскомментируйте, если в результате выше НЕТ колонки description

INSERT INTO promo_codes (code, discount_percent, is_active, expires_at) VALUES
('WELCOME10', 10, true, NOW() + INTERVAL '30 days'),
('SUMMER20', 20, true, NOW() + INTERVAL '60 days'),
('VIP30', 30, true, NOW() + INTERVAL '90 days'),
('EXPIRED', 15, true, NOW() - INTERVAL '1 day')
ON CONFLICT (code) DO NOTHING;

-- ============================================
-- ПРОВЕРКА ДОБАВЛЕННЫХ ПРОМОКОДОВ
-- ============================================

SELECT 
  code, 
  discount_percent,
  is_active,
  expires_at,
  expires_at > NOW() as is_valid,
  created_at
FROM promo_codes
ORDER BY discount_percent DESC;
