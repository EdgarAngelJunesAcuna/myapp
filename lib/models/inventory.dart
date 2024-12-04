// lib/models/inventory.dart
class Inventory {
  final int id;
  final int productId;
  final int movementQuantity;
  final String movementType;
  final DateTime movementDate;
  final String status;

  var name;

  Inventory({
    required this.id,
    required this.productId,
    required this.movementQuantity,
    required this.movementType,
    required this.movementDate,
    required this.status,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'],
      productId: json['product_id'],
      movementQuantity: json['movement_quantity'],
      movementType: json['movement_type'],
      movementDate: DateTime.parse(json['movement_date']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'movement_quantity': movementQuantity,
      'movement_type': movementType,
      'movement_date': movementDate.toIso8601String(),
      'status': status,
    };
  }
}
