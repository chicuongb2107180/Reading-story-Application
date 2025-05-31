import 'novel.dart';

class Storage {
  final String? userId;
  final String? novelId;
  final Novel? novel;
  final bool isStorage;

  Storage({
    this.userId,
    this.novelId,
    this.novel,
    this.isStorage = true,
  });

  Storage copyWith({
    String? userId,
    String? novelId,
    Novel? novel,
  }) {
    return Storage(
      userId: userId ?? this.userId,
      novelId: novelId ?? this.novelId,
      novel: novel ?? this.novel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'novel': novelId,
      'novelDetails': novel?.toJson(),
    };
  }

  factory Storage.fromJson(Map<String, dynamic> json) {
    return Storage(
      userId: json['user'] as String?,
      novelId: json['novel'] as String?,
      novel: json['expand']?['novel'] != null
          ? Novel.fromJson(json['expand']['novel'])
          : null,
    );
  }
}
