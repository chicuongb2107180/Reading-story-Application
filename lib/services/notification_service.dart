import 'package:pocketbase/pocketbase.dart';
import '../models/notification.dart';
import 'pocketbase_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationService {
  Future<List<AppNotification>> fetchNotifications(String userId) async {
    try {
      final pb = await getPocketBaseInstance();

      final result = await pb.collection('notification').getFullList(
            sort: '-created',
            filter: 'userId="$userId"',
            expand: 'relatedNovelId,relatedChapterId.novel,relatedAuthorId,relatedChapterId',
          );

      List<AppNotification> notifications = [];

      for (var record in result) {
        final data = record.toJson();
        final expand = data['expand'] ?? {};
        String? imageUrl;
        String? relatedNovelId = data['relatedNovelId'];
        String? relatedChapterId = data['relatedChapterId'];
        String? relatedAuthorId = data['relatedAuthorId'];

        switch (data['type']) {
          case 'report':
            final chapter = expand['relatedChapterId'];
            relatedChapterId = chapter?['id'];
            print('relatedChapterId: $relatedChapterId');
            final novel = chapter?['expand']?['novel'];
            relatedNovelId = novel?['id'];
            imageUrl =
                '${dotenv.env['POCKETBASE_URL']}api/files/${novel?['collectionId']}/${novel?['id']}/${novel?['image_cover']}';
            break;
          case 'new_novel':
            final author = expand['relatedAuthorId'];
            relatedAuthorId = author?['id'];
            imageUrl =
                '${dotenv.env['POCKETBASE_URL']}api/files/${author?['collectionId']}/${author?['id']}/${author?['avatar']}';
            break;
          case 'new_chapter':
            final novel = expand['relatedNovelId'];
            relatedNovelId = novel?['id'];
            imageUrl = '${dotenv.env['POCKETBASE_URL']}api/files/${novel?['collectionId']}/${novel?['id']}/${novel?['image_cover']}';
            break;
          default:
            imageUrl = data['imageUrl'] ?? data['avatar'];
        }

        notifications.add(AppNotification(
          id: data['id'] ?? '',
          userId: data['userId'] ?? '',
          title: data['title'] ?? '',
          message: data['message'] ?? '',
          relatedNovelId: relatedNovelId,
          relatedChapterId: relatedChapterId,
          relatedAuthorId: relatedAuthorId,
          type: data['type'] ?? '',
          isRead: data['isRead'] ?? false,
          createdAt: DateTime.parse(data['createdAt'] ?? data['created']),
          imageUrl: imageUrl,
        ));
      }

      return notifications;
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    String? type,
    String? relatedNovelId,
    String? relatedChapterId,
    String? relatedAuthorId,
  }) async {
    try {
      final pb = await getPocketBaseInstance();
      await pb.collection('notification').create(body: {
        'userId': userId,
        'title': title,
        'message': message,
        'type': type ?? 'general',
        'relatedNovelId': relatedNovelId,
        'relatedChapterId': relatedChapterId,
        'relatedAuthorId': relatedAuthorId,
        'isRead': false,
      });
    } catch (e) {
      print('Error creating notification: $e');
    }
  }
  Future <void> markAsRead(String notificationId) async {
    try {
      final pb = await getPocketBaseInstance();
      await pb.collection('notification').update(notificationId, body: {
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
  Future<void> deleteNotification(String notificationId) async {
    try {
      final pb = await getPocketBaseInstance();
      await pb.collection('notification').delete(notificationId);
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
}
