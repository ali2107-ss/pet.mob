import '../utils/product_rating_helper.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final double rating;
  final int ratingCount;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.rating = 0.0,
    this.ratingCount = 0,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num).toDouble(),
      category: map['category'] ?? '',
      imageUrl: map['image_url'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ??
          ProductRatingHelper.starterRating(
            productId: map['id'] ?? '',
            productName: map['name'] ?? '',
          ),
      ratingCount: (map['rating_count'] as num?)?.toInt() ?? 0,
    );
  }
}
