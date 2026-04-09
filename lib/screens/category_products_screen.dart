import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/translation.dart';

import '../models/product.dart';
import 'product_details_screen.dart';
import '../widgets/product_card.dart';
import '../theme.dart';

class _FilterDialogContent extends StatefulWidget {
  final Map<String, String> t;
  final Function(List<String>, double, double, String) onApplyFilters;
  final List<String> initialCategories;
  final double initialMinPrice;
  final double initialMaxPrice;
  final String initialSortBy;

  const _FilterDialogContent({
    required this.t,
    required this.onApplyFilters,
    required this.initialCategories,
    required this.initialMinPrice,
    required this.initialMaxPrice,
    required this.initialSortBy,
  });

  @override
  State<_FilterDialogContent> createState() => _FilterDialogContentState();
}

class _FilterDialogContentState extends State<_FilterDialogContent> {
  late List<String> selectedCategories;
  late RangeValues priceRange;
  late String sortBy;

  @override
  void initState() {
    super.initState();
    selectedCategories = widget.initialCategories.toList();
    priceRange = RangeValues(widget.initialMinPrice, widget.initialMaxPrice);
    sortBy = widget.initialSortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.t['filter'] ?? 'Фильтры',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor.withOpacity(0.1),
                      ),
                      child: Icon(Icons.close, color: AppTheme.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.t['price'] ?? 'Цена'}: ${priceRange.start.toStringAsFixed(0)} - ${priceRange.end.toStringAsFixed(0)} ₸',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RangeSlider(
                      values: priceRange,
                      min: 0,
                      max: 20000,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (RangeValues values) {
                        setState(() => priceRange = values);
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.t['sorting'] ?? 'Сортировка',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSortOptions(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedCategories = [];
                          priceRange = RangeValues(0, 20000);
                          sortBy = 'popular';
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.t['reset'] ?? 'Сбросить',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApplyFilters(
                          selectedCategories,
                          priceRange.start,
                          priceRange.end,
                          sortBy,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.t['apply'] ?? 'Применить',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOptions() {
    final options = [
      ('popular', widget.t['popular'] ?? 'Популярные'),
      (
        'price_low',
        '${widget.t['price'] ?? 'Цена'}: ${widget.t['low'] ?? 'низкие'}',
      ),
      (
        'price_high',
        '${widget.t['price'] ?? 'Цена'}: ${widget.t['high'] ?? 'высокие'}',
      ),
      ('rating', widget.t['by_rating'] ?? 'По рейтингу'),
    ];
    return Column(
      children: options.map((option) {
        return RadioListTile<String>(
          title: Text(option.$2),
          value: option.$1,
          groupValue: sortBy,
          onChanged: (value) => setState(() => sortBy = value!),
          activeColor: AppTheme.primaryColor,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }
}

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
  List<String> _selectedFilterCategories = [];
  double _minPrice = 0;
  double _maxPrice = 20000;
  String _filterSortBy = 'popular';

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

    // Apply filters from filter dialog
    if (_selectedFilterCategories.isNotEmpty ||
        _minPrice > 0 ||
        _maxPrice < 20000 ||
        _filterSortBy != 'popular') {
      categoryProducts = productData
          .filterProducts(
            categories: _selectedFilterCategories.isEmpty
                ? null
                : _selectedFilterCategories,
            minPrice: _minPrice,
            maxPrice: _maxPrice,
            sortBy: _filterSortBy,
          )
          .where((p) => p.category == widget.categoryKey)
          .toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      categoryProducts = categoryProducts
          .where(
            (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Apply sorting from sort menu
    if (_filterSortBy == 'popular') {
      categoryProducts = _applySorting(categoryProducts);
    }

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
                // Filter button
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white),
                    onPressed: () => _showFilterDialog(context, t),
                  ),
                ),
                const SizedBox(width: 8),
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

  void _showFilterDialog(BuildContext context, Map<String, String> t) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _FilterDialogContent(
          t: t,
          initialCategories: _selectedFilterCategories,
          initialMinPrice: _minPrice,
          initialMaxPrice: _maxPrice,
          initialSortBy: _filterSortBy,
          onApplyFilters: (categories, minPrice, maxPrice, sortBy) {
            setState(() {
              _selectedFilterCategories = categories;
              _minPrice = minPrice;
              _maxPrice = maxPrice;
              _filterSortBy = sortBy;
            });
          },
        );
      },
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
