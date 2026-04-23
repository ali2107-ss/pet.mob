-- ================================================================
-- ПОЛНОЕ ОБНОВЛЕНИЕ БАЗЫ ДАННЫХ (безопасный запуск, удаляет дубли)
-- ================================================================

-- ────────────────────────────────────────────────────────────────
-- 1. ТАБЛИЦА РЕЙТИНГОВ
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.product_ratings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  product_id TEXT NOT NULL,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  UNIQUE(user_id, product_id)
);

ALTER TABLE public.product_ratings ENABLE ROW LEVEL SECURITY;

-- Удаляем старые политики перед созданием
DROP POLICY IF EXISTS "Anyone can view ratings" ON public.product_ratings;
DROP POLICY IF EXISTS "Users can insert own ratings" ON public.product_ratings;
DROP POLICY IF EXISTS "Users can update own ratings" ON public.product_ratings;

CREATE POLICY "Anyone can view ratings" ON public.product_ratings FOR SELECT USING (true);
CREATE POLICY "Users can insert own ratings" ON public.product_ratings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own ratings" ON public.product_ratings FOR UPDATE USING (auth.uid() = user_id);

-- ────────────────────────────────────────────────────────────────
-- 2. ТРИГГЕР АВТООБНОВЛЕНИЯ РЕЙТИНГА ТОВАРА
-- ────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.update_product_rating()
RETURNS TRIGGER AS $$
DECLARE
  target_product_id TEXT;
BEGIN
  IF (TG_OP = 'DELETE') THEN
    target_product_id := OLD.product_id;
  ELSE
    target_product_id := NEW.product_id;
  END IF;

  UPDATE public.products
  SET rating = (
    SELECT COALESCE(AVG(rating::DECIMAL), 0)
    FROM public.product_ratings
    WHERE product_id = target_product_id
  )
  WHERE id = target_product_id;

  IF (TG_OP = 'DELETE') THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_product_rating_change ON public.product_ratings;
CREATE TRIGGER trigger_product_rating_change
AFTER INSERT OR UPDATE OR DELETE ON public.product_ratings
FOR EACH ROW
EXECUTE FUNCTION public.update_product_rating();

-- ────────────────────────────────────────────────────────────────
-- 3. СБРОС СТАРЫХ ЗАХАРДКОЖЕННЫХ РЕЙТИНГОВ
-- ────────────────────────────────────────────────────────────────
UPDATE public.products SET rating = 0;
DELETE FROM public.product_ratings;

-- ────────────────────────────────────────────────────────────────
-- 4. АВТО-СОЗДАНИЕ ПРОФИЛЯ ПРИ РЕГИСТРАЦИИ
-- ────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name', 'user')
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ────────────────────────────────────────────────────────────────
-- 5. CHECK CONSTRAINT ДЛЯ КОРЗИНЫ
-- ────────────────────────────────────────────────────────────────
ALTER TABLE public.cart_items
  DROP CONSTRAINT IF EXISTS cart_quantity_check;
ALTER TABLE public.cart_items
  ADD CONSTRAINT cart_quantity_check CHECK (quantity > 0);

-- ────────────────────────────────────────────────────────────────
-- 6. ТАБЛИЦА ЗАКАЗОВ
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.0,
  status TEXT DEFAULT 'processing',
  shipping_address TEXT,
  payment_method TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Добавляем колонки если таблица уже существует
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS shipping_address TEXT;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS payment_method TEXT;

-- ────────────────────────────────────────────────────────────────
-- 7. ТАБЛИЦА ПОЗИЦИЙ ЗАКАЗА
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES public.orders ON DELETE CASCADE NOT NULL,
  product_id TEXT NOT NULL,
  product_name TEXT,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  price_at_purchase DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Добавляем колонки если таблица уже существует
ALTER TABLE public.order_items ADD COLUMN IF NOT EXISTS product_name TEXT;

-- ────────────────────────────────────────────────────────────────
-- 8. RLS И ПОЛИТИКИ ДЛЯ ЗАКАЗОВ
-- ────────────────────────────────────────────────────────────────
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own orders" ON public.orders;
DROP POLICY IF EXISTS "Users can insert own orders" ON public.orders;
DROP POLICY IF EXISTS "Users can view own order items" ON public.order_items;
DROP POLICY IF EXISTS "Users can insert own order items" ON public.order_items;

CREATE POLICY "Users can view own orders" ON public.orders
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own orders" ON public.orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own order items" ON public.order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own order items" ON public.order_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid()
    )
  );
