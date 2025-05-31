import 'package:flutter/foundation.dart';

import '../../models/chapter.dart';
import '../../services/chapter_service.dart';

class ChapterManager with ChangeNotifier {
  final ChapterService _chapterService = ChapterService();

  List<Chapter> _chapters = [];
  List<Chapter> get chapters => _chapters;

  int get totalViews {
    return _chapters.fold(0, (total, chapter) => total + chapter.count_view);
  }

  int get totalChapters {
    return _chapters.length;
  }

  int get totalChapterDrafts {
    return _chapters.where((chapter) => chapter.status == 'draft').length;
  }

  int get totalChapterPublished {
    return _chapters.where((chapter) => chapter.status == 'published').length;
  }

  Future<void> fetchChapters(String novelId) async {
    _chapters = await _chapterService.fetchChapters(novelId);
    notifyListeners();
  }

  Future<void> fetchDraftChapters(String novelId) async {
    _chapters = await _chapterService.fetchChapters(novelId, isDraft: true);
    notifyListeners();
  }

  Future<void> fetchPublishedChapters(String novelId) async {
    _chapters = await _chapterService.fetchChapters(novelId, isPublished: true);
    notifyListeners();
  }

  Future<void> fetchChapter(String chapterId) async {
    final chapter = await _chapterService.fetchChapter(chapterId);
    if (chapter != null) {
      _chapters.add(chapter);
      notifyListeners();
    }
  }

  Future<Chapter?> getChapterById(String id) async {
    try {
      // Nếu đã có sẵn chương trong bộ nhớ, trả về luôn
      return _chapters.firstWhere((chapter) => chapter.id == id);
    } catch (e) {
      // Nếu chưa có thì fetch chương từ service
      final chapter = await _chapterService.fetchChapter(id);
      if (chapter != null) {
        _chapters.add(chapter); // Lưu lại vào danh sách
        notifyListeners();
      }
      return chapter;
    }
  }

  int getChapterIndexById(String id) {
    return _chapters.indexWhere((chapter) => chapter.id == id);
  }

  Future<void> incrementViewCount(String chapterId) async {
    await _chapterService.incrementViewCount(chapterId);
    final index = _chapters.indexWhere((chapter) => chapter.id == chapterId);
  }

  Future<Chapter?> addChapter(Chapter chapter) async {
    chapter.copyWith(count_view: 0);
    final newChapter = await _chapterService.addChapter(chapter);
    if (newChapter != null) {
      _chapters.add(newChapter);
      notifyListeners();
    }
    return newChapter;
  }

  Future<void> updateChapter(Chapter updatedChapter) async {
    await _chapterService.updateChapter(updatedChapter);
    final index =
        _chapters.indexWhere((chapter) => chapter.id == updatedChapter.id);
    if (index != -1) {
      _chapters[index] = updatedChapter;
      notifyListeners();
    }
  }
  
  Future<void> deleteChapter(String chapterId) async {
    await _chapterService.deleteChapter(chapterId);
    _chapters.removeWhere((chapter) => chapter.id == chapterId);
    notifyListeners();
  }
}
