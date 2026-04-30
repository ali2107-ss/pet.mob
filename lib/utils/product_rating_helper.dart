class ProductRatingHelper {
  /// Вычисляет рейтинг товара на основе ТОЛЬКО реальных отзывов пользователей
  static double combineRatings({
    required String productId,
    required String productName,
    required List<int> userRatings,
  }) {
    // Если нет отзывов - возвращаем 0.0
    if (userRatings.isEmpty) {
      return 0.0;
    }

    // Вычисляем средний рейтинг из реальных отзывов
    final double userAverage =
        userRatings.reduce((a, b) => a + b) / userRatings.length;

    // Округляем до 1 знака после запятой
    return double.parse(userAverage.toStringAsFixed(1));
  }
}
