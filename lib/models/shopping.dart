// lib/models/shopping.dart
class Shopping {
  final int id;
  final int clientId;
  final DateTime shoppingDate;
  final double total;
  final String status;

  Shopping({
    required this.id,
    required this.clientId,
    required this.shoppingDate,
    required this.total,
    required this.status,
  });

  factory Shopping.fromJson(Map<String, dynamic> json) {
    return Shopping(
      id: json['id'],
      clientId: json['client_id'],
      shoppingDate: DateTime.parse(json['shopping_date']),
      total: json['total'].toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'shopping_date': shoppingDate.toIso8601String(),
      'total': total,
      'status': status,
    };
  }
}
