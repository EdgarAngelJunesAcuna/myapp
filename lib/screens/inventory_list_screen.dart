import 'package:flutter/material.dart';
import '../models/inventory.dart';
import '../services/inventory_service.dart';

class InventoryListScreen extends StatefulWidget {
  @override
  _InventoryListScreenState createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final InventoryService _inventoryService = InventoryService();
  List<Inventory> inventoryList = [];
  List<Inventory> filteredInventory = [];
  bool isLoading = true;
  bool showInactive = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchInventory();
  }

  Future<void> fetchInventory() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedInventory = await _inventoryService.getAllInventory();
      setState(() {
        inventoryList = showInactive
            ? fetchedInventory.where((item) => item.status == 'inactive').toList()
            : fetchedInventory.where((item) => item.status == 'active').toList();
        filteredInventory = inventoryList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching inventory: $e');
    }
  }

  void filterInventory(String query) {
    setState(() {
      searchQuery = query;
      filteredInventory = inventoryList
          .where((item) =>
              item.name != null &&
              item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> deleteInventory(int id) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar inventario'),
          content: Text('¿Estás seguro de que deseas eliminar este elemento?'),
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
      await _inventoryService.deleteInventory(id);
      fetchInventory();
    }
  }

  Future<void> toggleActivation(Inventory inventory) async {
    if (inventory.status == 'active') {
      await _inventoryService.deactivateInventory(inventory.id);
    } else {
      await _inventoryService.activateInventory(inventory.id);
    }
    fetchInventory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventario', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                showInactive = !showInactive;
                fetchInventory();
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
              onChanged: filterInventory,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre',
                prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredInventory.isEmpty
                    ? Center(
                        child: Text(
                          showInactive
                              ? 'No hay inventarios inactivos'
                              : 'No hay inventarios activos',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredInventory.length,
                        itemBuilder: (context, index) {
                          final inventory = filteredInventory[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            child: ListTile(
                              title: Text(
                                inventory.name ?? 'Sin nombre',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${inventory.movementType} - Cantidad: ${inventory.movementQuantity}',
                              ),
                              trailing: Wrap(
                                spacing: 5,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      // Implement navigation to edit screen
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () =>
                                        deleteInventory(inventory.id),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      inventory.status == 'active'
                                          ? Icons.check_circle
                                          : Icons.block,
                                      color: inventory.status == 'active'
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    onPressed: () =>
                                        toggleActivation(inventory),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Implement navigation to create inventory screen
        },
      ),
    );
  }
}
