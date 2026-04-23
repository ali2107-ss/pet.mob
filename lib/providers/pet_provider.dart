import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet_model.dart';

class PetProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Pet> _pets = [];
  bool _isLoading = false;

  List<Pet> get pets => [..._pets];
  bool get isLoading => _isLoading;

  PetProvider() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        fetchPets();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _pets = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchPets() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabase
          .from('pets')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      _pets = (data as List).map((json) => Pet.fromMap(json)).toList();
    } catch (e) {
      debugPrint('Error fetching pets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPet({
    required String name,
    required String species,
    required String breed,
    required String age,
    required String weight,
    required String imageUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase.from('pets').insert({
        'user_id': user.id,
        'name': name,
        'species': species,
        'breed': breed,
        'age': age,
        'weight': weight,
        'image_url': imageUrl,
      }).select().single();

      _pets.insert(0, Pet.fromMap(response));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding pet: $e');
      rethrow;
    }
  }

  Future<void> deletePet(String id) async {
    try {
      await _supabase.from('pets').delete().eq('id', id);
      _pets.removeWhere((pet) => pet.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting pet: $e');
      rethrow;
    }
  }
}
