import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tateworld/main.dart';
import '../../models/chapter.dart';
import '../../manager/chapter_manager.dart';
import '../../main.dart';
import '../../models/novel.dart';
import '../../manager/notification_manager.dart';
import '../../manager/follow_manager.dart';
import '../../manager/user_manager.dart';
import '../../manager/storage_manager.dart';

class WriteChapterScreen extends StatefulWidget {
  final Chapter? chapter;
  final Novel novel;

  const WriteChapterScreen({Key? key, this.chapter, required this.novel})
      : super(key: key);

  @override
  _WriteChapterScreenState createState() => _WriteChapterScreenState();
}

class _WriteChapterScreenState extends State<WriteChapterScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isPublished = false;
  bool _isSaving = false;
  bool _isDeleted = false; // Thêm cờ để kiểm tra trạng thái xóa chương

  String? _titleErrorText;
  String? _contentErrorText;

  @override
  void initState() {
    super.initState();
    if (widget.chapter != null) {
      _titleController.text = widget.chapter!.title;
      _contentController.text = widget.chapter!.content;
      _isPublished = widget.chapter!.status == 'published';
    }
  }

  Future<bool> _saveContent({required String status}) async {
    if (_isSaving || _isDeleted) return false;
    setState(() {
      _isSaving = true;
    });

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    setState(() {
      _titleErrorText = title.isEmpty ? 'Tiêu đề không được để trống' : null;
      _contentErrorText =
          content.isEmpty ? 'Nội dung không được để trống' : null;
    });

    if (title.isEmpty || content.isEmpty) {
      setState(() {
        _isSaving = false;
      });
      return false;
    }

    final chapter = Chapter(
      id: widget.chapter?.id,
      title: title,
      content: content,
      novelId: widget.novel.id!,
      count_view: widget.chapter?.count_view ?? 0,
      status: status,
    );

    final chapterManager = context.read<ChapterManager>();

    if (widget.chapter != null) {
      await chapterManager.updateChapter(chapter);
    } else {
      await chapterManager.addChapter(chapter);
    }

    setState(() {
      _isSaving = false;
    });

    if (status == 'published') {
      _isPublished = true;
      return true;
    }

    return false;
  }

  void _clearContent() {
    setState(() {
      _titleController.clear();
      _contentController.clear();
    });
  }

  Future<bool> _onWillPop() async {
    if (!_isDeleted && !_isPublished) {
      await _saveContent(status: 'draft');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Viết Truyện'),
          actions: [
            TextButton(
              onPressed: () async {
                final isPublishedbefore = widget.chapter?.status == 'published';
                final isPublished = await _saveContent(status: 'published');
                if (!isPublished) return;

                final chapterManager = context.read<ChapterManager>();
                final notificationManager = context.read<NotificationManager>();
                final currentUser = widget.novel.author;
                final publishedChapters = await chapterManager
                    .fetchPublishedChapters(widget.novel.id!);
                if (!isPublishedbefore) {
                  if (chapterManager.totalChapterPublished == 1) {
                    // Truyện vừa có chương đầu tiên => thông báo cho người theo dõi tác giả
                    final followManager = context.read<FollowManager>();
                    await followManager.fetchFollowers(currentUser!);
                    final followers =
                        followManager.getFollowers(currentUser.id!);

                    for (final follower in followers) {
                      await notificationManager.addNotification(
                        userId: follower.id!,
                        title: 'Truyện mới',
                        message:
                            'Tác giả ${currentUser.name} vừa đăng truyện mới xem ngay nào!',
                        relatedAuthorId: currentUser.id,
                        relatedNovelId: widget.novel.id,
                        type: 'new_novel',
                      );
                    }
                  } else {
                    final storageManager = context.read<StorageManager>();
                    await storageManager
                        .fetchStorageByNovelId(widget.novel.id!);
                    final storages = storageManager.getStorage();
                    for (final storage in storages) {
                      if (storage.userId != currentUser?.id) {
                        await notificationManager.addNotification(
                          userId: storage.userId!,
                          title: 'Truyện mới',
                          message:
                              'Truyện mà bạn yêu thích vừa đăng chương mới xem ngay nào!',
                          relatedNovelId: widget.novel.id,
                          relatedChapterId: widget.chapter?.id,
                          type: 'new_chapter',
                        );
                      }
                    }
                  }
                }

                if (mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const MainBottomNavigationBar(index: 3),
                    ),
                  );
                }
              },
              child: const Text(
                'Đăng',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            PopupMenuButton<String>(
              color: Theme.of(context).colorScheme.surface,
              icon: const Icon(Icons.delete),
              onSelected: (value) async {
                if (value == 'Xóa') {
                  if (widget.chapter != null) {
                    final chapterManager = context.read<ChapterManager>();
                    await chapterManager.deleteChapter(widget.chapter!.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chương đã được xóa thành công.'),
                      ),
                    );
                    setState(() {
                      _isDeleted = true;
                    });
                  } else {
                    _clearContent();
                  }
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Xóa',
                  child: Text('Xóa'),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Đặt Tiêu đề cho Chương Truyện của bạn',
                  errorText: _titleErrorText,
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Nhập nội dung truyện của bạn...',
                    errorText: _contentErrorText,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
