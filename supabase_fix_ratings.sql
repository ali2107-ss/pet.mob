-- Сброс всех рейтингов на 0, если у товара нет оценок пользователей
UPDATE public.products p
SET rating = COALESCE(
  (
    SELECT AVG(rating) 
    FROM public.product_ratings 
    WHERE product_id = p.id
  ), 
  0
);
