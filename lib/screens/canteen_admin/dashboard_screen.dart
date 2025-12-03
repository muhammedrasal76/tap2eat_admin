import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/canteen_analytics_provider.dart';
import '../../models/order_model.dart';
import '../../models/analytics_time_period.dart';
import '../../widgets/badges/status_badge.dart';
import '../../widgets/filters/order_filters_bar.dart';
import '../../widgets/dialogs/order_details_dialog.dart';
import '../../widgets/analytics/stat_card.dart';
import '../../widgets/analytics/time_period_selector.dart';
import '../../widgets/analytics/chart_container.dart';
import '../../widgets/analytics/peak_hours_chart.dart';
import '../../widgets/analytics/popular_items_list.dart';

class CanteenDashboardScreen extends StatefulWidget {
  const CanteenDashboardScreen({super.key});

  @override
  State<CanteenDashboardScreen> createState() => _CanteenDashboardScreenState();
}

class _CanteenDashboardScreenState extends State<CanteenDashboardScreen> {
  TimePeriod _selectedPeriod = TimePeriod.today;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final canteenId = context.read<AuthProvider>().canteenId;
      if (canteenId != null) {
        context.read<OrdersProvider>().loadOrdersForCanteen(canteenId);
        context.read<CanteenAnalyticsProvider>().loadAnalytics(
              canteenId,
              DateRange.today(),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final ordersProvider = context.watch<OrdersProvider>();
    final canteenId = authProvider.canteenId;

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
                  child: canteenId == null
                      ? const Center(child: Text('No canteen assigned'))
                      : StreamBuilder<List<OrderModel>>(
                          stream: ordersProvider.streamOrdersForCanteen(canteenId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }

                            final orders = ordersProvider.orders;

                            return SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Analytics Section
                                  Consumer<CanteenAnalyticsProvider>(
                                    builder: (context, analyticsProvider, _) {
                                      final analyticsData = analyticsProvider.analyticsData;
                                      final isLoading = analyticsProvider.isLoading;
                                      final errorMessage = analyticsProvider.errorMessage;

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Analytics header with time period selector
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Analytics',
                                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                                      fontSize: 18,
                                                    ),
                                              ),
                                              TimePeriodSelector(
                                                selectedPeriod: _selectedPeriod,
                                                onPeriodChanged: (range) {
                                                  setState(() {
                                                    _selectedPeriod = range.period;
                                                  });
                                                  analyticsProvider.loadAnalytics(canteenId, range);
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),

                                          // Show loading or error states
                                          if (errorMessage != null)
                                            Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(20),
                                                child: Text(
                                                  errorMessage,
                                                  style: TextStyle(color: AppColors.error),
                                                ),
                                              ),
                                            )
                                          else if (isLoading)
                                            const Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(20),
                                                child: CircularProgressIndicator(),
                                              ),
                                            )
                                          else if (analyticsData != null)
                                            Column(
                                              children: [
                                                // Stat cards with week-over-week comparison
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: StatCard(
                                                        title: 'Orders Fulfilled',
                                                        value: analyticsData.ordersFulfilled.toString(),
                                                        icon: Icons.check_circle,
                                                        color: AppColors.success,
                                                        percentageChange: analyticsData.weekOverWeekOrdersChange,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: StatCard(
                                                        title: 'Total Revenue',
                                                        value: '₹${analyticsData.totalRevenue.toStringAsFixed(0)}',
                                                        icon: Icons.currency_rupee,
                                                        color: AppColors.primary,
                                                        percentageChange: analyticsData.weekOverWeekRevenueChange,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: StatCard(
                                                        title: 'Avg Order Value',
                                                        value: '₹${analyticsData.averageOrderValue.toStringAsFixed(0)}',
                                                        icon: Icons.trending_up,
                                                        color: AppColors.info,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 24),

                                                // Charts row
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: ChartContainer(
                                                        title: 'Peak Hours',
                                                        chart: PeakHoursChart(
                                                          ordersByHour: analyticsData.ordersByHour,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 24),
                                                    Expanded(
                                                      child: Container(
                                                        padding: const EdgeInsets.all(20),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.surface,
                                                          borderRadius: BorderRadius.circular(12),
                                                          border: Border.all(color: AppColors.borderColor),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'Popular Items',
                                                              style: TextStyle(
                                                                color: AppColors.textPrimary,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 20),
                                                            PopularItemsList(
                                                              items: analyticsData.popularItems,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          const SizedBox(height: 32),
                                          const Divider(color: AppColors.borderColor),
                                          const SizedBox(height: 24),
                                        ],
                                      );
                                    },
                                  ),

                                  // Orders section header
                                  Text(
                                    'Active Orders',
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                          fontSize: 18,
                                        ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Filters bar
                                  const OrderFiltersBar(),
                                  const SizedBox(height: 24),

                                  // Orders list
                                  if (orders.isEmpty)
                                    _buildEmptyState()
                                  else
                                    Column(
                                      children: [
                                        // Order count
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: Text(
                                            '${orders.length} order${orders.length == 1 ? '' : 's'} found',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        // Order cards
                                        ...orders.map((order) => _buildOrderCard(order)),
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
          _buildSidebarHeader(),
          _buildSidebarMenuItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            isActive: true,
          ),
          _buildSidebarMenuItem(
            icon: Icons.restaurant_menu,
            label: 'Menu Management',
            route: Routes.canteenMenu,
          ),
          _buildSidebarMenuItem(
            icon: Icons.settings,
            label: 'Settings',
            route: Routes.canteenSettings,
          ),
          const Spacer(),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
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
              Icons.restaurant,
              color: AppColors.onPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Tap2Eat',
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarMenuItem({
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
    return Consumer<OrdersProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.borderColor),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Active Orders',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    if (provider.newOrderCount > 0) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications_active,
                              size: 16,
                              color: AppColors.onPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${provider.newOrderCount} new',
                              style: TextStyle(
                                color: AppColors.onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Sound toggle
              IconButton(
                onPressed: () => provider.toggleSound(),
                icon: Icon(
                  provider.soundEnabled
                      ? Icons.volume_up
                      : Icons.volume_off,
                  color: provider.soundEnabled
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                tooltip: provider.soundEnabled
                    ? 'Disable sound notifications'
                    : 'Enable sound notifications',
              ),
              const SizedBox(width: 8),
              // Mark orders as seen button
              if (provider.newOrderCount > 0)
                ElevatedButton.icon(
                  onPressed: () => provider.markOrdersAsSeen(),
                  icon: Icon(Icons.done_all, size: 18),
                  label: Text('Mark as Seen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.textSecondary.withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            'No active orders',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.borderColor, width: 1),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => OrderDetailsDialog(order: order),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id}',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              order.getFormattedFulfillmentSlot(),
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: order.status),
                ],
              ),

              const SizedBox(height: 16),
              Divider(color: AppColors.borderColor),
              const SizedBox(height: 16),

              // Order details
              Row(
                children: [
                  // Items count and type
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.base,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            order.isDeliveryOrder
                                ? Icons.delivery_dining
                                : Icons.restaurant_menu,
                            size: 16,
                            color: order.isDeliveryOrder
                                ? AppColors.warning
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${order.items.length} Item${order.items.length == 1 ? '' : 's'}',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  order.fulfillmentType[0].toUpperCase() +
                                      order.fulfillmentType.substring(1),
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                if (order.isDeliveryOrder && order.hasDeliveryAssignment) ...[
                                  Text(
                                    ' • ',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Icon(
                                    Icons.person,
                                    size: 12,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Assigned',
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Delivery fee badge (if applicable)
                  if (order.deliveryFee > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delivery_dining,
                            size: 12,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '₹${order.deliveryFee.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Total amount
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₹${order.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  // View details button
                  OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => OrderDetailsDialog(order: order),
                      );
                    },
                    icon: Icon(Icons.visibility, size: 16),
                    label: Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  const Spacer(),

                  // Status action buttons
                  if (order.status == 'pending')
                    ElevatedButton.icon(
                      onPressed: () => _updateStatus(order.id, 'preparing'),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Start Preparing'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                      ),
                    ),
                  if (order.status == 'preparing')
                    ElevatedButton.icon(
                      onPressed: () => _updateStatus(order.id, 'ready'),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Mark as Ready'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.onPrimary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateStatus(String orderId, String newStatus) async {
    try {
      await context.read<OrdersProvider>().updateOrderStatus(orderId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order updated to $newStatus'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
