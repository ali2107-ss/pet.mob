CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  phone TEXT,
  city TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_profiles_id ON profiles(id);

-- Включить RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Удалить старые политики
DROP POLICY IF EXISTS "profiles_select_own" ON profiles;
DROP POLICY IF EXISTS "profiles_insert_own" ON profiles;
DROP POLICY IF EXISTS "profiles_update_own" ON profiles;

-- Создать новые политики
CREATE POLICY "profiles_select_own" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "profiles_insert_own" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_update_own" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Функция для автоматического создания профиля при регистрации
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, phone, city, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Без имени'),
    COALESCE(NEW.raw_user_meta_data->>'phone', ''),
    COALESCE(NEW.raw_user_meta_data->>'city', 'Атырау, Казахстан'),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Триггер для автоматического создания профиля
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- 2. ТАБЛИЦА PROMO_CODES (Промокоды)
-- ============================================

CREATE TABLE IF NOT EXISTS promo_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  discount_percent INTEGER NOT NULL CHECK (discount_percent >= 0 AND discount_percent <= 100),
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_promo_codes_code ON promo_codes(code);
CREATE INDEX IF NOT EXISTS idx_promo_codes_active ON promo_codes(is_active);

-- Включить RLS
ALTER TABLE promo_codes ENABLE ROW LEVEL SECURITY;

-- Удалить старые политики
DROP POLICY IF EXISTS "promo_codes_select_all" ON promo_codes;

-- Создать новые политики (все могут читать активные промокоды)
CREATE POLICY "promo_codes_select_all" ON promo_codes
  FOR SELECT USING (is_active = true);

-- ============================================
-- 3. ТАБЛИЦА PROMO_USAGES (Использование промокодов)
-- ============================================

CREATE TABLE IF NOT EXISTS promo_usages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  promo_id UUID NOT NULL REFERENCES promo_codes(id) ON DELETE CASCADE,
  used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, promo_id)
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_promo_usages_user_id ON promo_usages(user_id);
CREATE INDEX IF NOT EXISTS idx_promo_usages_promo_id ON promo_usages(promo_id);

-- Включить RLS
ALTER TABLE promo_usages ENABLE ROW LEVEL SECURITY;

-- Удалить старые политики
DROP POLICY IF EXISTS "promo_usages_select_own" ON promo_usages;
DROP POLICY IF EXISTS "promo_usages_insert_own" ON promo_usages;

-- Создать новые политики
CREATE POLICY "promo_usages_select_own" ON promo_usages
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "promo_usages_insert_own" ON promo_usages
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- 4. ТЕСТОВЫЕ ДАННЫЕ (опционально)
-- ============================================

-- Добавить несколько тестовых промокодов
INSERT INTO promo_codes (code, discount_percent, description, is_active, expires_at) VALUES
('WELCOME10', 10, 'Скидка 10% для новых пользователей', true, NOW() + INTERVAL '30 days'),
('SUMMER20', 20, 'Летняя распродажа - скидка 20%', true, NOW() + INTERVAL '60 days'),
('VIP30', 30, 'VIP скидка 30%', true, NOW() + INTERVAL '90 days'),
('EXPIRED', 15, 'Истекший промокод (для теста)', true, NOW() - INTERVAL '1 day')
ON CONFLICT (code) DO NOTHING;

-- ============================================
-- 5. ПРОВЕРКА СОЗДАННЫХ ТАБЛИЦ
-- ============================================

-- Проверка структуры profiles
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'profiles'
ORDER BY ordinal_position;

-- Проверка структуры promo_codes
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'promo_codes'
ORDER BY ordinal_position;

-- Проверка структуры promo_usages
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'promo_usages'
ORDER BY ordinal_position;

-- Проверка тестовых промокодов
SELECT code, discount_percent, description, expires_at > NOW() as is_valid
FROM promo_codes
ORDER BY discount_percent DESC;

-- Проверка политик
SELECT tablename, policyname, cmd
FROM pg_policies 
WHERE tablename IN ('profiles', 'promo_codes', 'promo_usages')
ORDER BY tablename, policyname;