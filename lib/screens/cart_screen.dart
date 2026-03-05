import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: AppTheme.greyColor.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('Ваша корзина пуста', style: TextStyle(fontSize: 18, color: AppTheme.greyColor)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final cartItem = cart.items.values.toList()[i];
                      final productId = cart.items.keys.toList()[i];
                      return _CartItemWidget(
                        id: cartItem.id,
                        productId: productId,
                        name: cartItem.product.name,
                        quantity: cartItem.quantity,
                        price: cartItem.product.price,
                        imageUrl: cartItem.product.imageUrl,
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Итого:',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                            ),
                            Text(
                              '\$${cart.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Оформление заказа...')),
                              );
                              cart.clear();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Оформить заказ'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CartItemWidget extends StatelessWidget {
  final String id;
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String imageUrl;

  const _CartItemWidget({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: const Icon(Icons.delete, color: Colors.white, size: 40),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<CartProvider>(context, listen: false).removeItem(productId);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 80, color: Colors.grey[200]),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: AppTheme.greyColor),
                  onPressed: () {
                    Provider.of<CartProvider>(context, listen: false).removeSingleItem(productId);
                  },
                ),
                Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
                  onPressed: () {
                    final product = Provider.of<CartProvider>(context, listen: false).items[productId]!.product;
                    Provider.of<CartProvider>(context, listen: false).addItem(product);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
