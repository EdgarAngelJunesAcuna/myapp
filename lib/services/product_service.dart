import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  final String apiUrl =
      'https://infamous-ghost-jj5pj6g5wq4h54gw-8080.app.github.dev/app/products';

  Future<List<Product>> getAllActiveProducts() async {
    final response = await http.get(Uri.parse('$apiUrl/active'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load active products');
    }
  }

  Future<List<Product>> getAllInactiveProducts() async {
    final response = await http.get(Uri.parse('$apiUrl/inactive'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load inactive products');
    }
  }

  Future<Product> getProductById(int id) async {
    final response = await http.get(Uri.parse('$apiUrl/$id'));

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load product');
    }
  }

  Future<Product> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create product');
    }
  }

  Future<void> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$apiUrl/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update product');
    }
  }

  Future<void> deactivateProduct(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/deactivate/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to deactivate product');
    }
  }

  Future<void> activateProduct(int id) async {
    final response = await http.put(Uri.parse('$apiUrl/activate/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to activate product');
    }
  }
}
