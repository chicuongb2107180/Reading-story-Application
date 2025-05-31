import 'package:pocketbase/pocketbase.dart';

import '../models/user.dart';
import './pocketbase_client.dart';

class UserService {
  String _getAvatarImageUrl(PocketBase pb, RecordModel usermodel) {
    final avatarImageName = usermodel.getStringValue('avatar');
    return pb.files.getUrl(usermodel, avatarImageName).toString();
  }

  String _getCoverImageUrl(PocketBase pb, RecordModel usermodel) {
    final coverImageName = usermodel.getStringValue('cover');
    return pb.files.getUrl(usermodel, coverImageName).toString();
  }

  Future<User> getUserbyId(String userId) async {
    try {
      userId = userId.replaceAll(RegExp(r'\[|\]'), '');
      final pb = await getPocketBaseInstance();
      final record = await pb.collection('users').getOne(userId);
      return User.fromJson(record.toJson()
        ..addAll({
          'url_avatar': _getAvatarImageUrl(pb, record),
          'url_cover': _getCoverImageUrl(pb, record),
        }));
    } catch (error) {
      print('Error getting user by id: $error');
      throw Exception('An error occurred');
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final pb = await getPocketBaseInstance();
      final records = await pb.collection('users').getFullList(
            sort: '-created',
          );
      return records.map((record) {
        return User.fromJson(record.toJson()
          ..addAll({
            'url_avatar': _getAvatarImageUrl(pb, record),
            'url_cover': _getCoverImageUrl(pb, record),
          }));
      }).toList();
    } catch (error) {
      print('Error getting all users: $error');
      throw Exception('An error occurred');
    }
  }
  Future<bool> deleteUser(String userId) async {
    try {
      final pb = await getPocketBaseInstance();
      await pb.collection('users').update(userId, body: {
        'role': 'banned',
      });
      return true;
    } catch (error) {
      print('Error deleting user: $error');
      return false;
    }
  }
  Future<bool> updateUserRole(String UserId, String newrole) async {
    try {
      final pb = await getPocketBaseInstance();
      final data = {
        'role': newrole,
      };
      await pb.collection('users').update(UserId, body: data);
      return true;
    } catch (error) {
      print('Error updating user role: $error');
      return false;
    }
  }

  Future<bool> updateViolatedUser(String userId, int newviolated) async {
    try {
      final pb = await getPocketBaseInstance();
      await pb.collection('users').update(userId, body: {
        'violated': newviolated,
      });
      return true;
    } catch (error) {
      print('Error updating violated user: $error');
      return false;
    }
  }
}
