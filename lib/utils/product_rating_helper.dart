class ProductRatingHelper {
  static double resolveInitialRating({
    required String productId,
    required String productName,
    double? currentRating,
  }) {
    if (currentRating != null && currentRating > 0) {
      return currentRating;
    }

    final String seed = '$productId|$productName';
    int hash = 0;
    for (final codeUnit in seed.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }

    final double normalized = (hash % 8) / 10.0;
    return double.parse((4.1 + normalized).toStringAsFixed(1));
  }

  static double displayRating({
    required String productId,
    required String productName,
    required double currentRating,
  }) {
    return resolveInitialRating(
      productId: productId,
      productName: productName,
      currentRating: currentRating,
    );
  }
}
