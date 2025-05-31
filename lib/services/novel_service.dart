import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;

import '../models/novel.dart';
import 'pocketbase_client.dart';

class NovelService {
  String _getImageCover(PocketBase pb, RecordModel novelModel) {
    final imageCover = novelModel.getStringValue('image_cover');
    return pb.files.getUrl(novelModel, imageCover).toString();
  }

  Future<List<Novel>> fetchNovel({
    bool filteredByUser = false,
    bool isDraft = false,
    bool isComplete = false,
    bool islatest = false,
    String authorId = '',
    String? keyWord,
  }) async {
    final List<Novel> novels = [];

    try {
      final pb = await getPocketBaseInstance();
      if (authorId.isEmpty) {
        authorId = pb.authStore.model!.id;
      }
      final userId = authorId;
      final List<String> filters = [];

      if (filteredByUser) {
        filters.add("author = '$userId'");
      }

      if (isDraft) {
        filters.add('is_completed = false');
      }

      if (isComplete) {
        filters.add('is_completed = true');
      }

      if (keyWord != null && keyWord.isNotEmpty) {
        filters.add("novel_name ~ '%$keyWord%'");
      }

      final filterQuery = filters.isNotEmpty ? filters.join(' && ') : null;

      final novelModels = await pb.collection('novels').getFullList(
            filter: filterQuery,
            sort: islatest ? '-created' : 'created',
            expand:
                'chapter_via_novel, author, storage_via_novel,novel_vote_via_novel',
          );

      for (final novelModel in novelModels) {
        int totalChaptersPublished = 0;
        int totalChaptersDraft = 0;
        int totalViews = 0;

        final chapters = novelModel.expand['chapter_via_novel'];
        if (chapters != null) {
          for (final chapter in chapters) {
            final status = chapter.getStringValue('status');
            if (status == 'published') {
              totalChaptersPublished++;
            } else if (status == 'draft') {
              totalChaptersDraft++;
            }
            totalViews += chapter.getIntValue('count_view');
          }
        }

        bool isStorage = false;
        final storage = novelModel.expand['storage_via_novel']?[0];
        if (storage != null) {
          isStorage = true;
        }

        Map<String, dynamic> categoriesMap = {};
        final categoriesModel =
            await pb.collection('category_novel').getFullList(
                  filter: 'novel = "${novelModel.id}"',
                  expand: 'category',
                );

        for (final categoryModel in categoriesModel) {
          final categoryData = categoryModel.expand['category']?[0];
          if (categoryData != null) {
            categoriesMap[categoryModel.id] = categoryData.toJson();
          }
        }

        novels.add(Novel.fromJson(
          novelModel.toJson()
            ..addAll({
              'image_cover': _getImageCover(pb, novelModel),
              'totalChaptersPublished': totalChaptersPublished,
              'totalChaptersDraft': totalChaptersDraft,
              'totalViews': totalViews,
              'categories': categoriesMap,
              'isStorage': isStorage,
              'totalvotes': novelModel.expand['novel_vote_via_novel']![0]
                  .getIntValue('total_vote'),
              'valuevotes': novelModel.expand['novel_vote_via_novel']![0]
                  .getDoubleValue('value'),
            }),
        ));
      }

      return novels;
    } catch (error) {
      return novels;
    }
  }

