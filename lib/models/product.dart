import 'category.dart';

class Product {
  int id;
  String productName;
  String description;
  double price;
  int stock;
  Category category; // Relación con Category como objeto
  DateTime? manufactureDate; // Fecha de elaboración
  DateTime? expirationDate;  // Fecha de caducidad
  String status; // Estado del producto

  Product({
    required this.id,
    required this.productName,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    this.manufactureDate,
    this.expirationDate,
    this.status = 'A',
  });

  /// Constructor para deserializar un objeto JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      productName: json['productName'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      stock: json['stock'] ?? 0,
      category: Category.fromJson(json['category'] ?? {}), // Deserializa Category
      manufactureDate: json['manufactureDate'] != null
          ? DateTime.parse(json['manufactureDate']) // Convierte fecha en String a DateTime
          : null,
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate']) // Convierte fecha en String a DateTime
          : null,
      status: json['status'] ?? 'A',
    );
  }

  /// Método para serializar un objeto `Product` a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category.toJson(), // Serializa Category
      'manufactureDate': manufactureDate?.toIso8601String(), // Formato ISO 8601 para fechas
      'expirationDate': expirationDate?.toIso8601String(),  // Formato ISO 8601 para fechas
      'status': status,
    };
  }

  /// Sobrescribe el operador `==` para comparar productos por contenido
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          productName == other.productName &&
          description == other.description &&
          price == other.price &&
          stock == other.stock &&
          category == other.category &&
          manufactureDate == other.manufactureDate &&
          expirationDate == other.expirationDate &&
          status == other.status;

  /// Sobrescribe `hashCode` para permitir el uso en conjuntos y claves de mapas
  @override
  int get hashCode =>
      id.hashCode ^
      productName.hashCode ^
      description.hashCode ^
      price.hashCode ^
      stock.hashCode ^
      category.hashCode ^
      manufactureDate.hashCode ^
      expirationDate.hashCode ^
      status.hashCode;

  /// Representación en texto del objeto `Product`
  @override
  String toString() {
    return 'Product(id: $id, productName: $productName, description: $description, price: $price, '
        'stock: $stock, category: $category, manufactureDate: $manufactureDate, '
        'expirationDate: $expirationDate, status: $status)';
  }
}
