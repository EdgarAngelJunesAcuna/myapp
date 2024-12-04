class Category {
  final int id;
  final String categoryName;
  final String description;
  final String status;

  Category({
    required this.id,
    required this.categoryName,
    required this.description,
    required this.status,
  });

  /// Constructor para crear una instancia de [Category] desde un mapa JSON.
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      categoryName: json['categoryName'] as String,
      description: json['description'] as String? ?? '', // Maneja descripción nula
      status: json['status'] as String,
    );
  }

  /// Convierte la instancia de [Category] a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'description': description,
      'status': status,
    };
  }

  /// Sobrescribe el operador `==` para comparar categorías por contenido.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          categoryName == other.categoryName &&
          description == other.description &&
          status == other.status;

  /// Sobrescribe `hashCode` para usar en estructuras como conjuntos (`Set`) o claves de mapas.
  @override
  int get hashCode =>
      id.hashCode ^ categoryName.hashCode ^ description.hashCode ^ status.hashCode;

  /// Representación en texto de la categoría.
  @override
  String toString() {
    return 'Category(id: $id, categoryName: $categoryName, description: $description, status: $status)';
  }
}
