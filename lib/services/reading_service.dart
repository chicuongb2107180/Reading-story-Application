import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';

import '../models/reading.dart';

import 'pocketbase_client.dart';

class ReadingService {
  Future<List<Reading>> fetchReadingNovel() async {
    final List<Reading> reading = [];

    try {
      final pb = await getPocketBaseInstance();
      final userId = pb.authStore.model!.id;

      final readingModels = await pb.collection('reading_status').getFullList(
            filter: "user = '$userId'",
            expand: "chapter, chapter.novel, chapter.novel.chapter_via_novel",
          );

      for (final readingModel in readingModels) {
        int totalChapterViews = 0;
        for (final chapter in readingModel.expand['chapter']!) {
          totalChapterViews++;
        }
        final readingJson = readingModel.toJson();
        final chapterJson =
            readingJson['expand']?['chapter'] as Map<String, dynamic>?;

        final novelJson =
            chapterJson?['expand']?['novel'] as Map<String, dynamic>?;

        String? imageCover;
        imageCover = novelJson?['image_cover'] as String?;
        if (novelJson != null && novelJson['image_cover'] != null) {
          imageCover = "${dotenv.env['POCKETBASE_URL']}/api/files/"
              "${novelJson['collectionId']}/${novelJson['id']}/${novelJson['image_cover']}";
          novelJson['image_cover'] = imageCover;
        }

        int totalChaptersPublished = 0;
        int totalViews = 0;
        int totalChapters = 0;

        final chapters =
            novelJson?['expand']?['chapter_via_novel'] as List<dynamic>?;
        if (chapters != null) {
          for (final chapter in chapters) {
            final chapterStatus = chapter['status'] as String?;
            final chapterViews = chapter['count_view'] as int? ?? 0;

            if (chapterStatus == 'published') {
              totalChaptersPublished++;
            }

            totalChapters++;
            totalViews += chapterViews;
          }
        }

        final double progress = totalChapterViews / totalChapters;

        novelJson?['totalChaptersPublished'] = totalChaptersPublished;
        novelJson?['totalViews'] = totalViews;
        novelJson?['progress'] = progress;

        reading.add(Reading.fromJson(
          readingJson
            ..['expand'] = {
              'chapter': chapterJson,
              'novel': novelJson,
            },
        ));
      }
    } catch (e) {
      print(e);
    }

    return reading;
  }

  Future<void> addReading(String chapterId, String novelId) async {
    try {
      final pb = await getPocketBaseInstance();
      final userId = pb.authStore.model!.id;
      List<RecordModel> readingModel;
      readingModel = await pb.collection('reading_status').getFullList(
            filter: "user ?~ '$userId' && chapter?~ '$chapterId'",
          );
      if (readingModel.isNotEmpty) {
        return;
      }
      await pb.collection('reading_status').create(body: {
        'user': userId,
        'chapter': chapterId,
      });
        List<RecordModel> reading;
      reading = await pb.collection('reading_novel').getFullList(
            filter: "user?~ '$userId' && novel ?~ '$novelId'",
          );
          print(reading);
      if (reading.isNotEmpty) {
        return;
      }
      await pb.collection('reading_novel').create(body: {
        'user': userId,
        'novel': novelId,
      });
    } catch (e) {
      print('Error while adding reading status: $e');
    }
  }
}
