import 'package:flutter/material.dart';
import '../../models/chapter.dart';

class CurrentChapterManager extends ChangeNotifier {
  Chapter? _currentChapter;

  Chapter? get currentChapter => _currentChapter;

  void setCurrentChapter(Chapter chapter) {
    _currentChapter = chapter;
    notifyListeners();
  }
}
