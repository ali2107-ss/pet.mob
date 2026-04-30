# 🚀 БЫСТРЫЙ СТАРТ - Что делать прямо сейчас

## ✅ У вас уже есть Supabase проект!

URL: `https://sxtjvdpuwidarlksnnat.supabase.co`

---

## 📋 ШАГ 1: Выполните SQL скрипт (5 минут)

1. Откройте ваш проект Supabase: https://supabase.com/dashboard
2. Перейдите в **SQL Editor** (левое меню, иконка </> )
3. Нажмите **New query**
4. Скопируйте **ВЕСЬ** файл `supabase_complete_setup.sql`
5. Вставьте в редактор
6. Нажмите **RUN** (или Ctrl+Enter)

### ✅ Что создаст этот скрипт:
- Все необходимые таблицы (products, orders, partners и т.д.)
- Политики безопасности (RLS)
- Тестовые товары для проверки
- Промо-баннеры

---

## 📋 ШАГ 2: Проверьте таблицы (1 минута)

1. Перейдите в **Table Editor** (левое меню)
2. Убедитесь, что видите таблицы:
   - ✅ products
   - ✅ product_ratings
   - ✅ addresses
   - ✅ payment_methods
   - ✅ pets
   - ✅ notifications
   - ✅ promo_banners
   - ✅ partner_shops
   - ✅ partner_products
   - ✅ orders
   - ✅ order_items

3. Откройте таблицу **products** - там должно быть 5 тестовых товаров

---

## 📋 ШАГ 3: Включите Email Authentication (1 минута)

1. Перейдите в **Authentication** → **Providers** (левое меню)
2. Найдите **Email**
3. Убедитесь, что переключатель **Enable Email provider** включен (зеленый)
4. **Confirm email** - выключите (для тестирования)
5. Нажмите **Save**

---

## 📋 ШАГ 4: Запустите приложение (2 минуты)

Откройте терминал в папке проекта и выполните:

```bash
flutter clean
flutter pub get
flutter run
```

Выберите устройство (эмулятор или браузер):
- Для Android: выберите эмулятор Android
- Для Web: выберите Chrome

---

## 🎉 ГОТОВО! Проверьте работу:

### 1. Регистрация
- Откройте приложение
- Нажмите "Регистрация"
- Введите email и пароль
- Зарегистрируйтесь

### 2. Просмотр товаров
- На главном экране должны появиться 5 тестовых товаров
- Попробуйте открыть карточку товара

### 3. Корзина
- Добавьте товар в корзину
- Перейдите в корзину
- Проверьте, что товар там есть

---

## 🔧 Если что-то не работает:

### ❌ Ошибка: "relation does not exist"
**Решение:** Скрипт не выполнился. Повторите ШАГ 1.

### ❌ Ошибка: "Invalid API key"
**Решение:** Проверьте, что в `lib/main.dart` правильные ключи:
```dart
url: 'https://sxtjvdpuwidarlksnnat.supabase.co',
anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
```

### ❌ Товары не загружаются
**Решение:** 
1. Откройте Supabase → Table Editor → products
2. Проверьте, что там есть товары
3. Если нет - выполните снова `supabase_complete_setup.sql`

### ❌ Не могу зарегистрироваться
**Решение:**
1. Supabase → Authentication → Providers
2. Включите Email provider
3. Выключите "Confirm email"

### ❌ Flutter ошибки при запуске
**Решение:**
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📞 Дополнительная помощь

Если проблемы остались:

1. **Проверьте логи Supabase:**
   - Supabase Dashboard → Logs
   - Посмотрите последние ошибки

2. **Проверьте Flutter логи:**
   - В терминале будут показаны ошибки

3. **Откройте файлы:**
   - `SUPABASE_CHECKLIST.md` - подробный чек-лист
   - `IMPROVEMENTS.md` - рекомендации по улучшению

---

## 🎯 Следующие шаги (после запуска):

1. ✅ Добавьте свои товары в таблицу `products`
2. ✅ Загрузите изображения в Supabase Storage
3. ✅ Настройте партнерский функционал
4. ✅ Добавьте больше тестовых данных

---

## 📚 Полезные ссылки:

- Ваш Supabase проект: https://supabase.com/dashboard/project/sxtjvdpuwidarlksnnat
- Документация Supabase: https://supabase.com/docs
- Flutter Supabase: https://pub.dev/packages/supabase_flutter

---

**Время на настройку: ~10 минут** ⏱️

**Удачи! 🚀**
