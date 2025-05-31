import 'dart:io';
import 'category.dart';
import 'user.dart';

class Novel {
  final String? id;
  final String novelName;
  final String description;
  final bool isCompleted;
  final File? imageCover;
  final String urlImageCover;
  final File? imageAuthAvatar = null;
  final String? urlAuthAvatar = '';
  final int? totalChaptersPublished;
  final int? totalChaptersDraft;
  final int? totalViews;
  final double? progress;
  final List<Category>? categories;
  final bool? isStorage;
  final User? author;
  final int totalvotes;
  final double valuevotes;
  late bool isrepost = false;

  Novel({
    this.id,
    required this.novelName,
    required this.description,
    this.isCompleted = false,
    this.imageCover,
    this.urlImageCover = '',
    this.totalChaptersPublished,
    this.totalChaptersDraft,
    this.totalViews,
    this.progress,
    this.categories,
    this.isStorage,
    this.author,
    this.totalvotes = 0,
    this.valuevotes = 0.0,
    this.isrepost = false,
  });

  Novel copyWith({
    String? id,
    String? novelName,
    String? description,
    bool? isCompleted,
    String? author,
    File? imageCover,
    String? urlImageCover,
    int? totalChaptersPublished,
    int? totalChaptersDraft,
    int? totalViews,
    List<Category>? categories,
    bool ? isrepost,
  }) {
    return Novel(
      id: id ?? this.id,
      novelName: novelName ?? this.novelName,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      imageCover: imageCover ?? this.imageCover,
      urlImageCover: urlImageCover ?? this.urlImageCover,
      totalChaptersPublished:
          totalChaptersPublished ?? this.totalChaptersPublished,
      totalChaptersDraft: totalChaptersDraft ?? this.totalChaptersDraft,
      totalViews: totalViews ?? this.totalViews,
      categories: categories ?? this.categories,
       isrepost: isrepost ?? this.isrepost,
    );
  }

  bool hasImageCover() {
    return imageCover != null || urlImageCover.isNotEmpty;
  }

  bool hasAuthAvatar() {
    return imageAuthAvatar != null || urlAuthAvatar!.isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return {
      'novel_name': novelName,
      'description': description,
      'is_completed': isCompleted,
      'is_repost': isrepost,
    };
  }

  factory Novel.fromJson(Map<String, dynamic> json) {
    return Novel(
      id: json['id'],
      novelName: json['novel_name'],
      description: json['description'],
      isCompleted: json['is_completed'] == 1 || json['is_completed'] == true,
      urlImageCover: json['image_cover'] ?? '',
      totalChaptersPublished: json['totalChaptersPublished'] ?? 0,
      totalChaptersDraft: json['totalChaptersDraft'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      progress: json['progress'] ?? 0.0,
      categories: json['categories'] != null &&
              json['categories'] is Map<String, dynamic>
          ? (json['categories'] as Map<String, dynamic>)
              .values
              .map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      author: User.fromJson(json['expand']['author']),
      isStorage: json['isStorage'] == 1 || json['isStorage'] == true,
      totalvotes: json['totalvotes'] ?? 0,
      valuevotes: json['valuevotes'] ?? 0,
      isrepost: json['isrepost'] == 1 || json['isrepost'] == true,
    );
  }
}
