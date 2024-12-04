import 'package:flutter/material.dart';
import 'package:myapp/screens/client_form_screen.dart';
import '../models/client.dart';
import '../services/client_service.dart';

class ClientListScreen extends StatefulWidget {
  @override
  _ClientListScreenState createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final ClientService _clientService = ClientService();
  List<Client> clients = [];
  List<Client> filteredClients = [];
  bool isLoading = true;
  bool showInactive = false; // Estado para alternar entre activos e inactivos
  String searchQuery = ''; // Estado para el texto de búsqueda

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  Future<void> fetchClients() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<Client> fetchedClients = showInactive
          ? await _clientService.getAllInactiveClients()
          : await _clientService.getAllActiveClients();
      setState(() {
        clients = fetchedClients;
        filteredClients = fetchedClients; // Inicialmente muestra todos
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching clients: $e');
    }
  }

  void filterClients(String query) {
    setState(() {
      searchQuery = query;
      filteredClients = clients
          .where((client) =>
              client.names.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> deleteClient(int id) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar cliente'),
          content: Text('¿Estás seguro de que deseas eliminar este cliente?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await _clientService.deactivateClient(id);
      fetchClients();
    }
  }

  Future<void> toggleActivation(Client client) async {
    if (client.isActive) {
      await _clientService.deactivateClient(client.id!);
    } else {
      await _clientService.activateClient(client.id!);
    }
    fetchClients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 59, 136, 236),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                showInactive = !showInactive;
                fetchClients();
              });
            },
            child: Text(
              showInactive ? 'Mostrar Activos' : 'Mostrar Inactivos',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: filterClients,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre',
                labelStyle: TextStyle(color: const Color.fromARGB(255, 124, 123, 121)),
                prefixIcon: Icon(Icons.search, color: const Color.fromARGB(255, 126, 126, 126)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber, width: 2.0),
                ),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredClients.isEmpty
                    ? Center(
                        child: Text(
                          showInactive
                              ? 'No hay clientes inactivos'
                              : 'No hay clientes activos',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredClients.length,
                        itemBuilder: (context, index) {
                          final client = filteredClients[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              color: const Color.fromARGB(213, 212, 229, 247),
                              elevation: 5,
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10.0),
                                leading: CircleAvatar(
                                  backgroundColor: client.isActive
                                      ? const Color.fromARGB(255, 12, 54, 240)
                                      : Colors.grey,
                                  child: Text(
                                    client.names.substring(0, 1).toUpperCase(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  client.names,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 5),
                                    Text(client.email),
                                    SizedBox(height: 5),
                                    Text(
                                      client.isActive ? 'Activo' : 'Inactivo',
                                      style: TextStyle(
                                        color: client.isActive
                                            ? const Color.fromARGB(255, 5, 143, 0)
                                            : Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Wrap(
                                  spacing: 5,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ClientFormScreen(client: client),
                                          ),
                                        ).then((_) => fetchClients());
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => deleteClient(client.id!),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        client.isActive
                                            ? Icons.check_circle
                                            : Icons.block,
                                        color: client.isActive
                                            ? const Color.fromARGB(255, 45, 65, 180)
                                            : Colors.grey,
                                      ),
                                      onPressed: () => toggleActivation(client),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 7, 123, 255),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ClientFormScreen()),
          ).then((_) => fetchClients());
        },
      ),
    );
  }
}