  Future<List<Novel>> fetchNovelPopular() async {
    final List<Novel> novels = [];
    try {
      final pb = await getPocketBaseInstance();
      final novelModels = await pb.collection('novel_view').getFullList(
            expand:
                'novel.chapter_via_novel, novel.author, novel.category_novel_via_novel.category,novel.novel_vote_via_novel',
          );
      final filteredNovels = novelModels
          .where((novel) => novel.getIntValue('total_view') >= 0)
          .toList();

      for (final noveViewlModel in filteredNovels) {
        final novelModel = noveViewlModel.expand['novel']![0];
        int totalChaptersPublished = 0;
        int totalChaptersDraft = 0;

        final chapters = novelModel.expand['chapter_via_novel'];
        if (chapters != null) {
          for (final chapter in chapters) {
            final status = chapter.getStringValue('status');
            if (status == 'published') {
              totalChaptersPublished++;
            } else if (status == 'draft') {
              totalChaptersDraft++;
            }
          }
        }

        Map<String, dynamic> categoriesMap = {};
        final categoriesModel =
            await pb.collection('category_novel').getFullList(
                  filter: 'novel = "${novelModel.id}"',
                  expand: 'category',
                );

        for (final categoryModel in categoriesModel) {
          final categoryData = categoryModel.expand['category']?[0];
          if (categoryData != null) {
            categoriesMap[categoryModel.id] = categoryData.toJson();
          }
        }

        bool isStorage = false;
        final storage = novelModel.expand['storage_via_novel']?[0];
        if (storage != null) {
          isStorage = true;
        }
        var totalVotes = 0;
        var valueVotes = 0.0;
        final novelVote = novelModel.expand['novel_vote_via_novel'];
        if (novelVote != null && novelVote.isNotEmpty) {
          totalVotes = novelVote[0].getIntValue('total_vote');
          valueVotes = novelVote[0].getDoubleValue('value') ?? 0.0;
        }

        novels.add(Novel.fromJson(
          novelModel.toJson()
            ..addAll({
              'image_cover': _getImageCover(pb, novelModel),
              'totalChaptersPublished': totalChaptersPublished,
              'totalChaptersDraft': totalChaptersDraft,
              'totalViews': noveViewlModel.getIntValue('total_view'),
              'categories': categoriesMap,
              'isStorage': isStorage,
              'totalvotes': totalVotes,
              'valuevotes': valueVotes,
            }),
        ));
      }

      return novels;
    } catch (error) {
      return novels;
    }
  }

  Future<Novel?> fetchNovelById(String novelId) async {
    try {
      final pb = await getPocketBaseInstance();
      final novelModel = await pb.collection('novels').getOne(
            novelId,
            expand: 'chapter_via_novel,novel_vote_via_novel,author',
          );
      int totalChaptersPublished = 0;
      int totalChaptersDraft = 0;
      int totalViews = 0;
      final chapters =
          novelModel.expand['chapter_via_novel'] as List<RecordModel>;
      for (final chapter in chapters) {
        final status = chapter.getStringValue('status');
        if (status == 'published') {
          totalChaptersPublished++;
        } else if (status == 'draft') {
          totalChaptersDraft++;
        }
        totalViews += chapter.getIntValue('count_view');
      }

      return Novel.fromJson(
        novelModel.toJson()
          ..addAll({
            'image_cover': _getImageCover(pb, novelModel),
            'totalChaptersPublished': totalChaptersPublished,
            'totalChaptersDraft': totalChaptersDraft,
            'totalViews': totalViews,
            'totalvotes': novelModel.expand['novel_vote_via_novel']![0]
                .getIntValue('total_vote'),
            'valuevotes': novelModel.expand['novel_vote_via_novel']![0]
                .getDoubleValue('value'),
          }),
      );
    } catch (error) {
      return null;
    }
  }

