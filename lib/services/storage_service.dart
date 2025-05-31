

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/storage.dart';

import 'pocketbase_client.dart';

class StorageService {
  Future<List<Storage>> fetchStorage() async {
    final List<Storage> storage = [];

    try {
      final pb = await getPocketBaseInstance();
      final userId = pb.authStore.model!.id;

      final storageModels = await pb.collection('storage').getFullList(
            filter: "user = '$userId'",
            expand:
                "novel, novel.chapter_via_novel, novel.author,novel.novel_vote_via_novel",
          );

      for (final storageModel in storageModels) {
        final storageJson = storageModel.toJson();
        final novelJson =
            storageJson['expand']?['novel'] as Map<String, dynamic>?;

        String? imageCover;
        imageCover = novelJson?['image_cover'] as String?;
        if (novelJson != null && novelJson['image_cover'] != null) {
          imageCover = "${dotenv.env['POCKETBASE_URL']}/api/files/"
              "${novelJson['collectionId']}/${novelJson['id']}/${novelJson['image_cover']}";
          novelJson['image_cover'] = imageCover;
        }

        int totalChaptersPublished = 0;
        int totalViews = 0;

        final chapters =
            novelJson?['expand']?['chapter_via_novel'] as List<dynamic>?;
        if (chapters != null) {
          for (final chapter in chapters) {
            final chapterStatus = chapter['status'] as String?;
            final chapterViews = chapter['count_view'] as int? ?? 0;

            if (chapterStatus == 'published') {
              totalChaptersPublished++;
            }

            totalViews += chapterViews;
          }
        }
        int totalVotes = 0;
        double valueVotes = 0.0;

        final novelVote =
            novelJson?['expand']?['novel_vote_via_novel'] as List<dynamic>?;
        print('Novel Vote: $novelVote');
        if (novelVote != null && novelVote.isNotEmpty) {
          final firstVote = novelVote[0] as Map<String, dynamic>?;
          totalVotes = (firstVote?['total_vote'] as int?) ?? 0;
          valueVotes = (firstVote?['value'] as num?)?.toDouble() ?? 0.0;
          print('Total Votes: $totalVotes, Value Votes: $valueVotes');
        }

        novelJson?['totalChaptersPublished'] = totalChaptersPublished;
        novelJson?['totalViews'] = totalViews;
        novelJson?['totalvotes'] = totalVotes;
        novelJson?['valuevotes'] = valueVotes;

        storage.add(Storage.fromJson(
          storageJson
            ..['expand'] = {
              'novel': novelJson,
            },
        ));
      }

      return storage;
    } catch (e) {
      print(e);
      return storage;
    }
  }

  Future<void> addStorage(String novelId) async {
    try {
      final pb = await getPocketBaseInstance();
      final userId = pb.authStore.model!.id;

      await pb.collection('storage').create(body: {
        'user': userId,
        'novel': novelId,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<List<Storage>> getStorageByNovelId(String novelId) async {
    final List<Storage> storage = [];

    try {
      final pb = await getPocketBaseInstance();

      final storageModels = await pb.collection('storage').getFullList(
        filter: "novel = '$novelId'",
      );
      for (final storageModel in storageModels) {
        final storageJson = storageModel.toJson();
        final novelJson = storageJson['expand']?['novel'] as Map<String, dynamic>?;
        String? imageCover;
        imageCover = novelJson?['image_cover'] as String?;
        if (novelJson != null && novelJson['image_cover'] != null) {
          imageCover = "${dotenv.env['POCKETBASE_URL']}/api/files/"
              "${novelJson['collectionId']}/${novelJson['id']}/${novelJson['image_cover']}";
          novelJson['image_cover'] = imageCover;
        }
        storage.add(Storage.fromJson(
          storageJson
            ..['expand'] = {
              'novel': novelJson,
            },
        ));
      }
      print('Storage by Novel ID: $storage');

      return storage;
    } catch (e) {
      // Replace print with a logging framework in production
      print(e);
      return storage;
    }
  }

  Future<void> removeStorage(String novelId) async {
    try {
      final pb = await getPocketBaseInstance();
      final userId = pb.authStore.model!.id;

      final storageModel = await pb.collection('storage').getFullList(
            filter: "user = '$userId' && novel = '$novelId'",
          );
      print(storageModel);

      if (storageModel.isNotEmpty) {
        await pb.collection('storage').delete(storageModel[0].id);
      }
    } catch (e) {
      print(e);
    }
  }
}
