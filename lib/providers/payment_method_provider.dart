import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_card_model.dart';

class PaymentMethodProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<PaymentCardModel> _cards = [];

  List<PaymentCardModel> get cards => [..._cards];

  Future<void> fetchCards() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _supabase
          .from('payment_methods')
          .select()
          .eq('user_id', user.id);

      _cards = (data as List).map((json) => PaymentCardModel.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching cards: $e');
    }
  }

  Future<void> addCard(PaymentCardModel card) async {
    try {
      await _supabase.from('payment_methods').insert(card.toJson());
      await fetchCards();
    } catch (e) {
      debugPrint('Error adding card: $e');
    }
  }

  Future<void> deleteCard(String id) async {
    try {
      await _supabase.from('payment_methods').delete().eq('id', id);
      _cards.removeWhere((element) => element.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting card: $e');
    }
  }
}
