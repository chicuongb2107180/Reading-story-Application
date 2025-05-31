import 'package:flutter/material.dart';

import '../models/novel.dart';
import '../services/novel_service.dart';

class NovelsManager with ChangeNotifier {
  final NovelService _novelService = NovelService();

  List<Novel> _novels = [];

  int get novelsCount => _novels.length;

  List<Novel> getNovels() {
    return [..._novels];
  }

  List<Novel> _reaadingNovels = [];
  List<Novel> getReadingNovels() {
    return [..._reaadingNovels];
  }

  List<Novel> _latestNovels = [];
  List<Novel> getLatestNovels() {
    return [..._latestNovels];
  }

  List<Novel> _hotNovels = [];
  List<Novel> getHotNovels() {
    return [..._hotNovels];
  }

  List<Novel> _completedNovels = [];
  List<Novel> getCompletedNovels() {
    return [..._completedNovels];
  }

  List<Novel> _searchNovels = [];
  List<Novel> getSearchNovels() {
    return [..._searchNovels];
  }

  Future<void> fetchNovelLates() async {
    _latestNovels = [];
    List<Novel> novels = await _novelService.fetchNovel(islatest: true);
    for (var novel in novels) {
      if (novel.totalChaptersPublished! > 0) {
        _latestNovels.add(novel);
      }
    }
    notifyListeners();
  }

  // Future<void> fetchHotNovels() async {
  //   _hotNovels = await _novelService.fetchNovel(ishot: true);
  //   notifyListeners();
  // }

  Future<void> fetchCompletedNovels() async {
    _completedNovels = [];
    List<Novel> novels = await _novelService.fetchNovel(isComplete: true);
    for (var novel in novels) {
      if (novel.totalChaptersPublished! > 0) {
        _completedNovels.add(novel);
      }
    }
    notifyListeners();
  }

  Future<void> fetchNovels() async {
    _novels = [];
    List<Novel?> novels = await _novelService.fetchNovel(filteredByUser: true);
    for (var novel in novels) {
      if (novel != null && novel.totalChaptersPublished! >= 0) {
        _novels.add(novel);
      }
    }
    notifyListeners();
  }

  Future<void> fetchReadingNovel() async {
    _reaadingNovels = await _novelService.fetchReadingNovels();
    notifyListeners();
  }

  Future<void> fetchSearchNovels({String? keyWord}) async {
    if (keyWord != null && keyWord.isNotEmpty) {
      _searchNovels = await _novelService.fetchNovel(
        keyWord: keyWord,
      );
    } else {
      _searchNovels = await _novelService.fetchNovelPopular();
    }
  }

  Future<void> fetchNovelByUser(String userId) async {
    List<Novel> novels =
        await _novelService.fetchNovel(filteredByUser: true, authorId: userId);
    _novels = [];
    for (var novel in novels) {
      if (novel.totalChaptersPublished != null &&
          novel.totalChaptersPublished! > 0) {
        _novels.add(novel);
      }
    }
    notifyListeners();
  }

  Future<void> fetchDraftNovel() async {
    _novels =
        await _novelService.fetchNovel(filteredByUser: true, isDraft: true);
    notifyListeners();
  }

  Future<void> fetchCompleteNovel() async {
    _novels =
        await _novelService.fetchNovel(filteredByUser: true, isComplete: true);
    notifyListeners();
  }

  Novel? getNovelById(String novelId) {
    return _novels.firstWhere((novel) => novel.id == novelId, orElse: null);
  }

  Future<void> updateNovel(Novel novel) async {
    await _novelService.updateNovel(novel);
    final novelIndex = _novels.indexWhere((novel) => novel.id == novel.id);
    notifyListeners();
  }

  Future<void> createNovel(Novel novel) async {
    await _novelService.createNovel(novel);
    notifyListeners();
  }

  Future<void> deleteNovel(String novelId) async {
    await _novelService.deleteNovel(novelId);
    _novels.removeWhere((novel) => novel.id == novelId);
    notifyListeners();
  }

  Future<Novel> fetcNovelsbyId(String id) async {
    Novel? novel = await _novelService.fetchNovelById(id);
    _novels = [];
    if (novel != null && novel.totalChaptersPublished != null &&
        novel.totalChaptersPublished! > 0) {
      _novels.add(novel);
    }
    notifyListeners();
    return novel!;
  }
}
