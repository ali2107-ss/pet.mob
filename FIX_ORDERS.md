# 🔧 ИСПРАВЛЕНИЕ: Заказы и таблица order_items

## ❌ ПРОБЛЕМА:
При оформлении заказа ошибка:
```
Could not find the 'price_at_purchase' column of 'order_items'
```

## ✅ ПРИЧИНА:
В таблице `order_items` в Supabase не хватает колонок:
- `price_at_purchase` - цена на момент покупки
- `product_name` - название товара
- `total` - итоговая сумма

---

## 🚀 РЕШЕНИЕ:

### ШАГ 1: Исправьте таблицу в Supabase (2 минуты)

1. Откройте Supabase → **SQL Editor**
2. Скопируйте файл **`fix_order_items_table.sql`**
3. Вставьте и нажмите **RUN** ▶️

Этот скрипт:
- ✅ Пересоздаст таблицу `order_items` с правильной структурой
- ✅ Добавит все необходимые колонки
- ✅ Настроит RLS политики
- ✅ Проверит таблицу `orders`

### ШАГ 2: Перезапустите приложение (1 минута)

```bash
flutter run
```

---

## 📊 ЧТО ИСПРАВЛЕНО:

### 1. Таблица order_items (БД)

**Было:**
```sql
CREATE TABLE order_items (
  id UUID,
  order_id UUID,
  product_id TEXT,
  quantity INTEGER,
  price NUMERIC  -- ❌ Неправильное имя
);
```

**Стало:**
```sql
CREATE TABLE order_items (
  id UUID,
  order_id UUID,
  product_id TEXT,
  product_name TEXT,           -- ✅ Название товара
  quantity INTEGER,
  price_at_purchase NUMERIC,   -- ✅ Цена на момент покупки
  total NUMERIC,                -- ✅ Итоговая сумма
  partner_id UUID,
  created_at TIMESTAMP
);
```

### 2. Код создания заказа (Dart)

**Файл:** `lib/providers/order_provider.dart`

**Исправлено:**
- ✅ Добавлено поле `total` при вставке
- ✅ Исправлен порядок полей
- ✅ Статус заказа: 'pending' вместо 'processing'
- ✅ Поле адреса: 'delivery_address' вместо 'shipping_address'

---

## 🎯 РЕЗУЛЬТАТ:

### До исправления:
- ❌ Ошибка при оформлении заказа
- ❌ Заказы не сохраняются
- ❌ В БД нет информации о товарах

### После исправления:
- ✅ Заказы оформляются успешно
- ✅ В таблице `orders` видны заказы
- ✅ В таблице `order_items` видны:
  - Название товара (`product_name`)
  - Цена на момент покупки (`price_at_purchase`)
  - Количество (`quantity`)
  - Итоговая сумма (`total`)

---

## 📝 СТРУКТУРА ЗАКАЗА В БД:

### Таблица orders:
```
id              | UUID
user_id         | UUID (кто заказал)
total_amount    | NUMERIC (общая сумма)
status          | TEXT (pending/completed/cancelled)
delivery_address| TEXT (адрес доставки)
payment_method  | TEXT (способ оплаты)
created_at      | TIMESTAMP
```

### Таблица order_items:
```
id                | UUID
order_id          | UUID (ссылка на orders)
product_id        | TEXT (ID товара)
product_name      | TEXT (название товара) ✅
quantity          | INTEGER (количество)
price_at_purchase | NUMERIC (цена на момент покупки) ✅
total             | NUMERIC (сумма за позицию) ✅
partner_id        | UUID (если партнерский товар)
created_at        | TIMESTAMP
```

---

## 🧪 ТЕСТИРОВАНИЕ:

### 1. Оформите заказ:
- Добавьте товары в корзину
- Перейдите в корзину
- Нажмите "Оформить заказ"
- Заполните адрес и способ оплаты
- Подтвердите заказ

### 2. Проверьте в Supabase:

**Таблица orders:**
```sql
SELECT * FROM orders ORDER BY created_at DESC LIMIT 5;
```

Должны увидеть:
- ID заказа
- ID пользователя
- Общую сумму
- Статус
- Адрес доставки

**Таблица order_items:**
```sql
SELECT 
  oi.product_name,
  oi.quantity,
  oi.price_at_purchase,
  oi.total,
  o.created_at
FROM order_items oi
JOIN orders o ON oi.order_id = o.id
ORDER BY o.created_at DESC
LIMIT 10;
```

Должны увидеть:
- ✅ Название товара
- ✅ Количество
- ✅ Цену на момент покупки
- ✅ Итоговую сумму

---

## ✅ ИТОГ:

**Выполните ШАГ 1 и ШАГ 2** - заказы будут работать!

**Время: ~3 минуты** ⏱️

**Результат: Заказы сохраняются с полной информацией о товарах! 🚀**
