-- Таблица для оценок продуктов пользователями
CREATE TABLE IF NOT EXISTS public.product_ratings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  product_id TEXT NOT NULL,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  UNIQUE(user_id, product_id)
);

ALTER TABLE public.product_ratings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view ratings" ON public.product_ratings FOR SELECT USING (true);
CREATE POLICY "Users can insert own ratings" ON public.product_ratings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own ratings" ON public.product_ratings FOR UPDATE USING (auth.uid() = user_id);

-- Функция для обновления рейтинга товара
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
    SELECT COALESCE(AVG(rating), 0)
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

-- Триггер для автоматического обновления рейтинга
DROP TRIGGER IF EXISTS trigger_product_rating_change ON public.product_ratings;
CREATE TRIGGER trigger_product_rating_change
AFTER INSERT OR UPDATE OR DELETE ON public.product_ratings
FOR EACH ROW
EXECUTE FUNCTION public.update_product_rating();
