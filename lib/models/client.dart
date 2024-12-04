class Client {
  int? id;
  String names;
  String email;
  String cellPhone;
  String address;
  String dni;  // Nuevo campo
  DateTime registrationDate;
  String status;

  Client({
    this.id,
    required this.names,
    required this.email,
    required this.cellPhone,
    required this.address,
    required this.dni,  // Nuevo campo en el constructor
    required this.registrationDate,
    required this.status,
  });

  // Constructor de fábrica para crear un objeto Client desde JSON
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      names: json['names'],
      email: json['email'],
      cellPhone: json['cellPhone'],
      address: json['address'],
      dni: json['dni'],  // Asignar el valor del nuevo campo
      registrationDate: DateTime.parse(json['registrationDate']), // Formato ISO con 'T'
      status: json['status'],
    );
  }

  // Convierte un objeto Client a JSON con el formato de fecha adecuado
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'names': names,
      'email': email,
      'cellPhone': cellPhone,
      'address': address,
      'dni': dni,  // Agregar el nuevo campo al JSON
      'registrationDate': registrationDate.toIso8601String(),
      'status': status,
    };
  }

  // Método de conveniencia para verificar si el cliente está activo
  bool get isActive => status == 'A';
}
