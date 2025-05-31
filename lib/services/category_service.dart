import 'pocketbase_client.dart';
import '../models/category.dart';

class CategoryService {
  Future<List<Category>> fetchCategories() async {
    final List<Category> categories = [];

    try {
      final pb = await getPocketBaseInstance();
      final categoryModels = await pb.collection('category').getFullList();

      for (final categoryModel in categoryModels) {
        categories.add(Category.fromJson(categoryModel.toJson()));
      }
      return categories;
    } catch (error) {
      print('Error fetching categories: $error');
      return categories;
    }
  }
  Future<List<Category>> fetchCategoriesByNovel(String novelId) async {
    final List<Category> categories = [];

    try {
      final pb = await getPocketBaseInstance();
      final categoryModels = await pb.collection('category_novel').getFullList(
        filter: 'novel = "$novelId"',
        expand: 'category',
      
      );

      for (final categoryModel in categoryModels) {
        categories.add(Category.fromJson(categoryModel.toJson()));
      }
      return categories;
    } catch (error) {
      print('Error fetching categories: $error');
      return categories;
    }
  }
}