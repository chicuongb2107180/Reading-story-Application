import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationManager with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => [..._notifications];

  int get unreadCount => _notifications.where((n) => !n.isRead).length;


  Future<void> fetchNotifications(String userId) async {
    _notifications = await _notificationService.fetchNotifications(userId);
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    await NotificationService().markAsRead(notificationId);
    final index =
        _notifications.indexWhere((noti) => noti.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }
  Future <void> markAllAsRead() async {
    for (final noti in _notifications) {
      if (!noti.isRead) {
        await NotificationService().markAsRead(noti.id);
        noti.isRead = true;
      }
    }
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    // await _notificationService.deleteNotification(notificationId);
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }
  Future<void> addNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    String? relatedNovelId,
    String? relatedChapterId,
    String? relatedAuthorId,
  }) async {
    await _notificationService.createNotification(
      userId: userId,
      title: title,
      message: message,
      type: type,
      relatedNovelId: relatedNovelId,
      relatedChapterId: relatedChapterId,
      relatedAuthorId: relatedAuthorId,
    );

    // Fetch lại danh sách để cập nhật
    await fetchNotifications(userId);
  }


}
