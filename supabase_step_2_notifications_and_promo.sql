-- =================───────────────────────────────────────────────
-- ПРИОРИТЕТ 5: Система Уведомлений
-- =================───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  body TEXT,
  type TEXT DEFAULT 'info',  -- order_update, promo, info
  is_read BOOLEAN DEFAULT false,
  related_order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
CREATE POLICY "Users can view own notifications" ON public.notifications
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;
CREATE POLICY "Users can update own notifications" ON public.notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- Триггер: уведомление при смене статуса заказа
CREATE OR REPLACE FUNCTION public.notify_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
  IF (OLD.status IS DISTINCT FROM NEW.status) THEN
    INSERT INTO public.notifications (user_id, title, body, type, related_order_id)
    VALUES (
      NEW.user_id,
      'Обновление заказа',
      'Статус вашего заказа #' || NEW.id || ' изменен на: ' || NEW.status,
      'order_update',
      NEW.id
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_order_status_notify ON public.orders;
CREATE TRIGGER trigger_order_status_notify
  AFTER UPDATE ON public.orders
  FOR EACH ROW EXECUTE FUNCTION public.notify_order_status_change();

-- =================───────────────────────────────────────────────
-- ПРИОРИТЕТ 6: Система Промокодов
-- =================───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.promo_codes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  discount_percent INTEGER NOT NULL CHECK (discount_percent > 0 AND discount_percent <= 100),
  is_active BOOLEAN DEFAULT true,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.promo_codes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can check promo codes" ON public.promo_codes FOR SELECT USING (true);

-- Таблица использованных промокодов (чтобы не использовать дважды)
CREATE TABLE IF NOT EXISTS public.promo_usages (
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  promo_id UUID REFERENCES public.promo_codes(id) ON DELETE CASCADE,
  used_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (user_id, promo_id)
);

ALTER TABLE public.promo_usages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own promo usages" ON public.promo_usages FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own promo usages" ON public.promo_usages FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Добавим пару тестовых промокодов
INSERT INTO public.promo_codes (code, discount_percent) 
VALUES ('WELCOME', 15), ('PETLOVE', 20)
ON CONFLICT (code) DO NOTHING;
