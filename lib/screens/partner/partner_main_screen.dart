import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/partner_provider.dart';
import '../../theme.dart';
import 'partner_dashboard_screen.dart';
import 'partner_products_screen.dart';
import 'partner_balance_screen.dart';

class PartnerMainScreen extends StatefulWidget {
  const PartnerMainScreen({super.key});

  @override
  State<PartnerMainScreen> createState() => _PartnerMainScreenState();
}

class _PartnerMainScreenState extends State<PartnerMainScreen> {
  int _currentIndex = 0;
  Timer? _refreshTimer;

  final List<Widget> _screens = [
    const PartnerDashboardScreen(),
    const PartnerProductsScreen(),
    const PartnerBalanceScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Загружаем данные из Supabase при входе в режим партнера
    Future.microtask(() async {
      final partnerProvider = Provider.of<PartnerProvider>(
        context,
        listen: false,
      );
      await partnerProvider.initializePartner();
    });

    // Периодический refresh каждые 10 секунд
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (mounted) {
        final partnerProvider = Provider.of<PartnerProvider>(
          context,
          listen: false,
        );
        await partnerProvider.refreshProductsFromSupabase();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.exit_to_app, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Выход из режима партнёра'),
          ],
        ),
        content: const Text(
          'Вы уверены, что хотите выйти из режима партнёра? Ваши товары останутся доступны покупателям.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Отмена',
              style: TextStyle(color: AppTheme.greyColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<PartnerProvider>().exitPartnerMode();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.white),
        Positioned.fill(
          child: Opacity(
            opacity: 0.25,
            child: Image.asset(
              'assets/images/pet_background.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.exit_to_app,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              onPressed: _confirmExit,
              tooltip: 'Выйти из режима партнёра',
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, Color(0xFFFFB385)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.storefront, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Партнёр',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Кнопка симуляции продаж для демо
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  final partner = context.read<PartnerProvider>();
                  if (partner.products.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Сначала добавьте товары!'),
                          ],
                        ),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    return;
                  }
                  partner.simulateRandomSales();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.celebration, color: Colors.white),
                          SizedBox(width: 8),
                          Text('🎉 Новые продажи!'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                tooltip: 'Симуляция продаж',
              ),
            ],
          ),
          body: IndexedStack(index: _currentIndex, children: _screens),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: AppTheme.greyColor,
              backgroundColor: Colors.white.withOpacity(0.95),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_outlined),
                  activeIcon: Icon(Icons.bar_chart),
                  label: 'Аналитика',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined),
                  activeIcon: Icon(Icons.inventory_2),
                  label: 'Товары',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  activeIcon: Icon(Icons.account_balance_wallet),
                  label: 'Баланс',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
