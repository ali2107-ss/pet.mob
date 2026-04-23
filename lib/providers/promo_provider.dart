import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PromoProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Проверяет промокод и возвращает процент скидки. 
  /// Если код неверный или истек, возвращает 0.
  Future<int> validatePromo(String code) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 0;

    try {
      // 1. Ищем промокод в базе
      final promoData = await _supabase
          .from('promo_codes')
          .select()
          .eq('code', code.toUpperCase())
          .eq('is_active', true)
          .maybeSingle();

      if (promoData == null) return 0;

      // 2. Проверяем срок действия
      if (promoData['expires_at'] != null) {
        final expiry = DateTime.parse(promoData['expires_at']);
        if (DateTime.now().isAfter(expiry)) return 0;
      }

      // 3. Проверяем, не использовал ли его этот пользователь уже
      final usage = await _supabase
          .from('promo_usages')
          .select()
          .eq('user_id', user.id)
          .eq('promo_id', promoData['id'])
          .maybeSingle();

      if (usage != null) {
        throw Exception('Вы уже использовали этот промокод');
      }

      return promoData['discount_percent'] as int;
    } catch (e) {
      debugPrint('Error validating promo: $e');
      rethrow;
    }
  }

  /// Фиксирует использование промокода
  Future<void> usePromo(String code) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final promoData = await _supabase
          .from('promo_codes')
          .select('id')
          .eq('code', code.toUpperCase())
          .single();

      await _supabase.from('promo_usages').insert({
        'user_id': user.id,
        'promo_id': promoData['id'],
      });
    } catch (e) {
      debugPrint('Error using promo: $e');
    }
  }
}
