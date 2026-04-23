import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/order_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/partner_provider.dart';
import 'providers/address_provider.dart';
import 'providers/payment_method_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/rating_provider.dart';
import 'screens/main_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Supabase. Замените ключи на ваши реальные!
  await Supabase.initialize(
    url: 'https://sxtjvdpuwidarlksnnat.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN4dGp2ZHB1d2lkYXJsa3NubmF0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxMzA4NDYsImV4cCI6MjA5MDcwNjg0Nn0.NYgX9o2z5ZOedkuHsfvGivDTaLjCID0D51JqehsYjBE',
  );

  runApp(const PetMobApp());
}

class PetMobApp extends StatelessWidget {
  const PetMobApp({super.key});

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
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => PaymentMethodProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider<ProductProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, productProvider, cart) {
            if (productProvider.items.isNotEmpty) {
              cart!.fetchCart(productProvider.items);
            }
            return cart!;
          },
        ),
        ChangeNotifierProxyProvider<ProductProvider, FavoriteProvider>(
          create: (_) => FavoriteProvider(),
          update: (_, productProvider, favorite) {
            if (productProvider.items.isNotEmpty) {
              favorite!.fetchFavorites(productProvider.items);
            }
            return favorite!;
          },
        ),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, child) {
          return MaterialApp(
            title: 'ЗооМаг Казахстан',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
