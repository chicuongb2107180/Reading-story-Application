import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Report {
  final String? id;
  final String? novelId;
  final String? reporterId;
  final String? chapterId;
  final String? chapterTitle;
  final String content;
  final String status;
  final String? novelName;
  final File? image_novelcover;
  final String? url_image_novelcover;
  final File? image_reporteravatar;
  final String? url_reporteravatar;
  final DateTime createdAt;
  final String reporterName;
  final  bool isrepost;
  final String? reportedId;
  Report({
    this.id,
    this.novelId,
    this.reporterId,
    this.chapterId,
    this.chapterTitle,
    required this.content,
    required this.status,
    this.novelName,
    this.image_novelcover,
    this.url_image_novelcover = '',
    this.image_reporteravatar,
    this.url_reporteravatar = '',
    required this.createdAt,
    required this.reporterName,
    required this.isrepost,
    required this.reportedId,
  });
  Report copyWith({
    String? id,
    String? novelId,
    String? reporterId,
    String? chapterId,
    String? chapterTitle,
    String? content,
    String? status,
    String? novelName,
    File? image_novelcover,
    String? url_image_novelcover,
    File? image_reporteravatar,
    String? url_reporteravatar,
    DateTime? createdAt,
    String? reporterName,
    bool? isreport,
  }) {
    return Report(
      id: id ?? this.id,
      novelId: novelId ?? this.novelId,
      reporterId: reporterId ?? this.reporterId,
      chapterId: chapterId ?? this.chapterId,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      content: content ?? this.content,
      status: status ?? this.status,
      novelName: novelName ?? this.novelName,
      image_novelcover: image_novelcover ?? this.image_novelcover,
      url_image_novelcover: url_image_novelcover ?? this.url_image_novelcover,
      image_reporteravatar: image_reporteravatar ?? this.image_reporteravatar,
      url_reporteravatar: url_reporteravatar ?? this.url_reporteravatar,
      createdAt: createdAt ?? this.createdAt,
      reporterName: reporterName ?? this.reporterName,
      isrepost: isreport ?? this.isrepost,
      reportedId: reportedId ?? this.reportedId,
    );
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    final pocketbaseUrl = dotenv.env['POCKETBASE_URL'] ?? '';

    final novelCover = json['novel_cover'] as String?;
    final reporterAvatar = json['reporter_avatar'] as String?;

    final imageCoverUrl = (novelCover != null && novelCover.isNotEmpty)
        ? '$pocketbaseUrl/api/files/${json['collectionId']}/${json['id']}/$novelCover'
        : '';

    final avatarUrl = (reporterAvatar != null && reporterAvatar.isNotEmpty)
        ? '$pocketbaseUrl/api/files/${json['collectionId']}/${json['id']}/$reporterAvatar'
        : '';
        print('FULL JSON: $json');
    print('EXPAND: ${json['expand']}');
    print('EXPAND author: ${json['expand']['novel_id']['expand']['author']['id']}');


    return Report(
      id: json['id'] as String?,
      novelId: json['expand']['novel_id']['id'] as String?,
      reporterId: json['reporter_id'] as String?,
      chapterId: json['expand']?['chapter_id']?['id'] as String? ??
          json['chapter_id'] as String?,
      chapterTitle: json['chapter_title'] as String?,
      content: json['content'] as String,
      status: json['report_status'] as String,
      novelName: json['novel_name'] as String?,
      image_novelcover: null,
      url_image_novelcover: imageCoverUrl,
      image_reporteravatar: null,
      url_reporteravatar: avatarUrl,
      createdAt: DateTime.parse(json['report_created'] as String),
      reporterName: json['reporter_name'] as String,
      isrepost: json['isrepost'] as bool? ?? false,
      reportedId: json['expand']['novel_id']['expand']['author']['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'novel': novelId,
      'reporter': reporterId,
      'chapter': chapterId,
      'content': content,
      'status': status,
    };
  }
}
