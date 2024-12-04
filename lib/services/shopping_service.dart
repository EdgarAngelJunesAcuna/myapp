// lib/services/shopping_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shopping.dart';

class ShoppingService {
  final String apiUrl =
      'https://organic-winner-x5v744jr64cppv4-8080.app.github.dev/app/shopping'; // Update with your actual API URL

  Future<List<Shopping>> getAllShoppings() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Shopping.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load shopping records');
    }
  }

  Future<Shopping> getShoppingById(int id) async {
    final response = await http.get(Uri.parse('$apiUrl/$id'));

    if (response.statusCode == 200) {
      return Shopping.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load shopping record');
    }
  }

  Future<Shopping> createShopping(Shopping shopping) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(shopping.toJson()),
    );

    if (response.statusCode == 201) {
      return Shopping.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create shopping record');
    }
  }

  Future<void> updateShopping(Shopping shopping) async {
    final response = await http.put(
      Uri.parse('$apiUrl/${shopping.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(shopping.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update shopping record');
    }
  }

  Future<void> deleteShopping(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete shopping record');
    }
  }

  Future<void> activateShopping(int id) async {
    await http.put(Uri.parse('$apiUrl/activate/$id'));
  }

  Future<void> deactivateShopping(int id) async {
    await http.put(Uri.parse('$apiUrl/deactivate/$id'));
  }
}
