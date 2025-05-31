import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tateworld/models/notification.dart';

import '../../models/report.dart';
import '../../models/chapter.dart';
import '../../manager/user_manager.dart';
import '../util/helper.dart';
import '../../manager/report_manager.dart';
import '../../manager/novels_manager.dart';
import '../../manager/chapter_manager.dart';
import 'review_chapter.dart';
import '../../manager/notification_manager.dart';

class ReportDetailScreen extends StatefulWidget {
  final Report report;

  const ReportDetailScreen({Key? key, required this.report}) : super(key: key);

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  Chapter? _chapter;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchChapter();
  }

  Future<void> _fetchChapter() async {
    if (widget.report.chapterId == null) return;

    setState(() => _isLoading = true);
    final chapterManager = context.read<ChapterManager>();
    final chapter =
        await chapterManager.getChapterById(widget.report.chapterId!);
    setState(() {
      _chapter = chapter;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final isReviewed = report.status != 'pending';

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết tố cáo')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ảnh truyện
                  Center(
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          report.url_image_novelcover ?? '',
                          width: 180,
                          height: 240,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 100),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Thông tin truyện
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              report.novelName ?? 'Không rõ tên truyện',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Row(
                              children: [
                                Icon(
                                  report.isrepost ? Icons.warning : Icons.book,
                                  size: 16,
                                  color: report.isrepost
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  report.isrepost
                                      ? 'Truyện đăng lại'
                                      : 'Truyện gốc',
                                  style: TextStyle(
                                    color: report.isrepost
                                        ? Colors.orange
                                        : Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(report.url_reporteravatar ?? ''),
                              radius: 24,
                            ),
                            title: Text(report.reporterName ?? ''),
                            subtitle: Text(
                                'Tố cáo vào ${Helper.formatRelativeTime(report.createdAt)}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nội dung tố cáo
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📄 Nội dung tố cáo:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(report.content ?? '',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 12),
                          if (_chapter != null) ...[
                            const Text('📚 Chương bị tố cáo:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(_chapter!.title ?? '',
                                style: const TextStyle(fontSize: 16)),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.info_outline, size: 20),
                              const SizedBox(width: 8),
                              const Text('Trạng thái:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Text(
                                Helper.statusText(report.status),
                                style: TextStyle(
                                  color: Helper.statusColor(report.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Nút xem chương
                  if (_chapter != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final novelManager = context.read<NovelsManager>();
                          await novelManager.fetcNovelsbyId(report.novelId!);
                          final novel =
                              novelManager.getNovelById(report.novelId!);
                          if (novel != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReadOnlyNovelScreen(
                                  chapter: _chapter!,
                                  novel: novel,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Không tìm thấy truyện')),
                            );
                          }
                        },
                        icon: const Icon(Icons.visibility),
                        label: const Text('Xem chương bị tố cáo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Nút xử lý
                  if (!isReviewed)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              await context
                                  .read<ReportManager>()
                                  .updateReportStatus(report.id!, 'approve');
                              await context
                                  .read<UserManager>()
                                  .increaseViolation(report.reportedId!);

                              await context
                                  .read<NotificationManager>()
                                  .addNotification(
                                    userId: report.reportedId!,
                                    type: 'report',
                                    title: 'Vi phạm',
                                    message:
                                        'Truyện "${report.novelName}" của bạn vi phạm và bị tố cáo "${report.content}" tại Chương "${_chapter?.title ?? ''}"',
                                    relatedNovelId: report.novelId,
                                    relatedChapterId: report.chapterId,
                                  );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Đã đánh dấu là vi phạm')),
                              );
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Vi phạm'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              await context
                                  .read<ReportManager>()
                                  .updateReportStatus(report.id!, 'reject');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Đã đánh dấu là không vi phạm')),
                              );

                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Không vi phạm'),
                          ),
                        ),
                      ],
                    )
                ],
              ),
            ),
    );
  }
}
