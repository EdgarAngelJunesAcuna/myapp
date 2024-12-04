// lib/services/shopping_details_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shopping_details.dart';

class ShoppingDetailsService {
  final String apiUrl =
      'https://organic-winner-x5v744jr64cppv4-8080.app.github.dev/app/shopping-details'; // Update with your actual API URL

  Future<List<ShoppingDetails>> getAllShoppingDetails(int shoppingId) async {
    final response =
        await http.get(Uri.parse('$apiUrl?shopping_id=$shoppingId'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ShoppingDetails.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load shopping details');
    }
  }

  Future<ShoppingDetails> getShoppingDetailById(int id) async {
    final response = await http.get(Uri.parse('$apiUrl/$id'));

    if (response.statusCode == 200) {
      return ShoppingDetails.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load shopping detail');
    }
  }

  Future<ShoppingDetails> createShoppingDetail(
      ShoppingDetails shoppingDetail) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(shoppingDetail.toJson()),
    );

    if (response.statusCode == 201) {
      return ShoppingDetails.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create shopping detail');
    }
  }

  Future<void> updateShoppingDetail(ShoppingDetails shoppingDetail) async {
    final response = await http.put(
      Uri.parse('$apiUrl/${shoppingDetail.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(shoppingDetail.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update shopping detail');
    }
  }

  Future<void> deleteShoppingDetail(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete shopping detail');
    }
  }

  Future<void> activateShoppingDetail(int id) async {
    await http.put(Uri.parse('$apiUrl/activate/$id'));
  }

  Future<void> deactivateShoppingDetail(int id) async {
    await http.put(Uri.parse('$apiUrl/deactivate/$id'));
  }
}
