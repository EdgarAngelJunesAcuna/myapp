import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/client.dart';
import '../services/client_service.dart';

class ClientFormScreen extends StatefulWidget {
  final Client? client;

  ClientFormScreen({this.client});

  @override
  _ClientFormScreenState createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ClientService _clientService = ClientService();

  // Campos del formulario
  String? _names;
  String? _email;
  String? _cellPhone;
  String? _address;
  String? _dni; // Nuevo campo DNI
  String _status = 'A'; // Valor predeterminado
  DateTime? _registrationDate;

  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.client != null) {
      _names = widget.client!.names;
      _email = widget.client!.email;
      _cellPhone = widget.client!.cellPhone;
      _address = widget.client!.address;
      _dni = widget.client!.dni;  // Asignar el DNI desde el cliente
      _status = widget.client!.status;
      _registrationDate = widget.client!.registrationDate;
      _dateController.text =
          DateFormat('yyyy-MM-dd').format(_registrationDate!);
    } else {
      _registrationDate = DateTime.now();
      _dateController.text =
          DateFormat('yyyy-MM-dd').format(_registrationDate!);
    }
  }

  Future<void> _saveClient() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        if (_registrationDate == null) {
          throw Exception('La fecha de registro no puede ser nula.');
        }

        if (widget.client != null) {
          // Actualizar cliente existente
          await _clientService.updateClient(
            Client(
              id: widget.client!.id,
              names: _names!,
              email: _email!,
              cellPhone: _cellPhone!,
              address: _address!,
              dni: _dni!,  // Incluir DNI en la actualización
              registrationDate: _registrationDate!,
              status: _status,
            ),
          );
        } else {
          // Crear nuevo cliente
          await _clientService.createClient(
            Client(
              names: _names!,
              email: _email!,
              cellPhone: _cellPhone!,
              address: _address!,
              dni: _dni!,  // Incluir DNI en la creación
              registrationDate: _registrationDate!,
              status: 'A',
            ),
          );
        }

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el cliente: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _registrationDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _registrationDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.lightBlue.shade300;
    final textColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.client != null ? 'Editar Cliente' : 'Nuevo Cliente',
        ),
        backgroundColor: primaryColor,
      ),
      body: Container(
        color: Colors.lightBlue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo de nombres
                  _buildTextFormField(
                    initialValue: _names,
                    label: 'Nombres',
                    onSaved: (value) => _names = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un nombre';
                      }
                      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                        return 'El nombre solo puede contener letras y espacios';
                      }
                      if (value.length < 3) {
                        return 'El nombre debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Campo de correo electrónico
                  _buildTextFormField(
                    initialValue: _email,
                    label: 'Correo Electrónico',
                    onSaved: (value) => _email = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un correo electrónico';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Campo de teléfono celular
                  _buildTextFormField(
                    initialValue: _cellPhone,
                    label: 'Teléfono Celular',
                    onSaved: (value) => _cellPhone = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un número de celular';
                      }
                      if (!RegExp(r'^\d{9,15}$').hasMatch(value)) {
                        return 'El número de celular debe tener entre 9 y 15 dígitos';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Campo de dirección
                  _buildTextFormField(
                    initialValue: _address,
                    label: 'Dirección',
                    onSaved: (value) => _address = value,
                  ),
                  SizedBox(height: 16),
                  // Campo de DNI
                  _buildTextFormField(
                    initialValue: _dni,
                    label: 'DNI',
                    onSaved: (value) => _dni = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un DNI';
                      }
                      if (!RegExp(r'^\d{8}$').hasMatch(value)) {
                        return 'El DNI debe tener 8 dígitos';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Campo de fecha
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Fecha de Registro',
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
                      onPressed: _saveClient,
                      child: Text(widget.client != null
                          ? 'Actualizar Cliente'
                          : 'Crear Cliente'),
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
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }
}
