import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? _user;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    _user = _supabase.auth.currentUser;
    _supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  bool get isLoggedIn => _user != null;
  String get userEmail => _user?.email ?? '';
  String get userName => _user?.userMetadata?['full_name'] ?? 'Без имени';
  String get userPhone => _user?.userMetadata?['phone'] ?? 'Номер не указан';
  String get userCity => _user?.userMetadata?['city'] ?? 'Атырау, Казахстан';
  String get avatarUrl => _user?.userMetadata?['avatar_url'] ?? 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';

  /// Регистрация. Возвращает true, если требуется подтверждение по коду из Email (OTP).
  Future<bool> register(String email, String password, String name, {String role = 'user'}) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': name,
        'role': role,
      },
    );
    // Если сессия пустая, значит нужно подтверждение почты
    return response.session == null && response.user != null;
  }

  /// Вход по паролю
  Future<void> login(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  /// Подтверждение почты через код (OTP)
  Future<void> verifyOTP(String email, String token) async {
    await _supabase.auth.verifyOTP(
      type: OtpType.signup,
      email: email,
      token: token,
    );
  }

  /// Выход
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  /// Обновление профиля (имя, телефон)
  Future<void> updateProfile({String? name, String? phone}) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['full_name'] = name;
    if (phone != null) updates['phone'] = phone;

    if (updates.isEmpty) return;

    // 1. Обновляем метаданные в Auth
    await _supabase.auth.updateUser(
      UserAttributes(
        data: updates,
      ),
    );

    // 2. Обновляем данные в таблице public.profiles
    if (_user != null) {
      await _supabase.from('profiles').update(updates).eq('id', _user!.id);
    }
    
    notifyListeners();
  }
}
