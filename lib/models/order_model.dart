import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String canteenId;
  final String userId;
  final List<dynamic> items;
  final double totalAmount;
  final Timestamp fulfillmentSlot;
  final String fulfillmentType;
  final String status;
  final String? deliveryStudentId;
  final double deliveryFee;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  OrderModel({
    required this.id,
    required this.canteenId,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.fulfillmentSlot,
    required this.fulfillmentType,
    required this.status,
    this.deliveryStudentId,
    required this.deliveryFee,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return OrderModel(
      id: id ?? map['id'] ?? '',
      canteenId: map['canteen_id'] ?? '',
      userId: map['user_id'] ?? '',
      items: map['items'] ?? [],
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      fulfillmentSlot: map['fulfillment_slot'] as Timestamp,
      fulfillmentType: map['fulfillment_type'] ?? '',
      status: map['status'] ?? '',
      deliveryStudentId: map['delivery_student_id'],
      deliveryFee: (map['delivery_fee'] ?? 0).toDouble(),
      createdAt: map['created_at'] as Timestamp?,
      updatedAt: map['updated_at'] as Timestamp?,
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel.fromMap(data, id: doc.id);
  }

  OrderModel copyWith({String? status}) {
    return OrderModel(
      id: id,
      canteenId: canteenId,
      userId: userId,
      items: items,
      totalAmount: totalAmount,
      fulfillmentSlot: fulfillmentSlot,
      fulfillmentType: fulfillmentType,
      status: status ?? this.status,
      deliveryStudentId: deliveryStudentId,
      deliveryFee: deliveryFee,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
