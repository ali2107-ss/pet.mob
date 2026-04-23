-- ================================================================
-- ПРИОРИТЕТ 1: Исправление политики профилей
-- =================───────────────────────────────────────────────
-- Позволяет пользователям создавать свой профиль (на всякий случай, если триггер не сработал)
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- =================───────────────────────────────────────────────
-- ПРИОРИТЕТ 2: Очистка таблицы заказов
-- =================───────────────────────────────────────────────
-- Удаляем старую колонку, которая больше не нужна (мы используем текстовый адрес)
ALTER TABLE public.orders DROP COLUMN IF EXISTS shipping_address_id;

-- =================───────────────────────────────────────────────
-- ПРИОРИТЕТ 3: Таблица Питомцев
-- =================───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.pets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  species TEXT,        -- кот, собака и т.д.
  breed TEXT,
  age TEXT,           -- храним как текст (напр. "2 года"), как в UI
  weight TEXT,        -- храним как текст (напр. "5 кг"), как в UI
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.pets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own pets" ON public.pets;
CREATE POLICY "Users can manage own pets" ON public.pets
  USING (auth.uid() = user_id) 
  WITH CHECK (auth.uid() = user_id);
