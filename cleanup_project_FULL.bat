@echo off
chcp 65001 >nul
echo ========================================
echo ОЧИСТКА ПРОЕКТА - ВАРИАНТ 3 (ПОЛНАЯ)
echo ========================================
echo.
echo ⚠️ ВНИМАНИЕ! Этот скрипт удалит:
echo - Пустые папки
echo - Старые версии файлов
echo - Документацию миграции
echo - Логи и тестовые файлы
echo - Python/Dart скрипты генерации
echo - Старые SQL скрипты
echo - Дублирующие инструкции
echo.
echo ⚠️ ВАЖНО: Сделайте backup перед запуском!
echo.
pause

echo.
echo Начинаю полную очистку...
echo.

REM Удаление пустых папок
echo [1/7] Удаление пустых папок...
if exist "code" rmdir /s /q "code"
if exist "assets\lottie" rmdir /s /q "assets\lottie"
echo ✅ Пустые папки удалены

REM Удаление логов и тестовых файлов
echo [2/7] Удаление логов и тестовых файлов...
if exist "build_log.txt" del /q "build_log.txt"
if exist "test_scraper.dart" del /q "test_scraper.dart"
if exist "test_wb.dart" del /q "test_wb.dart"
if exist "test_yahoo.dart" del /q "test_yahoo.dart"
echo ✅ Логи и тестовые файлы удалены

REM Удаление старых версий
echo [3/7] Удаление старых версий файлов...
if exist "OLD_product_provider_from_83ee1bb_parents.dart" del /q "OLD_product_provider_from_83ee1bb_parents.dart"
if exist "OLD_PRODUCTS_STRUCTURE_EXAMPLES.md" del /q "OLD_PRODUCTS_STRUCTURE_EXAMPLES.md"
if exist "old_provider_utf8.txt" del /q "old_provider_utf8.txt"
if exist "old_provider.txt" del /q "old_provider.txt"
if exist "current_provider.txt" del /q "current_provider.txt"
echo ✅ Старые версии удалены

REM Удаление документации миграции
echo [4/7] Удаление документации миграции...
if exist "MIGRATION_ANALYSIS_83ee1bb.md" del /q "MIGRATION_ANALYSIS_83ee1bb.md"
if exist "README_MIGRATION_ANALYSIS.md" del /q "README_MIGRATION_ANALYSIS.md"
if exist "COMPARISON_BEFORE_AFTER.md" del /q "COMPARISON_BEFORE_AFTER.md"
echo ✅ Документация миграции удалена

REM Удаление скриптов генерации
echo [5/7] Удаление скриптов генерации...
if exist "create_insert_sql.py" del /q "create_insert_sql.py"
if exist "extract_images_and_generate_sql.py" del /q "extract_images_and_generate_sql.py"
if exist "generate_products.py" del /q "generate_products.py"
if exist "generate_products.dart" del /q "generate_products.dart"
if exist "replace.py" del /q "replace.py"
if exist "check_dupes.dart" del /q "check_dupes.dart"
echo ✅ Скрипты генерации удалены

REM Удаление старых SQL скриптов
echo [6/7] Удаление старых SQL скриптов...
if exist "supabase_backend_updates.sql" del /q "supabase_backend_updates.sql"
if exist "supabase_fix_ratings.sql" del /q "supabase_fix_ratings.sql"
if exist "supabase_full_update.sql" del /q "supabase_full_update.sql"
if exist "supabase_step_1_fixes_and_pets.sql" del /q "supabase_step_1_fixes_and_pets.sql"
if exist "supabase_step_2_notifications_and_promo.sql" del /q "supabase_step_2_notifications_and_promo.sql"
if exist "supabase_update_images.sql" del /q "supabase_update_images.sql"
if exist "supabase_update_images_part1.sql" del /q "supabase_update_images_part1.sql"
if exist "supabase_update_images_part2.sql" del /q "supabase_update_images_part2.sql"
echo ✅ Старые SQL скрипты удалены

REM Удаление старых инструкций
echo [7/7] Удаление старых инструкций...
if exist "create_profiles_promo_tables.sql" del /q "create_profiles_promo_tables.sql"
if exist "create_profiles_promo_tables_FIXED.sql" del /q "create_profiles_promo_tables_FIXED.sql"
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
echo ✅ ПОЛНАЯ ОЧИСТКА ЗАВЕРШЕНА!
echo ========================================
echo.
echo Удалено:
echo - 2 пустые папки
echo - ~30 ненужных файлов
echo.
echo ✅ АКТУАЛЬНЫЕ ФАЙЛЫ СОХРАНЕНЫ:
echo.
echo 📄 Инструкции:
echo   - FIXED_SETUP_GUIDE.md (главная инструкция)
echo   - IMPROVEMENTS.md (рекомендации)
echo   - README.md (описание проекта)
echo   - CLEANUP_REPORT.md (этот отчет)
echo.
echo 📄 SQL скрипты:
echo   - setup_profiles_promo_UNIVERSAL.sql
echo   - add_test_promo_codes.sql
echo   - fix_cart_favorites_tables.sql
echo   - check_existing_tables.sql
echo   - check_tables_structure.sql
echo   - supabase_complete_setup.sql
echo   - supabase_setup.sql
echo   - supabase_setup_ratings.sql
echo   - supabase_insert_products.sql
echo.
echo 📁 Папки:
echo   - lib/ (код приложения)
echo   - assets/images/ (изображения)
echo   - android/, ios/, web/, windows/, linux/, macos/
echo   - supabase/migrations/
echo.
echo Проверьте работу приложения:
echo   flutter clean
echo   flutter pub get
echo   flutter run
echo.
pause
