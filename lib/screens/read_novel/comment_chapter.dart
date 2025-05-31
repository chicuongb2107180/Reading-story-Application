import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chapter.dart';
import '../../models/novel.dart';
import '../../manager/comment_manager.dart';
import '../../models/comment.dart';
import '../../manager/auth_manager.dart';
import '../util/helper.dart';

class CommentChapter extends StatefulWidget {
  final Chapter chapter;
  final Novel novel;

  const CommentChapter({
    Key? key,
    required this.chapter,
    required this.novel,
  }) : super(key: key);

  @override
  _CommentChapterState createState() => _CommentChapterState();
}

class _CommentChapterState extends State<CommentChapter> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final commentManager = context.read<CommentManager>();

    commentManager
        .loadComments(widget.novel.id!, isForChapter: true, chapterId: widget.chapter.id)
        .then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Hàm thêm bình luận
  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    // Lấy thông tin người dùng đang đăng nhập
    final authManager = context.read<AuthManager>();
    final user = authManager.user;

    if (user == null) {
      // Nếu người dùng chưa đăng nhập
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để bình luận.')),
      );
      return;
    }

    // Tạo một đối tượng Comment mới
    final comment = Comment(
      id: '',
      userId: user,
      novelId: widget.novel.id,
      chapterId: widget.chapter.id,
      content: content,
      createdAt: DateTime.now(),
    );

    final commentManager = context.read<CommentManager>();

    // Gửi bình luận tới CommentManager (có thể gửi lên server hoặc cơ sở dữ liệu)
    final success = await commentManager.addComment(comment, isForChapter: true);

    if (success) {
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bình luận đã được gửi.')),
      );
      setState(() {
        _isLoading = true;
      });
      await commentManager.loadComments(widget.novel.id!, isForChapter: true, chapterId: widget.chapter.id);
      setState(() {
        _isLoading = false;
      });
    } else {
      // Thông báo khi gửi bình luận thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi bình luận thất bại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommentManager>(
      builder: (context, commentManager, _) {
        final comments = commentManager.comments;

        return Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Bình luận',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : comments.isEmpty
                        ? const Center(child: Text("Chưa có bình luận nào."))
                        : ListView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              return _buildCommentCard(
                                  context, comments[index]);
                            },
                          ),
              ),
              const Divider(height: 1, thickness: 1),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: _buildCommentInput(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentCard(BuildContext context, Comment comment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: comment.userId.url_avatar != null
                      ? NetworkImage(comment.userId.url_avatar!)
                      : const AssetImage('assets/images/default_avatar.png'),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userId.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    Text(
                      Helper.formatRelativeTime(comment.createdAt),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment.content,
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Viết bình luận...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: _addComment, // Gửi bình luận khi nhấn nút gửi
          ),
        ],
      ),
    );
  }
}
