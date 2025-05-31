import 'package:pocketbase/pocketbase.dart';

import 'package:http/http.dart' as http;
import '../models/user.dart';
import './pocketbase_client.dart';

class AuthService {
  String _getAvatarImageUrl(PocketBase pb, RecordModel usermodel) {
    final avatarImageName = usermodel.getStringValue('avatar');
    return pb.files.getUrl(usermodel, avatarImageName).toString();
  }

  String _getCoverImageUrl(PocketBase pb, RecordModel usermodel) {
    final coverImageName = usermodel.getStringValue('cover');
    return pb.files.getUrl(usermodel, coverImageName).toString();
  }


  void Function(User? user)? onAuthChange;
  AuthService({this.onAuthChange}) {
    if (onAuthChange != null) {
      getPocketBaseInstance().then((pb) {
        pb.authStore.onChange.listen((event) {
          onAuthChange!(event.model == null
              ? null
              : User.fromJson(event.model!.toJson()
                ..addAll({
                  'url_avatar': _getAvatarImageUrl(pb, event.model!),
                  'url_cover': _getCoverImageUrl(pb, event.model!),
                })));
        });
      });
    }
  }
  Future<User> signup(User user, String password) async {
    final pb = await getPocketBaseInstance();
    try {
      final record = await pb.collection('users').create(body: {
        ...user.toJson(),
        'password': password,
        'passwordConfirm': password,
        'emailVisibility': true,
      });
      await pb.collection('users').requestVerification(user.email!);
      return User.fromJson(record.toJson());
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message']);
      }
      throw Exception('An error occurred');
    }
  }


  Future<User> login(String username, String password) async {
    final pb = await getPocketBaseInstance();
    try {
      final authRecord =
          await pb.collection('users').authWithPassword(username, password);
      return User.fromJson(authRecord.record!.toJson()
        ..addAll({
          'url_avatar': _getAvatarImageUrl(pb, authRecord.record!),
          'url_cover': _getCoverImageUrl(pb, authRecord.record!),
        }));
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message']);
      }
      throw Exception('An error occurred');
    }
  }

  Future<void> logout() async {
    final pb = await getPocketBaseInstance();
    pb.authStore.clear();
  }

Future<User?> getUserFromStore() async {
    final pb = await getPocketBaseInstance();

    if (!pb.authStore.isValid) return null;

    try {
      // Lấy userId từ authStore
      final userId = pb.authStore.model.id;

      // Lấy dữ liệu user mới nhất từ server
      final freshRecord = await pb.collection('users').getOne(userId);

      return User.fromJson(freshRecord.toJson()
        ..addAll({
          'url_avatar': _getAvatarImageUrl(pb, freshRecord),
          'url_cover': _getCoverImageUrl(pb, freshRecord),
        }));
    } catch (e) {
      return null;
    }
  }


  Future<User> updateProfile(User user) async {
    final pb = await getPocketBaseInstance();
    try {
      final record = await pb.collection('users').update(
        user.id!,
        body: user.toJson(),
        files: [
          if (user.avatar != null)
            await http.MultipartFile.fromBytes(
              'avatar',
              await user.avatar!.readAsBytes(),
              filename: user.avatar!.uri.pathSegments.last,
            ),
          if (user.cover != null)
            await http.MultipartFile.fromBytes(
              'cover',
              await user.cover!.readAsBytes(),
              filename: user.cover!.uri.pathSegments.last,
            ),
        ],
      );
      pb.authStore.save(pb.authStore.token, record);
      onAuthChange!(User.fromJson(record.toJson()
        ..addAll({
          'url_avatar': _getAvatarImageUrl(pb, record),
          'url_cover': _getCoverImageUrl(pb, record),
        })));
      return user.copyWith(
        url_avatar: _getAvatarImageUrl(pb, record),
        url_cover: _getCoverImageUrl(pb, record),
      );
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message']);
      }
      throw Exception('An error occurred');
    }
  }

  Future<void> deleteAccount(String userId) async {
    final pb = await getPocketBaseInstance();
    try {
      await pb.collection('users').delete(userId);
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message']);
      }
      throw Exception('An error occurred');
    }
  }
}
