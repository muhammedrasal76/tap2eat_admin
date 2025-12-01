import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/firebase_service.dart';
import '../models/order_model.dart';
import '../models/order_filter_state.dart';

class OrdersProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  List<OrderModel> _filteredOrders = [];
  Map<String, dynamic> _users = {}; // Cache user data
  Set<String> _seenOrderIds = {}; // Track seen orders
  int _newOrderCount = 0;
  bool _soundEnabled = true;
  bool _isLoading = false;

  OrderFilterState _filterState = OrderFilterState();

  // Getters
  List<OrderModel> get orders => _filteredOrders;
  bool get isLoading => _isLoading;
  OrderFilterState get filterState => _filterState;
  int get newOrderCount => _newOrderCount;
  bool get soundEnabled => _soundEnabled;

  // Update filter state and apply filters
  void updateFilters(OrderFilterState newFilterState) {
    _filterState = newFilterState;
    _applyFilters();
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _filterState = OrderFilterState();
    _applyFilters();
    notifyListeners();
  }

  // Apply filters to order list
  void _applyFilters() {
    _filteredOrders = _orders.where((order) {
      // Status filter
      if (_filterState.statusFilters.isNotEmpty &&
          !_filterState.statusFilters.contains(order.status)) {
        return false;
      }

      // Fulfillment type filter
      if (_filterState.fulfillmentTypeFilters.isNotEmpty &&
          !_filterState.fulfillmentTypeFilters
              .contains(order.fulfillmentType)) {
        return false;
      }

      // Date range filter
      if (_filterState.startDate != null) {
        final orderDate = order.fulfillmentSlot.toDate();
        if (orderDate.isBefore(_filterState.startDate!)) {
          return false;
        }
      }
      if (_filterState.endDate != null) {
        final orderDate = order.fulfillmentSlot.toDate();
        if (orderDate.isAfter(_filterState.endDate!)) {
          return false;
        }
      }

      // Search query filter
      if (_filterState.searchQuery.isNotEmpty) {
        final query = _filterState.searchQuery.toLowerCase();
        if (!order.id.toLowerCase().contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Apply sorting
    _filteredOrders.sort((a, b) {
      int comparison = 0;

      switch (_filterState.sortBy) {
        case 'time':
          comparison = a.fulfillmentSlot.compareTo(b.fulfillmentSlot);
          break;
        case 'amount':
          comparison = a.totalAmount.compareTo(b.totalAmount);
          break;
        case 'status':
          comparison = a.status.compareTo(b.status);
          break;
      }

      return _filterState.sortAscending ? comparison : -comparison;
    });
  }

  // Load orders once
  Future<void> loadOrdersForCanteen(String canteenId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseService.orders
          .where('canteen_id', isEqualTo: canteenId)
          .orderBy('fulfillment_slot')
          .limit(100)
          .get();

      _orders =
          snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading orders: $e');
      _orders = [];
      _filteredOrders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseService.orders.doc(orderId).update({
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Update local state
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: newStatus);
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow;
    }
  }

  // Enhanced stream with new order detection
  Stream<List<OrderModel>> streamOrdersForCanteen(String canteenId) {
    return FirebaseService.orders
        .where('canteen_id', isEqualTo: canteenId)
        .orderBy('fulfillment_slot', descending: false)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      final newOrders =
          snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();

      // Detect new orders
      final newOrderIds = newOrders.map((o) => o.id).toSet();
      final previousOrderIds = _orders.map((o) => o.id).toSet();
      final brandNewOrders = newOrderIds.difference(previousOrderIds);

      if (brandNewOrders.isNotEmpty && _orders.isNotEmpty) {
        _newOrderCount += brandNewOrders.length;
        // Trigger sound notification if enabled
        if (_soundEnabled) {
          _playNotificationSound();
        }
      }

      _orders = newOrders;
      _applyFilters();

      return _filteredOrders;
    });
  }

  // Fetch user data
  Future<Map<String, dynamic>> getUserData(String userId) async {
    if (_users.containsKey(userId)) {
      return _users[userId];
    }

    try {
      final doc = await FirebaseService.users.doc(userId).get();
      if (doc.exists) {
        final userData = doc.data() as Map<String, dynamic>;
        _users[userId] = userData;
        return userData;
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }

    return {};
  }

  // Fetch delivery student list
  Future<List<Map<String, dynamic>>> getAvailableDeliveryStudents() async {
    try {
      final snapshot = await FirebaseService.users
          .where('role', isEqualTo: 'delivery_student')
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      debugPrint('Error fetching delivery students: $e');
      return [];
    }
  }

  // Assign delivery student
  Future<void> assignDeliveryStudent(String orderId, String studentId) async {
    try {
      await FirebaseService.orders.doc(orderId).update({
        'delivery_student_id': studentId,
        'status': 'assigned',
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error assigning delivery student: $e');
      rethrow;
    }
  }

  // Mark orders as seen
  void markOrdersAsSeen() {
    _newOrderCount = 0;
    _seenOrderIds = _orders.map((o) => o.id).toSet();
    notifyListeners();
  }

  // Toggle sound notifications
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
  }

  // Play notification sound (web implementation)
  void _playNotificationSound() {
    // TODO: Implement web audio API or use package
    // For now, just a placeholder
    debugPrint('🔔 New order notification!');
  }
}
