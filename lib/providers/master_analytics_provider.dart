import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/firebase_service.dart';
import '../models/master_analytics_data.dart';
import '../models/analytics_time_period.dart';

class MasterAnalyticsProvider extends ChangeNotifier {
  MasterAnalyticsData? _analyticsData;
  bool _isLoading = false;
  String? _errorMessage;
  DateRange _dateRange = DateRange.today();

  MasterAnalyticsData? get analyticsData => _analyticsData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateRange get dateRange => _dateRange;

  Future<void> loadAnalytics(DateRange range) async {
    _dateRange = range;

    // Return cached data if valid
    if (_analyticsData != null && _analyticsData!.isCacheValid()) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        _fetchOrders(range),
        _fetchActiveCanteens(),
        _fetchDeliveryStudents(),
        _fetchOrdersByDay(),
      ]);

      final orders = results[0] as List<QueryDocumentSnapshot>;
      final activeCanteens = results[1] as int;
      final deliveryStudents = results[2] as int;
      final ordersByDay = results[3] as Map<DateTime, int>;

      // Calculate metrics
      final totalOrders = orders.length;
      final totalRevenue = orders.fold<double>(
        0,
        (total, doc) => total + ((doc.data() as Map)['total_amount'] ?? 0),
      );

      final ordersByType = <String, int>{};
      final revenueByCanteen = <String, double>{};

      for (var doc in orders) {
        final data = doc.data() as Map<String, dynamic>;
        final type = data['fulfillment_type'] ?? 'pickup';
        final canteenId = data['canteen_id'] ?? 'unknown';
        final amount = (data['total_amount'] ?? 0).toDouble();

        ordersByType[type] = (ordersByType[type] ?? 0) + 1;
        revenueByCanteen[canteenId] = (revenueByCanteen[canteenId] ?? 0) + amount;
      }

      _analyticsData = MasterAnalyticsData(
        totalOrders: totalOrders,
        totalRevenue: totalRevenue,
        activeCanteens: activeCanteens,
        deliveryStudents: deliveryStudents,
        ordersByDay: ordersByDay,
        ordersByType: ordersByType,
        revenueByCanteen: revenueByCanteen,
        lastUpdated: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load analytics: $e';
      notifyListeners();
    }
  }

  Future<List<QueryDocumentSnapshot>> _fetchOrders(DateRange range) async {
    final snapshot = await FirebaseService.orders
        .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(range.startDate))
        .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(range.endDate))
        .get();
    return snapshot.docs;
  }

  Future<int> _fetchActiveCanteens() async {
    final snapshot = await FirebaseService.canteens
        .where('is_active', isEqualTo: true)
        .get();
    return snapshot.docs.length;
  }

  Future<int> _fetchDeliveryStudents() async {
    final snapshot = await FirebaseService.users
        .where('role', isEqualTo: 'delivery_student')
        .get();
    return snapshot.docs.length;
  }

  Future<Map<DateTime, int>> _fetchOrdersByDay() async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day - 6);

    final snapshot = await FirebaseService.orders
        .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();

    final ordersByDay = <DateTime, int>{};
    for (var i = 0; i < 7; i++) {
      final date = DateTime(now.year, now.month, now.day - (6 - i));
      ordersByDay[date] = 0;
    }

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = (data['created_at'] as Timestamp).toDate();
      final dateKey = DateTime(createdAt.year, createdAt.month, createdAt.day);
      if (ordersByDay.containsKey(dateKey)) {
        ordersByDay[dateKey] = ordersByDay[dateKey]! + 1;
      }
    }

    return ordersByDay;
  }

  void clearCache() {
    _analyticsData = null;
    notifyListeners();
  }
}
