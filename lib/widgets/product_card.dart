import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../theme.dart';
import '../l10n/translation.dart';
import '../providers/locale_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final String heroPrefix;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.heroPrefix = '',
  });

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final langCode = localeProvider.locale.languageCode;
    final t =
        AppTranslation.translations[langCode] ??
        AppTranslation.translations['ru']!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: Hero(
                      tag: '${heroPrefix}product_image_${product.id}',
                      child: _buildProductImage(),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Consumer<FavoriteProvider>(
                      builder: (ctx, favoriteProvider, child) {
                        final isFavorite = favoriteProvider.isFavorite(
                          product.id,
                        );
                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey[800],
                          ),
                          onPressed: () {
                            favoriteProvider.toggleFavorite(product);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t[_getCategoryKey(product.category)] ?? product.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.greyColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₸${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      _AddToCartButton(product: product),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryKey(String originalCategory) {
    switch (originalCategory) {
      case 'Корма':
        return 'cat_food';
      case 'Игрушки':
        return 'cat_toys';
      case 'Аксессуары':
        return 'cat_accessories';
      case 'Гигиена':
        return 'cat_hygiene';
      case 'Одежда':
        return 'cat_clothes';
      default:
        return 'see_all';
    }
  }

  Widget _buildProductImage() {
    Widget errorWidget = Container(
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Нет фото',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );

    Widget loadingWidget = Container(
      color: Colors.grey[100],
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
      ),
    );

    // Base64 изображение
    if (product.imageUrl.startsWith('data:image')) {
      try {
        final parts = product.imageUrl.split(',');
        if (parts.length > 1) {
          final bytes = base64Decode(parts[1].replaceAll(RegExp(r'\s+'), ''));
          return Image.memory(
            bytes,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => errorWidget,
          );
        }
      } catch (e) {
        return errorWidget;
      }
    }

    // URL изображение с кэшированием
    if (product.imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: product.imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => loadingWidget,
        errorWidget: (context, url, error) => errorWidget,
        fadeInDuration: const Duration(milliseconds: 300),
        memCacheWidth: 400, // Оптимизация памяти
      );
    }

    // Если URL пустой или неправильный
    return errorWidget;
  }
}

class _AddToCartButton extends StatefulWidget {
  final Product product;

  const _AddToCartButton({required this.product});

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    Provider.of<CartProvider>(context, listen: false).addItem(widget.product);

    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final langCode = localeProvider.locale.languageCode;
    final t =
        AppTranslation.translations[langCode] ??
        AppTranslation.translations['ru']!;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} ${t['added_to_cart']}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_shopping_cart,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
