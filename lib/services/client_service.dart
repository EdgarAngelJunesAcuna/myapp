import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/client.dart';

class ClientService {
  final String apiUrl ='https://infamous-ghost-jj5pj6g5wq4h54gw-8080.app.github.dev/app/clients';

  // Get all active clients
  Future<List<Client>> getAllActiveClients() async {
    final response = await http.get(Uri.parse('$apiUrl/active'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Client.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load active clients');
    }
  }

  // Get all inactive clients
  Future<List<Client>> getAllInactiveClients() async {
    final response = await http.get(Uri.parse('$apiUrl/inactive'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Client.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load inactive clients');
    }
  }

  // Get client by ID
  Future<Client> getClientById(int id) async {
    final response = await http.get(Uri.parse('$apiUrl/$id'));

    if (response.statusCode == 200) {
      return Client.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load client');
    }
  }

  // Create a new client
  Future<Client> createClient(Client client) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(client.toJson()),
    );

    if (response.statusCode == 200) {
      // Adjusted to 200
      return Client.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create client');
    }
  }

  // Update an existing client
  Future<void> updateClient(Client client) async {
    final response = await http.put(
      Uri.parse('$apiUrl/${client.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(client.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update client');
    }
  }

  // Delete client (deactivate)
  Future<void> deactivateClient(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/deactivate/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to deactivate client');
    }
  }

  // Activate client
  Future<void> activateClient(int id) async {
    final response = await http.put(Uri.parse('$apiUrl/activate/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to activate client');
    }
  }
}
