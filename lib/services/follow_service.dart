
import '../models/user.dart';
import './pocketbase_client.dart';
import '../models/follow.dart';

class FollowService {
Future<Follow?> followUser(User follower, User following) async {
  try {
    final pb = await getPocketBaseInstance();
    final record = await pb.collection('follow').create(body: {
      'follower': follower.id,
      'following': following.id,
    });
    return Follow(
      follower: follower,
      following: following,
    );

  } catch (e) {
    print('Error while following user: $e');
    return null;
  }
}


  Future<void> unfollowUser(User follower, User following) async {
    final pb = await getPocketBaseInstance();
  try {
    final followModel = await pb.collection('follow').getFullList(
      filter: "follower ?~ '${follower.id}' && following ?~ '${following.id}'",
    );
    followModel.forEach((element) async {
      await pb.collection('follow').delete(element.id);
    });
  } catch (e) {
    print('Error unfollowing user: $e');
  }
  }

  Future<List<String>> getFollowers(User user) async {
    final pb = await getPocketBaseInstance();
    final String userId = user.id!;
    final records = await pb.collection('follow').getFullList(
       filter: 'following ?~ "$userId"',
      expand: 'follower',
    );
    return records.map((record) => record.getStringValue('follower')).toList();
  }

  Future<Map<String, dynamic>> getFollowing(User user) async {
    final pb = await getPocketBaseInstance();
    final records = await pb.collection('follows').getFullList(
      filter: "follower = '${user.id}'",
    );
    return {
      'following': records.map((record) => record.getStringValue('following')).toList(),
    };
  }
  // viết hàm kiểm tra xem user đã follow chưa
Future<bool> isFollowing(String follower_id, String following_id) async {
    try {
      final pb = await getPocketBaseInstance();
      final records = await pb.collection('follow').getFullList(
            filter: "follower ?~'$follower_id' && following ?~ '$following_id'",
            expand: 'follower,following',
          );
      return records.isNotEmpty;
    } catch (e) {
      print('Error checking if user is following: $e');
      return false;
    }
  }
}