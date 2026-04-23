class ProductRatingHelper {
  static const int starterWeight = 3;

  static double starterRating({
    required String productId,
    required String productName,
  }) {
    final String seed = '$productId|$productName';
    int hash = 0;
    for (final codeUnit in seed.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }

    final double normalized = (hash % 8) / 10.0;
    return double.parse((4.1 + normalized).toStringAsFixed(1));
  }

  static double combineRatings({
    required String productId,
    required String productName,
    required List<int> userRatings,
  }) {
    final double starter = starterRating(
      productId: productId,
      productName: productName,
    );

    if (userRatings.isEmpty) {
      return starter;
    }

    final double userAverage =
        userRatings.reduce((a, b) => a + b) / userRatings.length;
    final double combined =
        ((starter * starterWeight) + userRatings.reduce((a, b) => a + b)) /
        (starterWeight + userRatings.length);

    final double normalized = combined.clamp(1.0, 5.0);
    if (userRatings.length >= starterWeight) {
      return double.parse(userAverage.toStringAsFixed(1));
    }

    return double.parse(normalized.toStringAsFixed(1));
  }
}
