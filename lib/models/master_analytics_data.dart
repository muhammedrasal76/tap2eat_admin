class MasterAnalyticsData {
  final int totalOrders;
  final double totalRevenue;
  final int activeCanteens;
  final int deliveryStudents;
  final Map<DateTime, int> ordersByDay; // Last 7 days
  final Map<String, int> ordersByType; // pickup vs delivery
  final Map<String, double> revenueByCanteen;
  final DateTime lastUpdated;

  MasterAnalyticsData({
    required this.totalOrders,
    required this.totalRevenue,
    required this.activeCanteens,
    required this.deliveryStudents,
    required this.ordersByDay,
    required this.ordersByType,
    required this.revenueByCanteen,
    required this.lastUpdated,
  });

  bool isCacheValid() {
    return DateTime.now().difference(lastUpdated).inMinutes < 5;
  }
}
