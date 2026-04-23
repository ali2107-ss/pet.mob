-- 1. Сброс старых рейтингов и очистка таблицы оценок (для чистого старта)
UPDATE public.products SET rating = 0;
DELETE FROM public.product_ratings;

-- 2. Автоматическое создание профиля при регистрации пользователя
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name', 'user')
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Удаляем старый триггер, если он есть, чтобы избежать ошибок
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Создаем новый триггер
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 3. Добавление проверок (CHECK constraints) для существующих таблиц
ALTER TABLE public.cart_items 
  ADD CONSTRAINT cart_quantity_check CHECK (quantity > 0);

-- 4. Создание таблиц для системы заказов (История заказов)

-- Таблица заказов
CREATE TABLE IF NOT EXISTS public.orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.0,
  status TEXT DEFAULT 'pending', -- pending, processing, shipped, delivered, cancelled
  shipping_address_id UUID REFERENCES public.addresses ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Таблица товаров в заказе
CREATE TABLE IF NOT EXISTS public.order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES public.orders ON DELETE CASCADE NOT NULL,
  product_id TEXT NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  price_at_purchase DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- ВКЛЮЧЕНИЕ RLS (Row Level Security) для заказов
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- ПОЛИТИКИ БЕЗОПАСНОСТИ ДЛЯ ЗАКАЗОВ
-- Пользователи могут видеть только свои заказы
CREATE POLICY "Users can view own orders" ON public.orders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own orders" ON public.orders FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Пользователи могут видеть только товары из своих заказов
CREATE POLICY "Users can view own order items" ON public.order_items FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.orders 
    WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid()
  )
);
CREATE POLICY "Users can insert own order items" ON public.order_items FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.orders 
    WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid()
  )
);
