class PopularMenuItem {
  final String itemName;
  final int orderCount;
  final double revenue;

  PopularMenuItem({
    required this.itemName,
    required this.orderCount,
    required this.revenue,
  });
}

class CanteenAnalyticsData {
  final int ordersFulfilled;
  final double totalRevenue;
  final double averageOrderValue;
  final List<PopularMenuItem> popularItems;
  final Map<int, int> ordersByHour; // hour (0-23) -> count
  final int previousWeekOrders;
  final double previousWeekRevenue;
  final DateTime lastUpdated;

  CanteenAnalyticsData({
    required this.ordersFulfilled,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.popularItems,
    required this.ordersByHour,
    required this.previousWeekOrders,
    required this.previousWeekRevenue,
    required this.lastUpdated,
  });

  bool isCacheValid() {
    return DateTime.now().difference(lastUpdated).inMinutes < 5;
  }

  double get weekOverWeekOrdersChange {
    if (previousWeekOrders == 0) return 0;
    return ((ordersFulfilled - previousWeekOrders) / previousWeekOrders) * 100;
  }

  double get weekOverWeekRevenueChange {
    if (previousWeekRevenue == 0) return 0;
    return ((totalRevenue - previousWeekRevenue) / previousWeekRevenue) * 100;
  }
}
