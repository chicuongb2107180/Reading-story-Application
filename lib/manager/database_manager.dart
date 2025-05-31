import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/novel_service.dart';
import '../models/novel.dart';

class DatabaseManager with ChangeNotifier {
  final _dbService = DatabaseService.instance;

  final _savedNovels = [];

  List<Novel> getSavedNovels() {
    print(_savedNovels);
    return [..._savedNovels];
  }

  Future<void> saveNovel(String novelId) async {
    final Novel? novel = await NovelService().fetchNovelById(novelId);
    if (novel != null) {
      await _dbService.saveNovel(novel);
      notifyListeners();
    } else {
      print("Novel not found for id: $novelId");
      // Xử lý khi không tìm thấy Novel theo ID hoặc thông báo lỗi
    }
  }

  Future<void> removeSavedNovel(String id) async {
    await _dbService.removeSavedNovel(id);
    notifyListeners();
  }

  Future<void> fetchSavedNovels() async {
    final savedNovels = await _dbService.getSavedNovels();
    _savedNovels.clear();
    for (var novel in savedNovels) {
      _savedNovels.add(Novel.fromJson(novel));
    }
    notifyListeners();
  }
}
