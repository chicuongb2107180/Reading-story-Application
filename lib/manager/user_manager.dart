import 'package:flutter/foundation.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';

class UserManager with ChangeNotifier {
  final UserService _userService = UserService();
  final List<User> _users = [];

  List<User> get users => _users;

  User? getUserById(String id) {
    if (_users.isEmpty) return null;
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // Hàm fetchUsers để lấy tất cả người dùng
  Future<void> fetchUsers() async {
    try {
      final fetchedUsers = await _userService
          .getAllUsers(); 
      _users.clear();
      _users.addAll(fetchedUsers);
      print("Fetched users: $_users");
      notifyListeners();
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  Future<User?> addUser(String userId) async {
    final existingUser = getUserById(userId);
    if (existingUser != null) {
      return existingUser;
    }

    final user = await _userService.getUserbyId(userId);
    _users.add(user);
    notifyListeners();
    return user;
  }
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _userService.updateUserRole(userId, newRole);
      final user = getUserById(userId);
      if (user != null) {
        user.role = newRole;
        notifyListeners();
      }
    } catch (e) {
      print("Lỗi cập nhật role: $e");
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _userService.deleteUser(userId);
      _users.removeWhere((user) => user.id == userId);
      notifyListeners();
    } catch (e) {
      print("Lỗi xóa người dùng: $e");
    }
  }

  Future<void> updateViolated(String userId, int newViolated) async {
    try {
      await _userService.updateViolatedUser(userId, newViolated);
      final user = getUserById(userId);
      if (user != null) {
        user.violated = newViolated;
        notifyListeners();
      }
    } catch (e) {
      print("Lỗi cập nhật violated: $e");
    }
  }
  Future<void> increaseViolation(String userId) async {
    final user = getUserById(userId);
    if (user != null) {
      final newViolated = (user.violated ?? 0) + 1;
      await updateViolated(userId, newViolated);
    } else {
      final fetchedUser = await _userService.getUserbyId(userId);
      if (fetchedUser != null) {
        _users.add(fetchedUser);
        final newViolated = (fetchedUser.violated ?? 0) + 1;
        await updateViolated(userId, newViolated);
      }
    }
  }



}
