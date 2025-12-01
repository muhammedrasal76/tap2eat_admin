import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/colors.dart';

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

  // Helper: Format fulfillment slot
  String getFormattedFulfillmentSlot() {
    final date = fulfillmentSlot.toDate();
    return DateFormat('MMM dd, yyyy h:mm a').format(date);
  }

  // Helper: Get status color
  Color getStatusColor() {
    switch (status) {
      case 'pending':
        return AppColors.info;
      case 'preparing':
        return AppColors.primary;
      case 'ready':
        return AppColors.success;
      case 'assigned':
      case 'delivering':
        return AppColors.warning;
      case 'delivered':
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  // Helper: Get status display name
  String getStatusDisplayName() {
    return status[0].toUpperCase() + status.substring(1);
  }

  // Helper: Check if delivery order
  bool get isDeliveryOrder => fulfillmentType == 'delivery';

  // Helper: Check if has delivery assignment
  bool get hasDeliveryAssignment =>
      deliveryStudentId != null && deliveryStudentId!.isNotEmpty;

  // Enhanced copyWith to support all fields
  OrderModel copyWith({
    String? id,
    String? canteenId,
    String? userId,
    List<dynamic>? items,
    double? totalAmount,
    Timestamp? fulfillmentSlot,
    String? fulfillmentType,
    String? status,
    String? deliveryStudentId,
    double? deliveryFee,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      canteenId: canteenId ?? this.canteenId,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      fulfillmentSlot: fulfillmentSlot ?? this.fulfillmentSlot,
      fulfillmentType: fulfillmentType ?? this.fulfillmentType,
      status: status ?? this.status,
      deliveryStudentId: deliveryStudentId ?? this.deliveryStudentId,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
