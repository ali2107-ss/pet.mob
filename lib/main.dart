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
