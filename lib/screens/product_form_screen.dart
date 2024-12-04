import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  ProductFormScreen({this.product});

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();

  // Campos del formulario
  String? _productName;
  String? _description;
  double? _price;
  int? _stock;
  Category? _selectedCategory;
  DateTime? _manufactureDate;
  DateTime? _expirationDate;
  String _status = 'A';

  // Lista de categorías activas
  List<Category> _categories = [];
  bool _isLoadingCategories = true;

  // FocusNodes para cada campo
  final _productNameFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _stockFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _productName = widget.product!.productName;
      _description = widget.product!.description;
      _price = widget.product!.price;
      _stock = widget.product!.stock;
      _selectedCategory = widget.product!.category;
      _manufactureDate = widget.product!.manufactureDate;
      _expirationDate = widget.product!.expirationDate;
      _status = widget.product!.status;
    }
    _fetchCategories();
  }

  @override
  void dispose() {
    _productNameFocus.dispose();
    _descriptionFocus.dispose();
    _priceFocus.dispose();
    _stockFocus.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _categoryService.getAllActiveCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar las categorías: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final newProduct = Product(
          id: widget.product?.id ?? 0,
          productName: _productName!,
          description: _description!,
          price: _price!,
          stock: _stock!,
          category: _selectedCategory!,
          manufactureDate: _manufactureDate,
          expirationDate: _expirationDate,
          status: _status,
        );

        if (widget.product != null) {
          await _productService.updateProduct(newProduct);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Producto actualizado con éxito'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await _productService.createProduct(newProduct);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Producto creado con éxito'),
              backgroundColor: Colors.green,
            ),
          );
        }

        Navigator.of(context).pop(newProduct);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el producto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime) onDateSelected,
  ) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      onDateSelected(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Editar Producto' : 'Crear Producto'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del Producto
                TextFormField(
                  focusNode: _productNameFocus,
                  initialValue: _productName,
                  decoration: InputDecoration(labelText: 'Nombre del Producto'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre del producto es obligatorio.';
                    }
                    if (value.length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres.';
                    }
                    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
                      return 'El nombre solo puede contener letras y espacios.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _productName = value;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Descripción
                TextFormField(
                  focusNode: _descriptionFocus,
                  initialValue: _description,
                  decoration: InputDecoration(labelText: 'Descripción'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La descripción es obligatoria.';
                    }
                    if (value.length < 10) {
                      return 'La descripción debe tener al menos 10 caracteres.';
                    }
                    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
                      return 'La descripción solo puede contener letras y espacios.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _description = value;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Precio
                TextFormField(
                  focusNode: _priceFocus,
                  initialValue: _price?.toString(),
                  decoration: InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El precio es obligatorio.';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'El precio debe ser mayor que 0.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _price = double.tryParse(value);
                    });
                  },
                ),
                SizedBox(height: 16),

                // Stock
                TextFormField(
                  focusNode: _stockFocus,
                  initialValue: _stock?.toString(),
                  decoration: InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El stock es obligatorio.';
                    }
                    final stock = int.tryParse(value);
                    if (stock == null || stock < 1) {
                      return 'El stock debe ser mayor o igual a 1.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _stock = int.tryParse(value);
                    });
                  },
                ),
                SizedBox(height: 16),

                // Categoría
                _isLoadingCategories
                    ? CircularProgressIndicator()
                    : DropdownButtonFormField<Category>(
                        value: _selectedCategory,
                        decoration: InputDecoration(labelText: 'Categoría'),
                        items: _categories.map((category) {
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Text(category.categoryName),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedCategory = value),
                        validator: (value) => value == null
                            ? 'Debes seleccionar una categoría.'
                            : null,
                      ),
                SizedBox(height: 16),

                // Fechas
                ListTile(
                  title: Text(
                    _manufactureDate == null
                        ? 'Seleccionar Fecha de Fabricación'
                        : 'Fabricación: ${_manufactureDate!.toLocal().toString().split(' ')[0]}',
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, _manufactureDate, (date) {
                    setState(() {
                      _manufactureDate = date;

                      if (_expirationDate != null &&
                          _expirationDate!.isBefore(_manufactureDate!)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'La fecha de caducidad no puede ser anterior a la fecha de fabricación.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        _expirationDate = null;
                      }
                    });
                  }),
                ),
                if (_manufactureDate == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'La fecha de fabricación es obligatoria.',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                ListTile(
                  title: Text(
                    _expirationDate == null
                        ? 'Seleccionar Fecha de Caducidad'
                        : 'Caducidad: ${_expirationDate!.toLocal().toString().split(' ')[0]}',
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, _expirationDate, (date) {
                    setState(() {
                      _expirationDate = date;

                      if (_manufactureDate != null &&
                          _expirationDate!.isBefore(_manufactureDate!)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'La fecha de caducidad no puede ser anterior a la fecha de fabricación.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        _expirationDate = null;
                      }
                    });
                  }),
                ),
                if (_expirationDate == null && _manufactureDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'La fecha de caducidad es obligatoria y debe ser posterior a la de fabricación.',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                // Botón de Guardar
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  child: Text(widget.product != null
                      ? 'Actualizar Producto'
                      : 'Crear Producto'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
