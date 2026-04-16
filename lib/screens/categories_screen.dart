import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/translation.dart';
import '../theme.dart';
import '../models/product.dart';
import 'product_details_screen.dart';
import '../widgets/product_card.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _searchQuery = '';
  String _sortBy = 'default'; // default, price_asc, price_desc, rating, name
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final langCode = localeProvider.locale.languageCode;
    final t =
        AppTranslation.translations[langCode] ??
        AppTranslation.translations['ru']!;

    final categoriesMap = [
      {'key': 'Корма', 'label': t['cat_food']},
      {'key': 'Игрушки', 'label': t['cat_toys']},
      {'key': 'Аксессуары', 'label': t['cat_accessories']},
      {'key': 'Гигиена', 'label': t['cat_hygiene']},
      {'key': 'Одежда', 'label': t['cat_clothes']},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(t['catalog']!),
        centerTitle: true,
        automaticallyImplyLeading: false,
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
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(const Duration(milliseconds: 300), () {
                          setState(() => _searchQuery = value);
                        });
                      },
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
          // Categories list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: categoriesMap.length,
              itemBuilder: (context, index) {
                final categoryKey = categoriesMap[index]['key']!;
                final categoryLabel = categoriesMap[index]['label']!;
                var categoryProducts = productData.getProductsByCategory(
                  categoryKey,
                );

                // Apply search
                if (_searchQuery.isNotEmpty) {
                  categoryProducts = categoryProducts
                      .where(
                        (p) => p.name.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                      )
                      .toList();
                }

                // Apply sorting
                categoryProducts = _applySorting(categoryProducts);

                if (categoryProducts.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            categoryLabel,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.color ??
                                  AppTheme.textColor,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${categoryProducts.length} товар(ов)',
                                style: const TextStyle(
                                  color: AppTheme.greyColor,
                                  fontSize: 13,
                                ),
                              ),
                              if (categoryProducts.length > 5) ...[
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => CategoryProductsScreen(
                                          categoryKey: categoryKey,
                                          categoryLabel: categoryLabel,
                                        ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    t['see_all'] ?? 'Все',
                                    style: const TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categoryProducts.length > 5
                              ? 5
                              : categoryProducts.length,
                          itemBuilder: (ctx, i) {
                            return Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 16),
                              child: ProductCard(
                                heroPrefix: 'cat_',
                                product: categoryProducts[i],
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailsScreen(
                                        product: categoryProducts[i],
                                        heroPrefix: 'cat_',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryColor : null,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            const Icon(Icons.check, color: AppTheme.primaryColor, size: 18),
          ],
        ],
      ),
    );
  }
}
