import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String role;
  final String email;
  final String name;
  final String? canteenId;
  final String? classId;
  final String? designation;
  final double? earningsBalance;

  UserModel({
    required this.id,
    required this.role,
    required this.email,
    required this.name,
    this.canteenId,
    this.classId,
    this.designation,
    this.earningsBalance,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      role: data['role'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      canteenId: data['canteen_id'],
      classId: data['class_id'],
      designation: data['designation'],
      earningsBalance: data['earnings_balance']?.toDouble(),
    );
  }
}
