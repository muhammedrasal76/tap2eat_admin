import 'package:flutter/material.dart';
import '../core/services/firebase_service.dart';
import '../models/order_model.dart';

class OrdersProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> loadOrdersForCanteen(String canteenId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Use direct Firestore query instead of Cloud Function for admin panel
      // This is more efficient and doesn't require Cloud Functions deployment
      final snapshot = await FirebaseService.orders
          .where('canteen_id', isEqualTo: canteenId)
          .where('status', whereIn: ['pending', 'preparing', 'ready'])
          .orderBy('fulfillment_slot')
          .limit(100)
          .get();

      _orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error loading orders: $e');
      _orders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      // Use direct Firestore update instead of Cloud Function for admin panel
      await FirebaseService.orders.doc(orderId).update({
        'status': newStatus,
        'updated_at': DateTime.now(),
      });

      // Update local state
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: newStatus);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow;
    }
  }

  /// Real-time stream for live order updates
  Stream<List<OrderModel>> streamOrdersForCanteen(String canteenId) {
    return FirebaseService.orders
        .where('canteen_id', isEqualTo: canteenId)
        .where('status', whereIn: ['pending', 'preparing', 'ready'])
        .orderBy('fulfillment_slot') // PRD requirement
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList());
  }
}