  Future<List<Novel>> fetchReadingNovels() async {
    final List<Novel> novels = [];
    try {
      final pb = await getPocketBaseInstance();
      final userId = pb.authStore.model!.id;
      final readingNovelModel = await pb.collection('reading_novel').getFullList(
          filter: "user = '$userId'",
          expand:
              'novel, novel.chapter_via_novel,novel.novel_vote_via_novel,novel.author');

      for (final readingNovel in readingNovelModel) {
        final novelModel = readingNovel.expand['novel']?[0];

        if (novelModel == null) {
          continue;
        }

        final chapters = novelModel.expand['chapter_via_novel'];
        int totalChaptersPublished = 0;
        int totalChaptersDraft = 0;
        int totalViews = 0;
        int totalChaptersRead = 0;
        if (chapters != null) {
          for (final chapter in chapters) {
            final status = chapter.getStringValue('status');
            if (status == 'published') {
              totalChaptersPublished++;
            } else if (status == 'draft') {
              totalChaptersDraft++;
            }
            totalViews += chapter.getIntValue('count_view');

            final readingStatusModel =
                await pb.collection('reading_status').getFullList(
                      filter: "user = '$userId' && chapter = '${chapter.id}'",
                    );
            if (readingStatusModel.isNotEmpty) {
              totalChaptersRead++;
            }
          }
        }
        var totalVotes = 0;
        var valueVotes = 0.0;
        final novelVote = novelModel.expand['novel_vote_via_novel'];
        if (novelVote != null && novelVote.isNotEmpty) {
          totalVotes = novelVote[0].getIntValue('total_vote');
          valueVotes = novelVote[0].getDoubleValue('value') ?? 0.0;
        }
        final progress = totalChaptersRead / totalChaptersPublished;

        novels.add(Novel.fromJson(
          novelModel.toJson()
            ..addAll({
              'image_cover': _getImageCover(pb, novelModel),
              'totalChaptersPublished': totalChaptersPublished,
              'totalChaptersDraft': totalChaptersDraft,
              'totalViews': totalViews,
              'progress': progress,
              'totalvotes': totalVotes,
              'valuevotes': valueVotes,
            }),
        ));
      }

      return novels;
    } catch (error) {
      return novels;
    }
  }

  Future<Novel?> updateNovel(Novel novel) async {
    try {
      final pb = await getPocketBaseInstance();
      final String userId = pb.authStore.model!.id;
      final Map<String, dynamic> body = {
        ...novel.toJson(),
        'author': userId,
      };

      await pb.collection('novels').update(
        novel.id!,
        body: body,
        files: [
          if (novel.imageCover != null)
            http.MultipartFile.fromBytes(
              'image_cover',
              await novel.imageCover!.readAsBytes(),
              filename: novel.imageCover!.uri.pathSegments.last,
            ),
        ],
      );

      final List<RecordModel> recordscategories =
          await pb.collection('category_novel').getFullList(
                filter: "novel = '${novel.id}'",
                expand: "category",
              );

      if (novel.categories != null) {
        for (final category in novel.categories!) {
          final categoryModel = recordscategories.firstWhere(
            (element) => element.getStringValue('category') == category.id,
            orElse: () => RecordModel(id: ''),
          );

          if (categoryModel.id.isEmpty) {
            await pb.collection('category_novel').create(body: {
              'novel': novel.id,
              'category': category.id,
            });
          }
        }
      }

      return novel.copyWith(author: userId);
    } catch (error) {
      return null;
    }
  }

  Future<Novel> createNovel(Novel novel) async {
    try {
      final pb = await getPocketBaseInstance();
      final record = await pb.collection('novels').create(
        body: {
          ...novel.toJson(),
          'author': pb.authStore.model!.id,
        },
        files: [
          http.MultipartFile.fromBytes(
            'image_cover',
            await novel.imageCover!.readAsBytes(),
            filename: novel.imageCover!.uri.pathSegments.last,
          ),
        ],
      );
      if (novel.categories != null) {
        for (final category in novel.categories!) {
          await pb.collection('category_novel').create(body: {
            'novel': record.id,
            'category': category.id,
          });
        }
      }
      return novel.copyWith(author: pb.authStore.model!.id, id: record.id);
    } catch (error) {
      throw Exception('An error occurred');
    }
  }

  Future<void> deleteNovel(String novelId) async {
    try {
      final pb = await getPocketBaseInstance();
      await pb.collection('novels').delete(novelId);
    } catch (error) {
      throw Exception('An error occurred');
    }
  }
}
