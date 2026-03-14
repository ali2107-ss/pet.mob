import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = 'Айдар Нұрғалиев';
  String _userCity = 'Алматы, Казахстан';

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
