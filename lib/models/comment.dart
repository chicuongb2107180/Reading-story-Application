import 'user.dart';
class Comment {
  final String id;
  final User userId;
  final String? novelId;
  final String? chapterId;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.novelId,
    this.chapterId,
    required this.content,
    required this.createdAt,
  });

  Comment copyWith({
    String? id,
    User? userId,
    String? novelId,
    String? chapterId,
    String? content,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      novelId: novelId ?? this.novelId,
      chapterId: chapterId ?? this.chapterId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Comment.fromJson(Map<String, dynamic> data) {
    return Comment(
      id: data['id'],
      userId: data['user'],
      novelId: data['novel'],
      chapterId: data['chapter'],
      content: data['comment_content'],
      createdAt: DateTime.parse(data['updated']),
    );
  }

  Map<String, dynamic> toJson(bool isForChapter) {
    return {
      isForChapter ? 'chapter' : 'novel': isForChapter ? chapterId : novelId,
      'comment_content': content,
    };
  }
}
