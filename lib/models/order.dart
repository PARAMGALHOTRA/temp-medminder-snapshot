import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final DateTime orderDate;
  final String status;
  final List<Map<String, dynamic>> items;
  final double totalPrice;

  Order({
    required this.id,
    required this.orderDate,
    required this.status,
    required this.items,
    required this.totalPrice,
  });

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      orderDate: (map['orderDate'] as Timestamp).toDate(),
      status: map['status'] ?? '',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
    );
  }
}
