import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';

class CategoryService {
  final String apiUrl =
      'https://organic-winner-x5v744jr64cppv4-8080.app.github.dev/app/categories';

  Future<List<Category>> getAllActiveCategories() async {
    final response = await http.get(Uri.parse('$apiUrl/active'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load active categories');
    }
  }

  Future<List<Category>> getAllInactiveCategories() async {
    final response = await http.get(Uri.parse('$apiUrl/inactive'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load inactive categories');
    }
  }

  Future<Category> getCategoryById(int id) async {
    final response = await http.get(Uri.parse('$apiUrl/$id'));

    if (response.statusCode == 200) {
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load category');
    }
  }

  Future<Category> createCategory(Category category) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(category.toJson()),
    );

    if (response.statusCode == 200) {
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create category');
    }
  }

  Future<void> updateCategory(Category category) async {
    final response = await http.put(
      Uri.parse('$apiUrl/${category.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(category.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update category');
    }
  }

  Future<void> deactivateCategory(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/deactivate/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to deactivate category');
    }
  }

  Future<void> activateCategory(int id) async {
    final response = await http.put(Uri.parse('$apiUrl/activate/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to activate category');
    }
  }
}
