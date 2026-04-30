CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  phone TEXT,
  city TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_profiles_id ON profiles(id);
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profiles_select_own" ON profiles;
CREATE POLICY "profiles_select_own" ON profiles FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "profiles_insert_own" ON profiles;
CREATE POLICY "profiles_insert_own" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "profiles_update_own" ON profiles;
CREATE POLICY "profiles_update_own" ON profiles FOR UPDATE USING (auth.uid() = id);

-- Функция для автоматического создания профиля
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
EXCEPTION
  WHEN unique_violation THEN
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Включить RLS если еще не включен
ALTER TABLE promo_codes ENABLE ROW LEVEL SECURITY;

-- Удалить старые политики
DROP POLICY IF EXISTS "promo_codes_select_all" ON promo_codes;
DROP POLICY IF EXISTS "promo_codes_select_active" ON promo_codes;

-- Создать политику (все могут читать активные промокоды)
CREATE POLICY "promo_codes_select_all" ON promo_codes
  FOR SELECT USING (true);

-- ============================================
-- ЧАСТЬ 3: PROMO_USAGES
-- ============================================

CREATE TABLE IF NOT EXISTS promo_usages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  promo_id UUID NOT NULL REFERENCES promo_codes(id) ON DELETE CASCADE,
  used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, promo_id)
);

CREATE INDEX IF NOT EXISTS idx_promo_usages_user_id ON promo_usages(user_id);
CREATE INDEX IF NOT EXISTS idx_promo_usages_promo_id ON promo_usages(promo_id);

ALTER TABLE promo_usages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "promo_usages_select_own" ON promo_usages;
CREATE POLICY "promo_usages_select_own" ON promo_usages
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "promo_usages_insert_own" ON promo_usages;
CREATE POLICY "promo_usages_insert_own" ON promo_usages
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- ЧАСТЬ 4: ПРОВЕРКА И РЕЗУЛЬТАТЫ
-- ============================================

-- Показать структуру profiles
SELECT 'PROFILES STRUCTURE:' as info;
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'profiles' ORDER BY ordinal_position;

-- Показать структуру promo_codes
SELECT 'PROMO_CODES STRUCTURE:' as info;
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'promo_codes' ORDER BY ordinal_position;

-- Показать структуру promo_usages
SELECT 'PROMO_USAGES STRUCTURE:' as info;
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'promo_usages' ORDER BY ordinal_position;

-- Показать политики
SELECT 'POLICIES:' as info;
SELECT tablename, policyname FROM pg_policies 
WHERE tablename IN ('profiles', 'promo_codes', 'promo_usages')
ORDER BY tablename;
