import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  final String _userName = 'Айдар Нұрғалиев';
  final String _userCity = 'Атырау, Казахстан';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userCity => _userCity;

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
