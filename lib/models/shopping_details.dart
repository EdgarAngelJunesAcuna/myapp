// lib/models/shopping_details.dart
class ShoppingDetails {
  final int id;
  final int shoppingId;
  final int productId;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String status;

  ShoppingDetails({
    required this.id,
    required this.shoppingId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.status,
  });

  factory ShoppingDetails.fromJson(Map<String, dynamic> json) {
    return ShoppingDetails(
      id: json['id'],
      shoppingId: json['shopping_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      unitPrice: json['unit_price'].toDouble(),
      subtotal: json['subtotal'].toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopping_id': shoppingId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'status': status,
    };
  }
}
