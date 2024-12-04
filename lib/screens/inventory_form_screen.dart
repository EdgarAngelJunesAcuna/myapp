import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/inventory.dart';
import '../services/inventory_service.dart';

class InventoryFormScreen extends StatefulWidget {
  final Inventory? inventory;

  InventoryFormScreen({this.inventory});

  @override
  _InventoryFormScreenState createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final InventoryService _inventoryService = InventoryService();

  // Campos del formulario
  int? _productId;
  int? _movementQuantity;
  String? _movementType;
  String _status = 'A'; // Valor predeterminado
  DateTime? _movementDate;

  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.inventory != null) {
      _productId = widget.inventory!.productId;
      _movementQuantity = widget.inventory!.movementQuantity;
      _movementType = widget.inventory!.movementType;
      _status = widget.inventory!.status;
      _movementDate = widget.inventory!.movementDate;
      _dateController.text = DateFormat('yyyy-MM-dd').format(_movementDate!);
    } else {
      _movementDate = DateTime.now();
      _dateController.text = DateFormat('yyyy-MM-dd').format(_movementDate!);
    }
  }

  Future<void> _saveInventory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        if (_movementDate == null) {
          throw Exception('La fecha de movimiento no puede ser nula.');
        }

        if (widget.inventory != null) {
          // Actualizar inventario existente
          await _inventoryService.updateInventory(
            Inventory(
              id: widget.inventory!.id,
              productId: _productId!,
              movementQuantity: _movementQuantity!,
              movementType: _movementType!,
              movementDate: _movementDate!,
              status: _status,
            ),
          );
        } else {
          // Crear nuevo inventario
          await _inventoryService.createInventory(
            Inventory(
              id: 0, // El ID generalmente se genera en el backend.
              productId: _productId!,
              movementQuantity: _movementQuantity!,
              movementType: _movementType!,
              movementDate: _movementDate!,
              status: 'A',
            ),
          );
        }

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el inventario: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _movementDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _movementDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.teal.shade300;
    final textColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.inventory != null ? 'Editar Inventario' : 'Nuevo Inventario',
        ),
        backgroundColor: primaryColor,
      ),
      body: Container(
        color: Colors.teal.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo de ID de producto
                  _buildTextFormField(
                    initialValue: _productId?.toString(),
                    label: 'ID de Producto',
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _productId = int.tryParse(value!),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el ID del producto';
                      }
                      if (int.tryParse(value) == null) {
                        return 'El ID del producto debe ser un número';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Campo de cantidad de movimiento
                  _buildTextFormField(
                    initialValue: _movementQuantity?.toString(),
                    label: 'Cantidad de Movimiento',
                    keyboardType: TextInputType.number,
                    onSaved: (value) =>
                        _movementQuantity = int.tryParse(value!),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la cantidad de movimiento';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Debe ser un número válido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Campo de tipo de movimiento
                  _buildTextFormField(
                    initialValue: _movementType,
                    label: 'Tipo de Movimiento',
                    onSaved: (value) => _movementType = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el tipo de movimiento';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Campo de fecha
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Fecha de Movimiento',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                  SizedBox(height: 20),
                  // Botón para guardar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        textStyle: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _saveInventory,
                      child: Text(widget.inventory != null
                          ? 'Actualizar Inventario'
                          : 'Crear Inventario'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    String? initialValue,
    required String label,
    required void Function(String?) onSaved,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator: validator,
    );
  }
}
