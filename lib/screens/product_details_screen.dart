import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../theme.dart';
import 'cart_screen.dart';
import 'package:badges/badges.dart' as badges;
import '../l10n/translation.dart';
import '../providers/locale_provider.dart';
import '../providers/rating_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/network_or_base64_image.dart';
import '../widgets/star_rating.dart';
import 'auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/product_description_formatter.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final String heroPrefix;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.heroPrefix = '',
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    Future.microtask(() {
      if (mounted) {
        Provider.of<RatingProvider>(context, listen: false)
            .fetchUserRating(widget.product.id);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final langCode = localeProvider.locale.languageCode;
    final t =
        AppTranslation.translations[langCode] ??
        AppTranslation.translations['ru']!;
    final description = ProductDescriptionFormatter.detailedDescription(
      widget.product,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag:
                        '${widget.heroPrefix}product_image_${widget.product.id}',
                    child: NetworkOrBase64Image(
                      imageUrl: widget.product.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 56,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black45, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Consumer<FavoriteProvider>(
                builder: (ctx, favoriteProvider, child) {
                  final isFavorite = favoriteProvider.isFavorite(
                    widget.product.id,
                  );
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      favoriteProvider.toggleFavorite(widget.product);
                    },
                  );
                },
              ),
              Consumer<CartProvider>(
                builder: (_, cart, ch) => badges.Badge(
                  position: badges.BadgePosition.topEnd(top: 0, end: 3),
                  badgeAnimation: const badges.BadgeAnimation.scale(
                    animationDuration: Duration(milliseconds: 300),
                  ),
                  badgeContent: Text(
                    cart.totalItemsCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  child: ch!,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                transform: Matrix4.translationValues(0.0, -32.0, 0.0),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            t[_getCategoryKey(widget.product.category)] ??
                                widget.product.category,
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Consumer<ProductProvider>(
                              builder: (ctx, productProvider, _) {
                                final updatedProduct = productProvider.findById(widget.product.id);
                                return Text(
                                  updatedProduct.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).textTheme.bodyLarge?.color ??
                                        AppTheme.textColor,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.product.name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).textTheme.titleLarge?.color ??
                            AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t['description']!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).textTheme.titleLarge?.color ??
                            AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7F2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.12),
                        ),
                      ),
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              Theme.of(context).textTheme.bodyMedium?.color ??
                              AppTheme.greyColor,
                          height: 1.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t['rate_product'] ?? 'Оцените товар',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).textTheme.titleLarge?.color ??
                            AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Consumer<RatingProvider>(
                      builder: (ctx, ratingProvider, child) {
                        final userRating = ratingProvider.getUserRating(widget.product.id) ?? 0;
                        if (ratingProvider.isLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return StarRating(
                          rating: userRating,
                          onRatingChanged: (newRating) {
                              final auth = Supabase.instance.client.auth.currentUser;
                              if (auth == null) {
                                showDialog(
                                  context: context,
                                  builder: (dialogCtx) => AlertDialog(
                                    title: const Text('Требуется авторизация'),
                                    content: const Text('Для оценки товара необходимо войти в свой аккаунт.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(dialogCtx),
                                        child: const Text('Отмена'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(dialogCtx);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                                          );
                                        },
                                        child: const Text('Войти'),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }
                              final productProvider = Provider.of<ProductProvider>(context, listen: false);
                              ratingProvider.submitRating(widget.product.id, newRating, productProvider);
                            },
                          );
                        },
                    ),
                    const SizedBox(height: 100), // spacing for bottom nav
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t['price']!,
                    style: TextStyle(
                      color:
                          Theme.of(context).textTheme.bodyMedium?.color ??
                          AppTheme.greyColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₸${widget.product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Provider.of<CartProvider>(
                    context,
                    listen: false,
                  ).addItem(widget.product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${widget.product.name} ${t['added_to_cart']}',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: Text(t['to_cart']!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
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
}
