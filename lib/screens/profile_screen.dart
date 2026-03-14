import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import 'addresses_screen.dart';
import 'payment_methods_screen.dart';
import 'order_history_screen.dart';
import 'auth/login_screen.dart';
import 'map_screen.dart';
import '../l10n/translation.dart';
import '../l10n/translation.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/partner_provider.dart';
import 'partner/partner_main_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showLanguageSelector(BuildContext context, LocaleProvider localeProvider) {
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
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: Text(t['ru_lang']!),
                trailing: langCode == 'ru' ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
                onTap: () {
                  localeProvider.setLocale(const Locale('ru'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(t['kk_lang']!),
                trailing: langCode == 'kk' ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
                onTap: () {
                  localeProvider.setLocale(const Locale('kk'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(t['en_lang']!),
                trailing: langCode == 'en' ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
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

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final langCode = localeProvider.locale.languageCode;
    final t = AppTranslation.translations[langCode] ?? AppTranslation.translations['ru']!;

    final authProvider = Provider.of<AuthProvider>(context);
    final _isLoggedIn = authProvider.isLoggedIn;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(t['profile']!),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _showLanguageSelector(context, localeProvider),
          ),
          if (Provider.of<AuthProvider>(context).isLoggedIn)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                // Settings implementation
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (!_isLoggedIn) ...[
              const Icon(Icons.account_circle, size: 100, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                t['guest_mode']!,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                t['login_desc']!,
                style: const TextStyle(fontSize: 16, color: AppTheme.greyColor),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                  // Для демонстрации просто логинимся:
                  authProvider.login();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(t['login_register']!),
              ),
            ] else ...[
              const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&auto=format&fit=crop&w=100&q=80'),
              ),
              const SizedBox(height: 16),
              Text(
                authProvider.userName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textColor),
              ),
              const SizedBox(height: 4),
              Text(
                'aydarn@example.com',
                style: TextStyle(fontSize: 16, color: AppTheme.greyColor),
              ),
              const SizedBox(height: 4),
              Text(
                '+7 (705) 123 45 67',
                style: TextStyle(fontSize: 14, color: AppTheme.greyColor),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(t['edit_profile']!),
              ),
            ],
            
            const SizedBox(height: 32),
            _buildProfileMenuItem(
              context,
              icon: Icons.location_on_outlined,
              title: t['delivery_addresses']!,
              onTap: () {
                if (!_isLoggedIn) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
                  return;
                }
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddressesScreen()));
              },
            ),
            _buildProfileMenuItem(
              context,
              icon: Icons.payment_outlined,
              title: t['payment_methods']!,
              onTap: () {
                if (!_isLoggedIn) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
                  return;
                }
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()));
              },
            ),
            _buildProfileMenuItem(
              context,
              icon: Icons.history_outlined,
              title: t['order_history']!,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrderHistoryScreen()));
              },
            ),
            _buildProfileMenuItem(
              context,
              icon: Icons.local_offer_outlined,
              title: t['promocodes']!,
              onTap: () {
                if (!_isLoggedIn) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
                  return;
                }
              },
            ),
            _buildProfileMenuItem(
              context,
              icon: Icons.map_outlined,
              title: t['stores_map'] ?? 'Наши магазины',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MapScreen()));
              },
            ),
            if (_isLoggedIn) ...[
              const SizedBox(height: 24),
              // Кнопка режима партнёра
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, Color(0xFFFFB385)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.storefront, color: Colors.white),
                  ),
                  title: const Text('Режим партнёра', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  subtitle: const Text('Управляйте товарами и балансом', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PartnerMainScreen()),
                    );
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              _buildProfileMenuItem(
                context,
                icon: Icons.logout,
                title: t['logout']!,
                textColor: Colors.red,
                iconColor: Colors.red,
                showChevron: false,
                onTap: () {
                  authProvider.logout();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = AppTheme.textColor,
    Color iconColor = AppTheme.primaryColor,
    bool showChevron = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        trailing: showChevron ? const Icon(Icons.chevron_right, color: AppTheme.greyColor) : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
