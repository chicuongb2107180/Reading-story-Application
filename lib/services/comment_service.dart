import 'dart:math';
import 'package:pocketbase/pocketbase.dart';
import 'pocketbase_client.dart';
import '../models/comment.dart';
import '../models/user.dart';

class CommentService {
  String _getAvatarImageUrl(PocketBase pb, RecordModel commentmodel) {
    final RecordModel usermodel = commentmodel.expand['user']![0];
    final avatarImageName = usermodel.getStringValue('avatar');
    return pb.files.getUrl(usermodel, avatarImageName).toString();
  }

  String _getCoverImageUrl(PocketBase pb, RecordModel commentmodel) {
    final RecordModel usermodel = commentmodel.expand['user']![0];
    final coverImageName = usermodel.getStringValue('cover');
    return pb.files.getUrl(usermodel, coverImageName).toString();
  }

  Future<List<Comment>> fetchComments(String novelId,
      {bool isForChapter = false, String? chapterId}) async {
    final List<Comment> comments = [];

    try {
      final pb = await getPocketBaseInstance();

      // Chọn collection dựa trên loại comment
      final collectionName = isForChapter ? 'comment_chapter' : 'comment_novel';
      final List<String> filters = [];

      if (isForChapter && chapterId != null) {
        filters.add('chapter = "$chapterId"');
      } else {
        filters.add('novel = "$novelId"');
      }

      final filterQuery = filters.join(' && ');

      final commentModels = await pb.collection(collectionName).getFullList(
            filter: filterQuery,
            expand: 'user',
          );

      for (final commentModel in commentModels) {
        final commentjson = commentModel.toJson();
        final obj = {
          ...commentjson,
          'user': User.fromJson(commentjson['expand']['user']
            ..addAll({
              'url_avatar': _getAvatarImageUrl(pb, commentModel),
              'url_cover': _getCoverImageUrl(pb, commentModel),
            })),
        };
        print(obj);
        comments.add(Comment.fromJson(obj));
      }
      return comments;
    } catch (error) {
      print('Error fetching comments: $error');
      return comments;
    }
  }

  Future<Comment?> addComment(Comment comment,
      {bool isForChapter = false}) async {
    try {
      final pb = await getPocketBaseInstance();
      final userId = pb.authStore.model.id;
      // Chọn collection dựa trên loại comment
      final collectionName = isForChapter ? 'comment_chapter' : 'comment_novel';
      print(comment.toJson(isForChapter));

      final commentModel = await pb.collection(collectionName).create(body: {
        ...comment.toJson(isForChapter),
        'user': userId,
      });

      return comment.copyWith(id: commentModel.id, createdAt: DateTime.now());
    } catch (error) {
      print('Error adding comment: $error');
      return null;
    }
  }
}
