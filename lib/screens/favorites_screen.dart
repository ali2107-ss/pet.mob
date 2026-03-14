import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/translation.dart';
import '../widgets/product_card.dart';
import '../models/product.dart';
import 'product_details_screen.dart';
import '../theme.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _searchQuery = '';
  String _sortBy = 'default';

  @override
  Widget build(BuildContext context) {
    final favoritesData = Provider.of<FavoriteProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final langCode = localeProvider.locale.languageCode;
    final t = AppTranslation.translations[langCode] ?? AppTranslation.translations['ru']!;

    List<Product> favorites = favoritesData.items.values.toList();

    // Apply search
    if (_searchQuery.isNotEmpty) {
      favorites = favorites
          .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply sorting
    favorites = _applySorting(favorites);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(t['favorites'] ?? 'Таңдаулы'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search + sort bar
          if (favoritesData.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: (Theme.of(context).cardTheme.color ?? Colors.white).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: t['search_hint'] ?? 'Іздеу...',
                          hintStyle: const TextStyle(color: AppTheme.greyColor, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.sort, color: Colors.white),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onSelected: (value) => setState(() => _sortBy = value),
                      itemBuilder: (_) => [
                        _buildSortItem('default', 'По умолчанию', Icons.auto_awesome),
                        _buildSortItem('price_asc', 'Цена ↑ (дешевле)', Icons.arrow_upward),
                        _buildSortItem('price_desc', 'Цена ↓ (дороже)', Icons.arrow_downward),
                        _buildSortItem('rating', 'Рейтинг ↓', Icons.star),
                        _buildSortItem('name', 'Название (А-Я)', Icons.sort_by_alpha),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Content
          Expanded(
            child: favorites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 80, color: AppTheme.greyColor.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          favoritesData.items.isEmpty
                              ? (t['no_favorites'] ?? 'Таңдаулы тізімі бос')
                              : (t['no_products'] ?? 'Товары не найдены'),
                          style: const TextStyle(fontSize: 18, color: AppTheme.greyColor),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: favorites.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (ctx, i) {
                        return ProductCard(
                          heroPrefix: 'fav_',
                          product: favorites[i],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(product: favorites[i], heroPrefix: 'fav_'),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<Product> _applySorting(List<Product> products) {
    switch (_sortBy) {
      case 'price_asc':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        products.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
        products.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return products;
  }

  PopupMenuItem<String> _buildSortItem(String value, String label, IconData icon) {
    final isSelected = _sortBy == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: isSelected ? AppTheme.primaryColor : AppTheme.greyColor, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppTheme.primaryColor : null,
          )),
          if (isSelected) ...[
            const Spacer(),
            const Icon(Icons.check, color: AppTheme.primaryColor, size: 18),
          ],
        ],
      ),
    );
  }
}
