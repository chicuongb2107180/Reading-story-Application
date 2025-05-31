import '../models/chapter.dart';

import 'pocketbase_client.dart';

class ChapterService {
  Future<List<Chapter>> fetchChapters(String novelId,
      {bool isDraft = false, bool isPublished = false}) async {
    final List<Chapter> chapters = [];

    try {
      final pb = await getPocketBaseInstance();

      final List<String> filters = ['novel = "$novelId"'];

      if (isDraft) {
        filters.add('status = "draft"');
      }

      if (isPublished) {
        filters.add('status = "published"');
      }

      final filterQuery = filters.join(' && ');

      final chapterModels = await pb.collection('chapter').getFullList(
            filter: filterQuery,
          );
      for (final chapterModel in chapterModels) {
        bool isRead = false;
        final userId = pb.authStore.model!.id;
        final chapterId = chapterModel.id;
        final readingStatus = await pb.collection('reading_status').getFullList(
              filter: 'chapter = "$chapterId" && user = "$userId"',
            );
        if (readingStatus.isNotEmpty) {
          isRead = true;
        }

        chapters.add(
          Chapter.fromJson(
            chapterModel.toJson()..addAll({'isRead': isRead}),
          ),
        );
      }
      return chapters;
    } catch (error) {
      return chapters;
    }
  }

Future<Chapter?> fetchChapter(String chapterId) async {
    try {
      final pb = await getPocketBaseInstance();
      final chapterModel = await pb.collection('chapter').getOne(chapterId);

      // Kiểm tra chapterModel có phải null không
      if (chapterModel == null) {
        print('Không tìm thấy chương với ID: $chapterId');
        return null; // Nếu không tìm thấy chương, trả về null
      }

      // Log dữ liệu để kiểm tra
      print('Chapter data: ${chapterModel.toJson()}');
      return Chapter.fromJson(chapterModel.toJson());
    } catch (error) {
      print('Error fetching chapter: $error');
      return null;
    }
  }



  Future<void> incrementViewCount(String chapterId) async {
    try {
      final pb = await getPocketBaseInstance();
      final chapterModel = await pb.collection('chapter').getOne(chapterId);
      final currentViews = chapterModel.data['count_view'] ?? 0;
      await pb
          .collection('chapter')
          .update(chapterId, body: {'count_view': currentViews + 1});
    } catch (error) {
      print("Error occurred: $error");
    }
  }

  Future<Chapter?> addChapter(Chapter chapter) async {
    try {
      print(chapter.toJson());
      final pb = await getPocketBaseInstance();
      final chapterModel =
          await pb.collection('chapter').create(body: chapter.toJson());

      return Chapter.fromJson(chapterModel.toJson());
    } catch (error) {
      print("Error occurred: $error");
      return null;
    }
  }

  Future<void> updateChapter(Chapter chapter) async {
    try {
      final pb = await getPocketBaseInstance();
      await pb
          .collection('chapter')
          .update(chapter.id!, body: chapter.toJson());
    } catch (error) {
      print("Error occurred: $error");
    }
  }

  Future<void> deleteChapter(String chapterId) async {
    try {
      final pb = await getPocketBaseInstance();
      await pb.collection('chapter').delete(chapterId);
    } catch (error) {
      print("Error occurred: $error");
    }
  }
}
