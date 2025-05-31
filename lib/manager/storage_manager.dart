import 'package:flutter/material.dart';

import '../models/storage.dart';
import '../services/storage_service.dart';

class StorageManager with ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<Storage> _storage = [];

  int get storageCount => _storage.length;

  List<Storage> getStorage() {
    return [..._storage];
  }

  Future<bool> isNovelAddedToStorage(String novelId) async {
    _storage = await _storageService.fetchStorage();
    return _storage.any((element) => element.novel?.id == novelId);
  }

  bool isNovelRead(String novelId) {
    return _storage.any((element) => element.novel?.id == novelId);
  }

  Future<void> fetchStorage() async {
    _storage = await _storageService.fetchStorage();
    notifyListeners();
  }

  Future<void> addStorage(String novelId) async {
    if (await isNovelAddedToStorage(novelId)) {
      return;
    }
    await _storageService.addStorage(novelId);
    notifyListeners();
  }

  Future<void> removeStorage(String novelId) async {
    await _storageService.removeStorage(novelId);
    notifyListeners();
  }
  Future<void> fetchStorageByNovelId(String novelId) async {
    _storage = await _storageService.getStorageByNovelId(novelId);
    notifyListeners();
  }
}
