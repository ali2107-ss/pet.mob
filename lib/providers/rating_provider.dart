import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'product_provider.dart';

class RatingProvider with ChangeNotifier {
  final Map<String, int> _userRatings = {}; // product_id -> rating
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  int? getUserRating(String productId) {
    return _userRatings[productId];
  }

  Future<void> fetchUserRating(String productId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('product_ratings')
          .select('rating')
          .eq('product_id', productId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        _userRatings[productId] = response['rating'] as int;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching rating: $e');
    }
  }

  Future<void> submitRating(String productId, int rating, ProductProvider productProvider) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await Supabase.instance.client.from('product_ratings').upsert({
        'user_id': user.id,
        'product_id': productId,
        'rating': rating,
      }, onConflict: 'user_id, product_id');

      _userRatings[productId] = rating;
      
      // Update the product list to reflect the new average rating 
      await productProvider.updateProductRatingLocal(productId);
      
    } catch (e) {
      debugPrint('RatingProvider: Error submitting rating: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
