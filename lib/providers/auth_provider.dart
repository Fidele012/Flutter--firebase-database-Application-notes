import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  AppUser? _user;
  bool _isLoading = false;
  String _errorMessage = '';

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Listen to auth state changes
    _authRepository.authStateChanges.listen((AppUser? user) {
      _user = user;
      notifyListeners();
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  Future<bool> signUp(String email, String password) async {
    try {
      _setLoading(true);
      clearError();

      final user = await _authRepository.signUpWithEmailAndPassword(
        email,
        password,
      );
      if (user != null) {
        _user = user;
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      clearError();

      final user = await _authRepository.signInWithEmailAndPassword(
        email,
        password,
      );
      if (user != null) {
        _user = user;
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authRepository.signOut();
      _user = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
}