import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int rating;
  final Function(int) onRatingChanged;
  final double size;

  const StarRating({
    super.key,
    this.rating = 0,
    required this.onRatingChanged,
    this.size = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
          ),
          color: Colors.orange,
          iconSize: size,
          onPressed: () {
            onRatingChanged(index + 1);
          },
        );
      }),
    );
  }
}
