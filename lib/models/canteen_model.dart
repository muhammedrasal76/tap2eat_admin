import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_item_model.dart';

class CanteenModel {
  final String id;
  final String name;
  final List<MenuItemModel> menuItems;
  final int maxConcurrentOrders;
  final bool isActive;

  CanteenModel({
    required this.id,
    required this.name,
    required this.menuItems,
    required this.maxConcurrentOrders,
    required this.isActive,
  });

  factory CanteenModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    List<MenuItemModel> items = [];
    if (data['menu_items'] != null) {
      items = (data['menu_items'] as List)
          .map((item) => MenuItemModel.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    return CanteenModel(
      id: doc.id,
      name: data['name'] ?? '',
      menuItems: items,
      maxConcurrentOrders: data['max_concurrent_orders'] ?? 10,
      isActive: data['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'menu_items': menuItems.map((item) => item.toFirestore()).toList(),
      'max_concurrent_orders': maxConcurrentOrders,
      'is_active': isActive,
    };
  }

  CanteenModel copyWith({
    String? id,
    String? name,
    List<MenuItemModel>? menuItems,
    int? maxConcurrentOrders,
    bool? isActive,
  }) {
    return CanteenModel(
      id: id ?? this.id,
      name: name ?? this.name,
      menuItems: menuItems ?? this.menuItems,
      maxConcurrentOrders: maxConcurrentOrders ?? this.maxConcurrentOrders,
      isActive: isActive ?? this.isActive,
    );
  }
}
