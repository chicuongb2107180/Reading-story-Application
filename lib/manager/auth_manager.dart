import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/follow_service.dart';

class AuthManager with ChangeNotifier {
  late final AuthService _authService;
  User? _loggedInUser;

  AuthManager() {
    _authService = AuthService(onAuthChange: (User? user) {
      _loggedInUser = user;
      notifyListeners();
    });
  }

  bool get isAuth {
    return _loggedInUser != null;
  }

  User? get user {
    return _loggedInUser;
  }

  Future<User> signup(User user, String password) {
    return _authService.signup(user, password);
  }

  Future<User> login(String username, String password) async {
    final user = await _authService.login(username, password);
    if (user.role == 'banned') {
      await logout(); // Đăng xuất nếu bị cấm
      throw Exception('Tài khoản của bạn đã bị cấm');
    }

    _loggedInUser = user;
    notifyListeners();
    return user;
  }

  Future<void> tryAutoLogin() async {
    final user = await _authService.getUserFromStore();
    if (user != null) {
      if (user.role == 'banned') {
        await logout(); // Đăng xuất nếu bị cấm
        return;
      }
      _loggedInUser = user;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    return _authService.logout();
  }

  Future<void> updateProfile(User user) async {
    final updatedUser = await _authService.updateProfile(user);
    _loggedInUser = updatedUser;
    notifyListeners();
  }

  Future<bool> isFollowing(String userId) async {
    if (_loggedInUser?.id != null) {
      return await FollowService().isFollowing(_loggedInUser!.id!, userId);
    }
    return false;
  }

  Future<void> followUser(User user) async {
    await FollowService().followUser(_loggedInUser!, user);
    notifyListeners();
  }

  Future<void> unfollowUser(User user) async {
    await FollowService().unfollowUser(_loggedInUser!, user);
    notifyListeners();
  }

  Future deleteAccount(User user) async {
    await AuthService().deleteAccount(user.id!);
  }
}
