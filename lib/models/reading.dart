import 'novel.dart';
import 'chapter.dart';

class Reading {
  final String userId;
  final Chapter chapter;
  final Novel? novel;

  Reading({
    required this.userId,
    required this.chapter,
    this.novel,
  });

  Reading copyWith({
    String? userId,
    Chapter? chapter,
    Novel? novel,
  }) {
    return Reading(
      userId: userId ?? this.userId,
      chapter: chapter ?? this.chapter,
      novel: novel ?? this.novel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'chapter': chapter.toJson(),
      'novel': novel?.toJson(),
    };
  }

  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      userId: json['user'] as String,
      chapter:
          Chapter.fromJson(json['expand']['chapter'] as Map<String, dynamic>),
      novel: json['expand']['novel'] != null
          ? Novel.fromJson(json['expand']['novel'] as Map<String, dynamic>)
          : null,
    );
  }
}
