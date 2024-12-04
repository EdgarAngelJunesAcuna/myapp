import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  bool _showInactive = false; // Alterna entre activos e inactivos
  String _searchQuery = ""; // Consulta del buscador

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  /// Obtiene productos según el estado (activos o inactivos)
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = _showInactive
          ? await _productService.getAllInactiveProducts()
          : await _productService.getAllActiveProducts();

      setState(() {
        _products = products;
        _filteredProducts = _filterProducts(products, _searchQuery);
      });
    } catch (e) {
      _showErrorSnackbar('Error al cargar productos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Filtra los productos según la consulta de búsqueda
  List<Product> _filterProducts(List<Product> products, String query) {
    if (query.isEmpty) return products;
    return products
        .where((product) => product.productName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Alterna el estado de un producto entre activo/inactivo
  Future<void> _toggleProductStatus(Product product) async {
    final action = product.status == 'A' ? 'desactivar' : 'activar';
    final confirm = await _showConfirmationDialog(
      title: 'Confirmación',
      content: '¿Estás seguro de que quieres $action el producto "${product.productName}"?',
    );

    if (!confirm) return;

    try {
      if (product.status == 'A') {
        await _productService.deactivateProduct(product.id);
        _showSuccessSnackbar('${product.productName} desactivado');
      } else {
        await _productService.activateProduct(product.id);
        _showSuccessSnackbar('${product.productName} activado');
      }
      _fetchProducts();
    } catch (e) {
      _showErrorSnackbar('Error al cambiar el estado del producto: $e');
    }
  }

  /// Muestra un SnackBar de éxito
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  /// Muestra un SnackBar de error
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Muestra un cuadro de diálogo de confirmación
  Future<bool> _showConfirmationDialog({required String title, required String content}) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text('Confirmar'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        elevation: 5,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _showInactive = !_showInactive; // Cambia entre activos/inactivos
                _fetchProducts();
              });
            },
            child: Text(
              _showInactive ? 'Mostrar Activos' : 'Mostrar Inactivos',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar productos',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filteredProducts = _filterProducts(_products, _searchQuery);
                });
              },
            ),
          ),
          // Lista de productos
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Text(
                          _showInactive
                              ? 'No hay productos inactivos'
                              : 'No hay productos activos',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return _buildProductCard(product);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final newProduct = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductFormScreen()),
          );
          if (newProduct != null) {
            _fetchProducts();
          }
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        color: Colors.deepPurple.shade50,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          leading: CircleAvatar(
            backgroundColor:
                product.status == 'A' ? Colors.deepPurple : Colors.grey,
            child: Icon(
              product.status == 'A' ? Icons.check_circle : Icons.block,
              color: Colors.white,
            ),
          ),
          title: Text(
            product.productName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade800,
            ),
          ),
          subtitle: Text(
            '${product.price.toStringAsFixed(2)} PEN\nStock: ${product.stock}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          isThreeLine: true,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final updatedProduct = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductFormScreen(product: product),
                    ),
                  );
                  if (updatedProduct != null) {
                    _fetchProducts();
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  product.status == 'A'
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: product.status == 'A' ? Colors.red : Colors.green,
                ),
                onPressed: () => _toggleProductStatus(product),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
