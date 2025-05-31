import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/notification_manager.dart';
import '../../models/notification.dart';
import '../../models/novel.dart';
import '../novels/novel_detail_screen.dart';
import '../../manager/novels_manager.dart';
import '../util/helper.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<NotificationManager>().notifications;

    return Scaffold(
      appBar: AppBar(title: const Text("Thông báo")),
      body: notifications.isEmpty
          ? const Center(child: Text("Không có thông báo nào."))
          : ListView.separated(
              padding: const EdgeInsets.all(12.0),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final noti = notifications[index];

                return GestureDetector(
                  onTap: () async {
                    if (!noti.isRead) {
                      await context
                          .read<NotificationManager>()
                          .markAsRead(noti.id);
                    }

                    if (noti.relatedNovelId != null) {
                      final novel = await context
                          .read<NovelsManager>()
                          .fetcNovelsbyId(noti.relatedNovelId!);
                      if (novel != null && context.mounted) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => NovelDetailScreen(novel: novel),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Không tìm thấy truyện tương ứng.')),
                        );
                      }
                    }
                  },
                  child: Card(
                    elevation: 4,
                    color: noti.isRead ? Colors.grey[100] : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            noti.imageUrl ?? '',
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        title: Text(
                          noti.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: noti.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              noti.message,
                              style: const TextStyle(fontSize: 14),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              Helper.formatRelativeTime(noti.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: !noti.isRead
                            ? const Icon(Icons.fiber_manual_record,
                                color: Colors.blue, size: 10)
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
