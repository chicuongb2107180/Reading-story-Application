class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String? relatedNovelId;
  final String? relatedChapterId;
  final String? relatedAuthorId;
  final String type;
  late bool isRead;
  final DateTime createdAt;
  final String? imageUrl; // ảnh avatar của truyện hoặc tác giả

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.relatedNovelId,
    this.relatedChapterId,
    this.relatedAuthorId,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.imageUrl,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    print('AppNotification.fromJson: ${json['imageUrl']}');
    return AppNotification(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      relatedNovelId: json['relatedNovelId'],
      relatedChapterId: json['relatedChapterId'],
      relatedAuthorId: json['relatedAuthorId'],
      type: json['type'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? json['created']),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'relatedNovelId': relatedNovelId,
      'relatedChapterId': relatedChapterId,
      'relatedAuthorId': relatedAuthorId,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      userId: userId,
      title: title,
      message: message,
      relatedNovelId: relatedNovelId,
      relatedChapterId: relatedChapterId,
      relatedAuthorId: relatedAuthorId,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      imageUrl: imageUrl,
    );
  }
}
