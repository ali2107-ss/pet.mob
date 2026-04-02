import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/translation.dart';
import '../theme.dart';
import '../models/product.dart';
import 'product_details_screen.dart';
import '../widgets/product_card.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryKey;
  final String categoryLabel;

  const CategoryProductsScreen({
    super.key,
    required this.categoryKey,
    required this.categoryLabel,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  String _searchQuery = '';
  String _sortBy = 'default';

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final langCode = localeProvider.locale.languageCode;
    final t =
        AppTranslation.translations[langCode] ??
        AppTranslation.translations['ru']!;

    var categoryProducts = productData.getProductsByCategory(
      widget.categoryKey,
    );

    // Apply search
    if (_searchQuery.isNotEmpty) {
      categoryProducts = categoryProducts
          .where(
            (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Apply sorting
    categoryProducts = _applySorting(categoryProducts);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.categoryLabel),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar + sort
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: (Theme.of(context).cardTheme.color ?? Colors.white)
                          .withValues(alpha: 0.9),
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
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: t['search_hint'] ?? 'Іздеу...',
                        hintStyle: const TextStyle(
                          color: AppTheme.greyColor,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppTheme.primaryColor,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onSelected: (value) => setState(() => _sortBy = value),
                    itemBuilder: (_) => [
                      _buildSortItem(
                        'default',
                        'По умолчанию',
                        Icons.auto_awesome,
                      ),
                      _buildSortItem(
                        'price_asc',
                        'Цена ↑ (дешевле)',
                        Icons.arrow_upward,
                      ),
                      _buildSortItem(
                        'price_desc',
                        'Цена ↓ (дороже)',
                        Icons.arrow_downward,
                      ),
                      _buildSortItem('rating', 'Рейтинг ↓', Icons.star),
                      _buildSortItem(
                        'name',
                        'Название (А-Я)',
                        Icons.sort_by_alpha,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Products grid
          Expanded(
            child: categoryProducts.isEmpty
                ? Center(
                    child: Text(
                      t['no_products'] ?? 'Товары не найдены',
                      style: const TextStyle(color: AppTheme.greyColor),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: categoryProducts.length,
                    itemBuilder: (ctx, i) {
                      return ProductCard(
                        heroPrefix: 'cat_full_',
                        product: categoryProducts[i],
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsScreen(
                                product: categoryProducts[i],
                                heroPrefix: 'cat_full_',
                              ),
                            ),
                          );
                        },
                      );
                    },
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

  PopupMenuItem<String> _buildSortItem(
    String value,
    String label,
    IconData icon,
  ) {
    final isSelected = _sortBy == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.primaryColor : AppTheme.greyColor,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }
}
