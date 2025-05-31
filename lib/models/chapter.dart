import 'dart:io';

class Chapter {
  final String? id;
  final String title;
  final String content;
  final String novelId;
  final int count_view;
  final String status;
  final bool isRead;

  Chapter({
    this.id,
    required this.title,
    required this.novelId,
    required this.content,
    required this.count_view,
    required this.status,
    this.isRead = false,
  });

  Chapter copyWith({
    String? id,
    String? title,
    String? novelId,
    String? content,
    int? count_view,
    String? status,
  }) {
    return Chapter(
      id: id ?? this.id,
      title: title ?? this.title,
      novelId: novelId ?? this.novelId,
      content: content ?? this.content,
      count_view: count_view ?? this.count_view,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'novel': novelId,
      'content': content,
      'count_view': count_view,
      'status': status,
    };
  }

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      count_view: json['count_view'] as int,
      novelId: json['novel'] as String,
      status: json['status'] as String,
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
