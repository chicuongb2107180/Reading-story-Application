import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/novel.dart';
import '../../models/chapter.dart';
import '../../models/comment.dart';
import '../../manager/chapter_manager.dart';
import 'read_novel_content.dart';
import 'read_novel_appbar.dart';
import 'read_novel_bottomnavbar.dart';
import 'font_settings_dialog.dart';
import 'chapter_list_dialog.dart';
import 'comment_chapter.dart';
import '../../manager/theme_manager.dart';
import '../../manager/current_chapter_manager.dart';
import '../../manager/reading_manager.dart';
import '../../manager/comment_manager.dart';
import '../../manager/vote_manager.dart';
import '../../models/vote.dart';
import '../../manager/report_manager.dart';
import '../../models/report.dart';
import '../../manager/auth_manager.dart';

class ReadNovel extends StatefulWidget {
  final String id;
  final Novel novel;

  const ReadNovel({super.key, required this.id, required this.novel});

  @override
  State<ReadNovel> createState() => _ReadNovelState();
}

class _ReadNovelState extends State<ReadNovel> {
  bool _isVisible = true;
  Chapter? chapter;
  late ScrollController _scrollController;
  bool _isLoadingNextChapter = false;
  bool _shouldLoadNextChapter = false;
  List<Comment> comments = [];
  bool _isCommentsLoading = true;
  Vote? _vote;
  late Future<void> _initialLoad;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initialLoad =
        _loadChapter(widget.id); // Khởi tạo Future để tránh gọi lại nhiều lần
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  } 

  Future<void> _loadChapter(String chapterId) async {
    final chapterManager = context.read<ChapterManager>();
    final readingManager = context.read<ReadingManager>();
    final voteManager = context.read<VoteManager>();
    chapter = await chapterManager.getChapterById(chapterId);


    if (chapter != null) {
      await chapterManager.incrementViewCount(chapter!.id!);
      await readingManager.addReading(chapter!.id!, widget.novel.id!);
      await voteManager.fetchVote(widget.novel.id!);

      if (mounted) {
        setState(() {
          _vote = voteManager.vote;
        });

        context.read<CurrentChapterManager>().setCurrentChapter(chapter!);
        _fetchComments();
      }
    }
  }

  void _fetchComments() async {
    final commentManager = context.read<CommentManager>();
    setState(() {
      _isCommentsLoading = true;
    });

    final fetchedComments = await commentManager.loadComments(
      widget.novel.id!,
      isForChapter: true,
      chapterId: chapter?.id,
    );

    setState(() {
      comments = fetchedComments;
      _isCommentsLoading = false;
    });
  }

  void _handleVote(int stars) async {
    final voteManager = context.read<VoteManager>();

    if (stars == 0 && _vote != null) {
      await voteManager.deleteVote(widget.novel.id!);
    } else if (_vote != null) {
      await voteManager.updateVote(stars);
    } else {
      await voteManager.addVote(widget.novel.id!, stars);
    }
    setState(() {
      _vote = voteManager.vote;
    });
  }

  Future<void> _loadNextChapter() async {
    if (_isLoadingNextChapter || !_shouldLoadNextChapter) return;

    final chapterManager = context.read<ChapterManager>();
    final readingManager = context.read<ReadingManager>();
    final nextIndex = chapterManager.getChapterIndexById(chapter!.id!) + 1;

    if (nextIndex < chapterManager.chapters.length) {
      setState(() {
        _isLoadingNextChapter = true;
        _shouldLoadNextChapter = false;
      });

      await Future.delayed(const Duration(milliseconds: 100));

      setState(() {
        chapter = chapterManager.chapters[nextIndex];
        _isLoadingNextChapter = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        chapterManager.incrementViewCount(chapter!.id!);
        readingManager.addReading(chapter!.id!, widget.novel.id!);
        context.read<CurrentChapterManager>().setCurrentChapter(chapter!);
        _fetchComments();
      });

      _scrollController.jumpTo(0);
    }
  }

  void _showCommentDialog() {
    if (chapter != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: 0.67,
            child: CommentChapter(
              chapter: chapter!,
              novel: widget.novel,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var fontThemeManager = Provider.of<FontThemeManager>(context);

    return SafeArea(
      child: Scaffold(
        body: FutureBuilder<void>(
          future:
              _initialLoad, // Sử dụng Future đã khởi tạo để tránh gọi lại nhiều lần
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Stack(
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification) {
                        if (_scrollController.position.pixels ==
                            _scrollController.position.maxScrollExtent) {
                          _shouldLoadNextChapter = true;
                        }
                      }
                      return false;
                    },
                    child: GestureDetector(
                      onTap: () {
                        if (_shouldLoadNextChapter) {
                          _loadNextChapter();
                        }
                        _toggleVisibility();
                      },
                      child: chapter != null
                          ? NovelContent(
                              fontSize: fontThemeManager.fontSize,
                              selectedFont: fontThemeManager.fontFamily,
                              currentTheme: fontThemeManager.currentTheme,
                              chapter: chapter!,
                              scrollController: _scrollController,
                              commentCount: comments.length,
                              iscommentsLoading: _isCommentsLoading,
                              valuevotes: widget.novel.valuevotes,
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  AppBarWidget(
                    novel: widget.novel,
                    isVisible: _isVisible,
                    toggleVisibility: _toggleVisibility,
                    showChapterListDialog: () =>
                        showChapterListDialog(context, widget.novel, chapter!),
                    onReportPressed: _reportChapter,
                  ),
                  BottomNavBar(
                    isVisible: _isVisible,
                    showFontSettings: _showFontSettings,
                    showComment: _showCommentDialog,
                    onVote: _handleVote,
                    initialVote: _vote?.value ?? 0,
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  void _showFontSettings() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const FontSettingsDialog();
      },
    );
  }

  void _reportChapter() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _controller = TextEditingController();

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          title: Row(
            children: const [
              Icon(Icons.flag, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Báo cáo chương',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Vui lòng nhập lý do bạn muốn báo cáo chương này:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Nhập lý do tại đây...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final reason = _controller.text.trim();
                if (reason.isEmpty) return;

                final authManager = context.read<AuthManager>();
                final user = authManager.user;
                final reportManager = context.read<ReportManager>();

                final success = await reportManager.addReport(
                  Report(
                    id: '',
                    reporterId: user!.id,
                    reporterName: user.username,
                    novelId: widget.novel.id!,
                    novelName: widget.novel.novelName,
                    chapterId: chapter!.id!,
                    content: reason,
                    status: 'pending',
                    createdAt: DateTime.now(),
                    isrepost: widget.novel.isrepost,
                    reportedId: widget.novel.author?.id!,
                  ),
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Báo cáo đã được gửi!'
                          : 'Gửi báo cáo thất bại.',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('Gửi'),
            ),
          ],
        );
      },
    );
  }
}
