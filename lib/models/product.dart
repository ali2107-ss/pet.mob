import '../utils/product_rating_helper.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final double rating;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.rating = 0.0,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    final double rawRating = (map['rating'] as num?)?.toDouble() ?? 0.0;

    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num).toDouble(),
      category: map['category'] ?? '',
      imageUrl: map['image_url'] ?? '',
      rating: ProductRatingHelper.resolveInitialRating(
        productId: map['id'] ?? '',
        productName: map['name'] ?? '',
        currentRating: rawRating,
      ),
    );
  }
}
