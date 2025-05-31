import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';

class CommentManager extends ChangeNotifier {
  final CommentService _commentService = CommentService();
  List<Comment> _comments = [];

  List<Comment> get comments => _comments;

  Future<List<Comment>> loadComments(String novelId,
      {bool isForChapter = false, String? chapterId}) async {
    _comments = await _commentService.fetchComments(novelId,
        isForChapter: isForChapter, chapterId: chapterId);
    notifyListeners();
    return _comments;
  }

  Future<bool> addComment(Comment comment, {bool isForChapter = false}) async {
    final newComment =
        await _commentService.addComment(comment, isForChapter: isForChapter);

    if (newComment != null) {
      _comments.insert(0, newComment);
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeComment(String commentId) {
    _comments.removeWhere((comment) => comment.id == commentId);
    notifyListeners();
  }

  Future<void> updateComment(Comment updatedComment) async {
    final index =
        _comments.indexWhere((comment) => comment.id == updatedComment.id);
    if (index != -1) {
      _comments[index] = updatedComment;
      notifyListeners();
    }
  }
}
