// lib/services/inventory_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventory.dart';

class InventoryService {
  final String apiUrl ='https://infamous-ghost-jj5pj6g5wq4h54gw-8080.app.github.dev/app/inventory'; // Update with your actual API URL

  Future<List<Inventory>> getAllInventory() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Inventory.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load inventory');
    }
  }

  Future<Inventory> getInventoryById(int id) async {
    final response = await http.get(Uri.parse('$apiUrl/$id'));

    if (response.statusCode == 200) {
      return Inventory.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load inventory');
    }
  }

  Future<Inventory> createInventory(Inventory inventory) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(inventory.toJson()),
    );

    if (response.statusCode == 201) {
      return Inventory.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create inventory');
    }
  }

  Future<void> updateInventory(Inventory inventory) async {
    final response = await http.put(
      Uri.parse('$apiUrl/${inventory.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(inventory.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update inventory');
    }
  }

  Future<void> deleteInventory(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete inventory');
    }
  }

  Future<void> activateInventory(int id) async {
    await http.put(Uri.parse('$apiUrl/activate/$id'));
  }

  Future<void> deactivateInventory(int id) async {
    await http.put(Uri.parse('$apiUrl/deactivate/$id'));
  }
}
