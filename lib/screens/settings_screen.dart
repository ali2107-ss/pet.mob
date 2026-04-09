import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../l10n/translation.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  void _showLanguageSelector(
    BuildContext context,
    LocaleProvider localeProvider,
  ) {
    final langCode = localeProvider.locale.languageCode;
    final t = AppTranslation.translations[langCode]!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  t['choose_language']!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: Text(t['ru_lang']!),
                trailing: langCode == 'ru'
                    ? const Icon(Icons.check, color: AppTheme.primaryColor)
                    : null,
                onTap: () {
                  localeProvider.setLocale(const Locale('ru'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(t['kk_lang']!),
                trailing: langCode == 'kk'
                    ? const Icon(Icons.check, color: AppTheme.primaryColor)
                    : null,
                onTap: () {
                  localeProvider.setLocale(const Locale('kk'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(t['en_lang']!),
                trailing: langCode == 'en'
                    ? const Icon(Icons.check, color: AppTheme.primaryColor)
                    : null,
                onTap: () {
                  localeProvider.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPasswordDialog(BuildContext context) {
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Смена пароля'),
        content: TextField(
          controller: passController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Новый пароль'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          TextButton(
            onPressed: () async {
              if (passController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Пароль должен быть не менее 6 символов')),
                );
                return;
              }
              await context.read<AuthProvider>().updatePassword(passController.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Пароль успешно изменен')),
              );
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Политика конфиденциальности'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Сбор данных: Мы собираем только те данные, которые необходимы для работы приложения: имя, телефон и адрес доставки.\n\n'
            '2. Использование: Данные используются исключительно для обработки ваших заказов и улучшения сервиса.\n\n'
            '3. Защита: Мы используем современные методы шифрования для защиты вашей информации. Ваши данные не передаются третьим лицам.\n\n'
            '4. Ваши права: Вы можете в любой момент изменить или удалить свои данные в настройках профиля.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Понятно')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final langCode = localeProvider.locale.languageCode;
    final t = AppTranslation.translations[langCode] ?? AppTranslation.translations['ru']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t['settings'] ?? 'Настройки'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Секция профиля
            Text(
              t['profile'] ?? 'Профиль',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: TextEditingController(text: context.read<AuthProvider>().userName),
                    decoration: InputDecoration(
                      labelText: t['full_name'] ?? 'Имя',
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    onSubmitted: (value) async {
                      await context.read<AuthProvider>().updateProfile(name: value);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Имя обновлено')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: t['phone_number'] ?? 'Номер телефона',
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                    onSubmitted: (value) async {
                      await context.read<AuthProvider>().updateProfile(phone: value);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Телефон обновлен')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Секция уведомлений
            Text(
              t['notifications'] ?? 'Уведомления',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: const Text(
                  'Включить уведомления',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                trailing: Switch(
                  value: _notificationsEnabled,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Секция внешнего вида
            Text(
              t['appearance'] ?? 'Внешний вид',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.language,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: Text(
                  t['language']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppTheme.greyColor,
                ),
                onTap: () => _showLanguageSelector(context, localeProvider),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.dark_mode_outlined,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: const Text(
                  'Темный режим',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Секция безопасности
            Text(
              t['security'] ?? 'Безопасность',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: const Text(
                  'Изменить пароль',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppTheme.greyColor,
                ),
                onTap: () => _showPasswordDialog(context),
              ),
            ),
            const SizedBox(height: 32),

            // Секция информации
            Text(
              t['about'] ?? 'О приложении',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Icon(Icons.info_outline, color: AppTheme.primaryColor),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Версия приложения',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '1.0.0',
                      style: TextStyle(fontSize: 14, color: AppTheme.greyColor),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: const Text(
                  'Политика конфиденциальности',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppTheme.greyColor,
                ),
                onTap: () => _showPrivacyPolicy(context),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
