import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';
import 'tip_detail_screen.dart';
import '../theme.dart';
import 'package:badges/badges.dart' as badges;
import '../providers/locale_provider.dart';
import '../l10n/translation.dart';
import '../widgets/product_card.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'dart:convert';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  List<String> _selectedFilterCategories = [];
  double _minPrice = 0;
  double _maxPrice = 10000;
  String _sortBy = 'popular';

  // Base keys instead of hardcoded localized strings
  final List<Map<String, dynamic>> _categories = [
    {'key': 'Барлығы', 'locale_key': 'see_all', 'icon': Icons.pets},
    {'key': 'Тамақ', 'locale_key': 'cat_food', 'icon': Icons.restaurant},
    {'key': 'Ойыншықтар', 'locale_key': 'cat_toys', 'icon': Icons.toys},
    {
      'key': 'Аксессуарлар',
      'locale_key': 'cat_accessories',
      'icon': Icons.content_cut,
    },
    {
      'key': 'Гигиена',
      'locale_key': 'cat_hygiene',
      'icon': Icons.cleaning_services,
    },
    {'key': 'Киімдер', 'locale_key': 'cat_clothes', 'icon': Icons.checkroom},
  ];

  String _searchQuery = '';
  late AnimationController _animationController;
  late ConfettiController _confettiController;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
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

    // First apply search, then apply category filter, then apply filters
    var displayedProducts = productData.search(_searchQuery);

    // Apply category filter
    if (_selectedCategoryIndex != 0) {
      displayedProducts = displayedProducts
          .where(
            (p) => p.category == _categories[_selectedCategoryIndex]['key'],
          )
          .toList();
    }

    // Apply price and category filters from filter dialog
    displayedProducts = productData
        .filterProducts(
          categories: _selectedFilterCategories.isEmpty
              ? null
              : _selectedFilterCategories,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          sortBy: _sortBy,
        )
        .where((p) => displayedProducts.contains(p))
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isLoggedIn) {
              return Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(auth.avatarUrl),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${t['hello_user']!}, ${auth.userName} 👋',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 12,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t['city']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.greyColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  const Icon(
                    Icons.pets,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t['login_title'] ?? 'ZooMag',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              );
            }
          },
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, ch) => badges.Badge(
              position: badges.BadgePosition.topEnd(top: 0, end: 3),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: AppTheme.primaryColor,
                padding: EdgeInsets.all(4),
              ),
              badgeAnimation: const badges.BadgeAnimation.scale(
                animationDuration: Duration(milliseconds: 300),
              ),
              badgeContent: Text(
                cart.totalItemsCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: ch!,
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
                },
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t['care_for']!,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textColor,
                    ),
                  ),
                  Text(
                    t['your_pet']!,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryColor,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).cardTheme.color ??
                                Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: t['search_hint']!,
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
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          _showFilterDialog(context, t);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.tune, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // PROMO BANNER
                  Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, Color(0xFFFFB385)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(
                            Icons.pets,
                            size: 150,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                t['discount_20']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                t['first_order']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  _confettiController.play();
                                  _showPromoDialog(context, t);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  t['get_btn']!,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    t['catalog'] ?? 'Категории',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          Theme.of(context).textTheme.titleLarge?.color ??
                          AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100, // Increased height for icon + text
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedCategoryIndex == index;
                        final localeKey = _categories[index]['locale_key'];
                        final displayLabel =
                            t[localeKey] ?? _categories[index]['key'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategoryIndex = index;
                              });
                            },
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : (Theme.of(context).cardTheme.color ?? Colors.white),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? AppTheme.primaryColor.withOpacity(
                                                0.3,
                                              )
                                            : Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _categories[index]['icon'],
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.greyColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  displayLabel,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : AppTheme.greyColor,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    t['tips_title'] ?? 'Полезные советы',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          Theme.of(context).textTheme.titleLarge?.color ??
                          AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: TipDetailScreen.getTips(langCode).length,
                      itemBuilder: (context, index) {
                        final tips = TipDetailScreen.getTips(langCode);
                        final tip = tips[index];
                        return _buildTipCard(
                          tip['title']!,
                          tip['image']!,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TipDetailScreen(
                                  title: tip['title']!,
                                  imageUrl: tip['image']!,
                                  content: tip['content']!,
                                  readTime: tip['readTime'] ?? '5 мин',
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
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: displayedProducts.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: AppTheme.greyColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              t['no_products']!,
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppTheme.greyColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          // CASCADING ANIMATION
                          final delay = index * 0.1;
                          final curvedAnimation = CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              delay.clamp(0.0, 1.0),
                              (delay + 0.4).clamp(0.0, 1.0),
                              curve: Curves.easeOutBack,
                            ),
                          );

                          return ScaleTransition(
                            scale: curvedAnimation,
                            child: FadeTransition(
                              opacity: curvedAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: ProductCard(
                          heroPrefix: 'home_',
                          product: displayedProducts[index],
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                transitionDuration: const Duration(
                                  milliseconds: 500,
                                ),
                                pageBuilder: (_, _, _) => ProductDetailsScreen(
                                  product: displayedProducts[index],
                                  heroPrefix: 'home_',
                                ),
                                transitionsBuilder: (_, animation, _, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    }, childCount: displayedProducts.length),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildTipCard(String title, String imageUrl, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: imageUrl.startsWith('data:image') 
                ? MemoryImage(base64Decode(imageUrl.split(',').last.replaceAll(RegExp(r'\s+'), ''))) as ImageProvider
                : NetworkImage(imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.4),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'New',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(Icons.arrow_forward, color: Colors.white70, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Читать',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, Map<String, String> t) {
    final provider = context.read<ProductProvider>();
    final locale = context.read<LocaleProvider>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _FilterDialogContent(
          t: t,
          provider: provider,
          locale: locale,
          onApplyFilters: (categories, minPrice, maxPrice, sortBy) {
            setState(() {
              _selectedFilterCategories = categories;
              _minPrice = minPrice;
              _maxPrice = maxPrice;
              _sortBy = sortBy;
            });
          },
          initialCategories: _selectedFilterCategories,
          initialMinPrice: _minPrice,
          initialMaxPrice: _maxPrice,
          initialSortBy: _sortBy,
        );
      },
    );
  }

  void _showPromoDialog(BuildContext context, Map<String, String> t) {
    // Звуки
    _playSuccessSound();
    // Вибрация
    Vibration.vibrate(duration: 500);
    Future.delayed(const Duration(milliseconds: 600), () {
      Vibration.vibrate(duration: 300);
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _PromoDialogContent(t: t, audioPlayer: _audioPlayer);
      },
    );
  }

  Future<void> _playSuccessSound() async {
    try {
      // Генерируем звук programmatically (встроенный системный звук)
      // Для Android и iOS используются встроенные звуки
      // Можно добавить свой звук позже в assets/sounds/success.mp3
    } catch (e) {
      debugPrint('Sound error: $e');
    }
  }
}

class _PromoDialogContent extends StatefulWidget {
  final Map<String, String> t;
  final AudioPlayer audioPlayer;

  const _PromoDialogContent({required this.t, required this.audioPlayer});

  @override
  State<_PromoDialogContent> createState() => _PromoDialogContentState();
}

class _PromoDialogContentState extends State<_PromoDialogContent>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rotateController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.9),
                Color(0xFFFFB385).withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Летающие лапки
              _buildPaw(top: 20, left: 10, delay: 0),
              _buildPaw(top: 40, right: 15, delay: 200),
              _buildPaw(bottom: 30, left: 20, delay: 400),
              _buildPaw(bottom: 20, right: 10, delay: 600),

              // Основной контент
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Звёзды вокруг текста
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildRotatingStars(),
                          Column(
                            children: [
                              const SizedBox(height: 20),
                              const Text('🎉', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 16),
                              const Text(
                                'ПОЗДРАВЛЯЕМ!',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Вы выиграли промокод',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Промокод с пульсирующим эффектом
                    ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 1.05).animate(
                        CurvedAnimation(
                          parent: _scaleController,
                          curve: const Interval(
                            0.6,
                            1.0,
                            curve: Curves.elasticIn,
                          ),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Ваш код',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.greyColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  AppTheme.primaryColor,
                                  Color(0xFFFFB385),
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'PROMO20',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      '✨ Скидка 20% на первый заказ ✨',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.95),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.t['ok'] ?? 'ОК',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaw({
    double? top,
    double? bottom,
    double? left,
    double? right,
    int delay = 0,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 800 + delay),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(
              (right != null ? -20 : 20) * (1 - value),
              (bottom != null ? -20 : 20) * (1 - value),
            ),
            child: Opacity(
              opacity: value,
              child: const Text('🐾', style: TextStyle(fontSize: 24)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRotatingStars() {
    return RotationTransition(
      turns: _rotateAnimation,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              child: Text('⭐', style: TextStyle(fontSize: 20)),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Text('✨', style: TextStyle(fontSize: 18)),
            ),
            Positioned(
              right: 0,
              child: Text('⭐', style: TextStyle(fontSize: 20)),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Text('✨', style: TextStyle(fontSize: 18)),
            ),
            Positioned(
              bottom: 0,
              child: Text('⭐', style: TextStyle(fontSize: 20)),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              child: Text('✨', style: TextStyle(fontSize: 18)),
            ),
            Positioned(
              left: 0,
              child: Text('⭐', style: TextStyle(fontSize: 20)),
            ),
            Positioned(
              left: 10,
              top: 10,
              child: Text('✨', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDialogContent extends StatefulWidget {
  final Map<String, String> t;
  final ProductProvider provider;
  final LocaleProvider locale;
  final Function(List<String>, double, double, String) onApplyFilters;
  final List<String> initialCategories;
  final double initialMinPrice;
  final double initialMaxPrice;
  final String initialSortBy;

  const _FilterDialogContent({
    required this.t,
    required this.provider,
    required this.locale,
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
    priceRange = RangeValues(
      widget.initialMinPrice,
      widget.initialMaxPrice == 0 ? 20000 : widget.initialMaxPrice,
    );
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
            // Header
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
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories
                    Text(
                      widget.t['category'] ?? 'Категории',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryChips(),
                    const SizedBox(height: 24),

                    // Price Range
                    Text(
                      '${widget.t['price'] ?? 'Цена'}: ${priceRange.start.toStringAsFixed(0)} - ${priceRange.end.toStringAsFixed(0)} ₸',
                      style: TextStyle(
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
                        setState(() {
                          priceRange = values;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Sort By
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
            // Buttons
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
                        // Apply filters via callback
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

  Widget _buildCategoryChips() {
    final categories = [
      'Тамақ',
      'Ойыншықтар',
      'Аксессуарлар',
      'Гигиена',
      'Киімдер',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = selectedCategories.contains(category);
        return FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedCategories.add(category);
              } else {
                selectedCategories.remove(category);
              }
            });
          },
          backgroundColor: Colors.white,
          selectedColor: AppTheme.primaryColor.withOpacity(0.3),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          ),
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryColor : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
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
          onChanged: (value) {
            setState(() {
              sortBy = value!;
            });
          },
          activeColor: AppTheme.primaryColor,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }
}
