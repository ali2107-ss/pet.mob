import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/order_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/partner_provider.dart';
import 'screens/main_screen.dart';
import 'theme.dart';

void main() {
  runApp(const PetMobApp());
}

class PetMobApp extends StatelessWidget {
  const PetMobApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PartnerProvider()),
        ChangeNotifierProxyProvider<PartnerProvider, ProductProvider>(
          create: (_) => ProductProvider(),
          update: (_, partner, product) {
            product!.setPartnerProvider(partner);
            return product;
          },
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'ЗооМаг Казахстан',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
