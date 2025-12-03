import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/firebase_service.dart';
import '../models/canteen_analytics_data.dart';
import '../models/analytics_time_period.dart';

class CanteenAnalyticsProvider extends ChangeNotifier {
  CanteenAnalyticsData? _analyticsData;
  bool _isLoading = false;
  String? _errorMessage;
  DateRange _dateRange = DateRange.today();
  String? _canteenId;

  CanteenAnalyticsData? get analyticsData => _analyticsData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateRange get dateRange => _dateRange;

  Future<void> loadAnalytics(String canteenId, DateRange range) async {
    _canteenId = canteenId;
    _dateRange = range;

    // Return cached data if valid and canteen matches
    if (_analyticsData != null &&
        _analyticsData!.isCacheValid() &&
        _canteenId == canteenId) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch orders for current period
      final orders = await _fetchOrders(canteenId, range);

      // Fetch orders for previous week (for comparison)
      final previousWeekRange = _getPreviousWeekRange(range);
      final previousWeekOrders = await _fetchOrders(canteenId, previousWeekRange);

      // Calculate metrics
      final totalOrders = orders.length;
      final totalRevenue = orders.fold<double>(
        0,
        (total, doc) => total + ((doc.data() as Map)['total_amount'] ?? 0),
      );
      final averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

      // Calculate previous week metrics
      final previousWeekOrderCount = previousWeekOrders.length;
      final previousWeekRevenue = previousWeekOrders.fold<double>(
        0,
        (total, doc) => total + ((doc.data() as Map)['total_amount'] ?? 0),
      );

      // Calculate popular items
      final itemCounts = <String, int>{};
      final itemRevenues = <String, double>{};

      for (var doc in orders) {
        final data = doc.data() as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];

        for (var item in items) {
          final itemName = item['name'] ?? 'Unknown';
          final quantity = (item['quantity'] ?? 1) as int;
          final price = (item['price'] ?? 0).toDouble();

          itemCounts[itemName] = (itemCounts[itemName] ?? 0) + quantity;
          itemRevenues[itemName] = (itemRevenues[itemName] ?? 0) + (price * quantity);
        }
      }

      // Sort items by order count and take top 5
      final sortedItems = itemCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final popularItems = sortedItems.take(5).map((entry) {
        return PopularMenuItem(
          itemName: entry.key,
          orderCount: entry.value,
          revenue: itemRevenues[entry.key] ?? 0,
        );
      }).toList();

      // Calculate orders by hour
      final ordersByHour = <int, int>{};
      for (var i = 0; i < 24; i++) {
        ordersByHour[i] = 0;
      }

      for (var doc in orders) {
        final data = doc.data() as Map<String, dynamic>;
        final fulfillmentSlot = data['fulfillment_slot'] as Timestamp?;
        if (fulfillmentSlot != null) {
          final date = fulfillmentSlot.toDate();
          final hour = date.hour;
          ordersByHour[hour] = (ordersByHour[hour] ?? 0) + 1;
        }
      }

      _analyticsData = CanteenAnalyticsData(
        ordersFulfilled: totalOrders,
        totalRevenue: totalRevenue,
        averageOrderValue: averageOrderValue,
        popularItems: popularItems,
        ordersByHour: ordersByHour,
        previousWeekOrders: previousWeekOrderCount,
        previousWeekRevenue: previousWeekRevenue,
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

  Future<List<QueryDocumentSnapshot>> _fetchOrders(
    String canteenId,
    DateRange range,
  ) async {
    final snapshot = await FirebaseService.orders
        .where('canteen_id', isEqualTo: canteenId)
        .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(range.startDate))
        .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(range.endDate))
        .get();
    return snapshot.docs;
  }

  DateRange _getPreviousWeekRange(DateRange currentRange) {
    final duration = currentRange.endDate.difference(currentRange.startDate);
    final previousStart = currentRange.startDate.subtract(duration);
    final previousEnd = currentRange.endDate.subtract(duration);
    return DateRange.custom(previousStart, previousEnd);
  }

  void clearCache() {
    _analyticsData = null;
    notifyListeners();
  }
}
