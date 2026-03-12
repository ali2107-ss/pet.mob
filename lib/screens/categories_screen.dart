import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/translation.dart';
import '../theme.dart';
import 'product_details_screen.dart';
import '../widgets/product_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final langCode = localeProvider.locale.languageCode;
    final t = AppTranslation.translations[langCode] ?? AppTranslation.translations['ru']!;

    // Using internal category keys as value, map string is label
    final categoriesMap = [
      {'key': 'Тамақ', 'label': t['cat_food']},
      {'key': 'Ойыншықтар', 'label': t['cat_toys']},
      {'key': 'Аксессуарлар', 'label': t['cat_accessories']},
      {'key': 'Гигиена', 'label': t['cat_hygiene']},
      {'key': 'Киімдер', 'label': t['cat_clothes']},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(t['catalog']!),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: categoriesMap.length,
        itemBuilder: (context, index) {
          final categoryKey = categoriesMap[index]['key']!;
          final categoryLabel = categoriesMap[index]['label']!;
          final categoryProducts = productData.getProductsByCategory(categoryKey);

          // Skip rendering if category has no products
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
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(t['see_all']!),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categoryProducts.length > 5 ? 5 : categoryProducts.length,
                    itemBuilder: (ctx, i) {
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 16),
                        child: ProductCard(
                          product: categoryProducts[i],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(product: categoryProducts[i]),
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
    );
  }
}
