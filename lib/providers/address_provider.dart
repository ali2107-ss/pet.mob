import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/address_model.dart';

class AddressProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<AddressModel> _addresses = [];

  List<AddressModel> get addresses => [..._addresses];

  Future<void> fetchAddresses() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', user.id);

      _addresses = (data as List).map((json) => AddressModel.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
    }
  }

  Future<void> addAddress(AddressModel address) async {
    try {
      await _supabase.from('addresses').insert(address.toJson());
      await fetchAddresses();
    } catch (e) {
      debugPrint('Error adding address: $e');
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _supabase.from('addresses').delete().eq('id', id);
      _addresses.removeWhere((element) => element.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting address: $e');
    }
  }

  Future<void> setDefaultAddress(String id) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Сначала убираем флаг default у всех адресов пользователя
      await _supabase.from('addresses').update({'is_default': false}).eq('user_id', user.id);
      // Ставим новому адресу
      await _supabase.from('addresses').update({'is_default': true}).eq('id', id);
      await fetchAddresses();
    } catch (e) {
      debugPrint('Error setting default address: $e');
    }
  }
}
