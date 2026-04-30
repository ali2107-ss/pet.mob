@echo off
chcp 65001 >nul
echo ========================================
echo ОЧИСТКА ПРОЕКТА - ВАРИАНТ 2 (СРЕДНЯЯ)
echo ========================================
echo.
echo Этот скрипт удалит:
echo - Пустые папки (code, assets/lottie)
echo - Старые версии файлов (OLD_*, old_*)
echo - Документацию миграции
echo - Логи и тестовые файлы
echo.
echo ⚠️ ВАЖНО: Сделайте backup перед запуском!
echo.
pause

echo.
echo Начинаю очистку...
echo.

REM Удаление пустых папок
echo [1/5] Удаление пустых папок...
if exist "code" rmdir /s /q "code"
if exist "assets\lottie" rmdir /s /q "assets\lottie"
echo ✅ Пустые папки удалены

REM Удаление логов и тестовых файлов
echo [2/5] Удаление логов и тестовых файлов...
if exist "build_log.txt" del /q "build_log.txt"
if exist "test_scraper.dart" del /q "test_scraper.dart"
if exist "test_wb.dart" del /q "test_wb.dart"
if exist "test_yahoo.dart" del /q "test_yahoo.dart"
echo ✅ Логи и тестовые файлы удалены

REM Удаление старых версий
echo [3/5] Удаление старых версий файлов...
if exist "OLD_product_provider_from_83ee1bb_parents.dart" del /q "OLD_product_provider_from_83ee1bb_parents.dart"
if exist "OLD_PRODUCTS_STRUCTURE_EXAMPLES.md" del /q "OLD_PRODUCTS_STRUCTURE_EXAMPLES.md"
if exist "old_provider_utf8.txt" del /q "old_provider_utf8.txt"
if exist "old_provider.txt" del /q "old_provider.txt"
if exist "current_provider.txt" del /q "current_provider.txt"
echo ✅ Старые версии удалены

REM Удаление документации миграции
echo [4/5] Удаление документации миграции...
if exist "MIGRATION_ANALYSIS_83ee1bb.md" del /q "MIGRATION_ANALYSIS_83ee1bb.md"
if exist "README_MIGRATION_ANALYSIS.md" del /q "README_MIGRATION_ANALYSIS.md"
if exist "COMPARISON_BEFORE_AFTER.md" del /q "COMPARISON_BEFORE_AFTER.md"
echo ✅ Документация миграции удалена

REM Удаление старых инструкций (дубликаты)
echo [5/5] Удаление старых инструкций...
if exist "create_profiles_promo_tables.sql" del /q "create_profiles_promo_tables.sql"
if exist "PARTNER_SETUP.md" del /q "PARTNER_SETUP.md"
if exist "PARTNER_SUPABASE.md" del /q "PARTNER_SUPABASE.md"
if exist "SUPABASE_SETUP_GUIDE.md" del /q "SUPABASE_SETUP_GUIDE.md"
if exist "QUICK_START.md" del /q "QUICK_START.md"
if exist "FINAL_SETUP.md" del /q "FINAL_SETUP.md"
if exist "ALL_TABLES_GUIDE.md" del /q "ALL_TABLES_GUIDE.md"
if exist "SUPABASE_CHECKLIST.md" del /q "SUPABASE_CHECKLIST.md"
echo ✅ Старые инструкции удалены

echo.
echo ========================================
echo ✅ ОЧИСТКА ЗАВЕРШЕНА!
echo ========================================
echo.
echo Удалено:
echo - 2 пустые папки
echo - ~20 ненужных файлов
echo.
echo Актуальные файлы сохранены:
echo ✅ FIXED_SETUP_GUIDE.md - главная инструкция
echo ✅ setup_profiles_promo_UNIVERSAL.sql - настройка БД
echo ✅ add_test_promo_codes.sql - промокоды
echo ✅ fix_cart_favorites_tables.sql - корзина/избранное
echo.
echo Проверьте работу приложения:
echo flutter clean
echo flutter pub get
echo flutter run
echo.
pause
