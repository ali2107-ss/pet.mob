import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';
import '../theme.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoritesData = Provider.of<FavoriteProvider>(context);
    final favorites = favoritesData.items.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Таңдаулы'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: AppTheme.greyColor.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('Таңдаулы тізімі бос', style: TextStyle(fontSize: 18, color: AppTheme.greyColor)),
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
                    product: favorites[i],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsScreen(product: favorites[i]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
