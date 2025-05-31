import 'package:flutter/material.dart';

import '../models/reading.dart';
import '../services/reading_service.dart';

class ReadingManager with ChangeNotifier {
  final ReadingService _readingService = ReadingService();

  List<Reading> _readingNovel = [];

  int get readingCount => _readingNovel.length;

  List<Reading> getReading() {
    return [..._readingNovel];
  }

  Future<void> fetchReadingNovel() async {
    _readingNovel = await _readingService.fetchReadingNovel();
    notifyListeners();
  }

  Future<void> addReading(String chapterId,String novelId) async {
    if (_readingNovel.any((reading) => reading.chapter.id == chapterId)) {
      return;
    }
    await _readingService.addReading(chapterId,novelId);
    notifyListeners();
  }
}
