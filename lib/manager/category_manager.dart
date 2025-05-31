import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';


class CategoryManager with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<Category> _categories = [];

  List<Category> get categories => [..._categories];

  Future<void> fetchCategories() async {
    _categories = await _categoryService.fetchCategories();
    notifyListeners();
  }
}
