import 'package:flutter/foundation.dart';
import '../../models/user.dart';
import '../../services/follow_service.dart';
import '../../services/user_service.dart';

class FollowManager with ChangeNotifier {
  final FollowService _followService = FollowService();
  final UserService _userService = UserService();

  final Map<String, List<User>> _followers = {};
  final Map<String, List<User>> _following = {};

  List<User> getFollowers(String userId) {
    return _followers[userId] ?? [];
  }

  List<User> getFollowing(String userId) {
    return _following[userId] ?? [];
  }

  Future<void> fetchFollowers(User user) async {
    if (user.id == null || _followers.containsKey(user.id!)) return;
    _followers[user.id!] = [];
    final followerIds = await _followService.getFollowers(user);
    for (final id in followerIds) {
      final follower = await _userService.getUserbyId(id);
      _followers[user.id]!.add(follower);
    }
    notifyListeners();
  }

  Future<void> fetchFollowing(User user) async {
    if (user.id == null || _following.containsKey(user.id!)) return;
    _following[user.id!] = [];
    final followingIds = (await _followService.getFollowing(user)) as List<dynamic>;
    for (final id in followingIds) {
      final followingUser = await _userService.getUserbyId(id);
      _following[user.id]!.add(followingUser);
    }
    notifyListeners();
  }
}
