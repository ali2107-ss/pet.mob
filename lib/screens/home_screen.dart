import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';
import '../theme.dart';
import 'package:badges/badges.dart' as badges;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['Все', 'Корм', 'Игрушки', 'Аксессуары'];
  String _searchQuery = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductProvider>(context);
    final cartData = Provider.of<CartProvider>(context);
    
    // First apply search, then apply category filter.
    final searchedProducts = productData.search(_searchQuery);
    final displayedProducts = _selectedCategoryIndex == 0
        ? searchedProducts
        : searchedProducts.where((p) => p.category == _categories[_selectedCategoryIndex]).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('PetMob', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
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
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen()));
              },
            ),
          ),
          const SizedBox(width: 8),
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
                  const Text(
                    'Найдите лучшее',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const Text(
                    'для вашего питомца',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
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
                        hintText: 'Поиск товаров...',
                        hintStyle: const TextStyle(color: AppTheme.greyColor),
                        prefixIcon: const Icon(Icons.search, color: AppTheme.greyColor),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Категории',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategoryIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedCategoryIndex == index
                                    ? AppTheme.primaryColor
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: _selectedCategoryIndex == index
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryColor.withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                              ),
                              child: Text(
                                _categories[index],
                                style: TextStyle(
                                  color: _selectedCategoryIndex == index ? Colors.white : AppTheme.textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
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
                            Icon(Icons.search_off, size: 64, color: AppTheme.greyColor.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            const Text(
                              'Товары не найдены',
                              style: TextStyle(fontSize: 18, color: AppTheme.greyColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
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
                            product: displayedProducts[index],
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration: const Duration(milliseconds: 500),
                                  pageBuilder: (_, __, ___) => ProductDetailsScreen(product: displayedProducts[index]),
                                  transitionsBuilder: (_, animation, __, child) {
                                    return FadeTransition(opacity: animation, child: child);
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: displayedProducts.length,
                    ),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}
