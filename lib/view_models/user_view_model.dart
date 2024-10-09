// lib/view_models/user_view_model.dart
import 'package:flutter/material.dart';
import '../model/user.dart';
import '../services/fb_service.dart';

class UserViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _currentUser;
  bool isLoading = false;
  String? errorMessage;

  UserModel? get currentUser => _currentUser;

  // Đăng ký người dùng
  Future<bool> register(String email, String password, String name) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      UserModel user = UserModel(id: '', email: email, password: password, name: name);
      await _firebaseService.registerUser(user);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Đăng nhập người dùng
  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      UserModel? user = await _firebaseService.loginUser(email, password);
      if (user != null) {
        _currentUser = user;
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        isLoading = false;
        errorMessage = 'Email hoặc mật khẩu không đúng.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Đăng xuất người dùng
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
