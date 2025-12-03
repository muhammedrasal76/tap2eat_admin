import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/master_analytics_provider.dart';
import '../../models/analytics_time_period.dart';
import '../../widgets/analytics/stat_card.dart';
import '../../widgets/analytics/time_period_selector.dart';
import '../../widgets/analytics/chart_container.dart';
import '../../widgets/analytics/orders_over_time_chart.dart';
import '../../widgets/analytics/order_type_pie_chart.dart';
import '../../widgets/analytics/revenue_by_canteen_chart.dart';

class MasterDashboardScreen extends StatefulWidget {
  const MasterDashboardScreen({super.key});

  @override
  State<MasterDashboardScreen> createState() => _MasterDashboardScreenState();
}

class _MasterDashboardScreenState extends State<MasterDashboardScreen> {
  TimePeriod _selectedPeriod = TimePeriod.today;

  @override
  void initState() {
    super.initState();
    // Load initial analytics data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MasterAnalyticsProvider>().loadAnalytics(DateRange.today());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(context),

          // Main content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(
                  child: Consumer<MasterAnalyticsProvider>(
                    builder: (context, analyticsProvider, _) {
                      final isLoading = analyticsProvider.isLoading;
                      final analyticsData = analyticsProvider.analyticsData;
                      final errorMessage = analyticsProvider.errorMessage;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time Period Selector
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Analytics Overview',
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                        fontSize: 20,
                                      ),
                                ),
                                TimePeriodSelector(
                                  selectedPeriod: _selectedPeriod,
                                  onPeriodChanged: (range) {
                                    setState(() {
                                      _selectedPeriod = range.period;
                                    });
                                    analyticsProvider.loadAnalytics(range);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Stat Cards
                            if (errorMessage != null)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Text(
                                    errorMessage,
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ),
                              )
                            else if (isLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (analyticsData != null)
                              Column(
                                children: [
                                  // Stat Cards Grid
                                  GridView.count(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 1.8,
                                    children: [
                                      StatCard(
                                        title: 'Total Orders',
                                        value: analyticsData.totalOrders.toString(),
                                        icon: Icons.shopping_bag,
                                        color: AppColors.primary,
                                      ),
                                      StatCard(
                                        title: 'Total Revenue',
                                        value: '₹${analyticsData.totalRevenue.toStringAsFixed(2)}',
                                        icon: Icons.currency_rupee,
                                        color: AppColors.success,
                                      ),
                                      StatCard(
                                        title: 'Active Canteens',
                                        value: analyticsData.activeCanteens.toString(),
                                        icon: Icons.restaurant,
                                        color: AppColors.info,
                                      ),
                                      StatCard(
                                        title: 'Delivery Students',
                                        value: analyticsData.deliveryStudents.toString(),
                                        icon: Icons.delivery_dining,
                                        color: AppColors.warning,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),

                                  // Charts
                                  ChartContainer(
                                    title: 'Orders Over Time (Last 7 Days)',
                                    chart: OrdersOverTimeChart(
                                      ordersByDay: analyticsData.ordersByDay,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: ChartContainer(
                                          title: 'Order Type Distribution',
                                          chart: OrderTypePieChart(
                                            ordersByType: analyticsData.ordersByType,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: ChartContainer(
                                          title: 'Revenue by Canteen',
                                          chart: RevenueByCanteenChart(
                                            revenueByCanteen: analyticsData.revenueByCanteen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      color: AppColors.surface,
      child: Column(
        children: [
          _buildSidebarHeader(context),
          _buildSidebarMenuItem(
            context,
            icon: Icons.dashboard,
            label: 'Dashboard',
            isActive: true,
          ),
          _buildSidebarMenuItem(
            context,
            icon: Icons.schedule,
            label: 'Break Slots',
            route: Routes.masterBreakSlots,
          ),
          _buildSidebarMenuItem(
            context,
            icon: Icons.history,
            label: 'Audit Logs',
            route: Routes.masterAuditLogs,
          ),
          _buildSidebarMenuItem(
            context,
            icon: Icons.settings,
            label: 'System Settings',
          ),
          const Spacer(),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: AppColors.onPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Master Admin',
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isActive = false,
    String? route,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withAlpha(25) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: route != null ? () => context.go(route) : null,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListTile(
        leading: const Icon(Icons.logout, color: AppColors.error),
        title: const Text(
          'Logout',
          style: TextStyle(color: AppColors.error),
        ),
        onTap: () => context.read<AuthProvider>().signOut(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: Text(
        'System Overview',
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }

}
