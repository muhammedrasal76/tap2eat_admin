import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/colors.dart';
import '../../models/order_model.dart';
import '../../providers/orders_provider.dart';
import '../badges/status_badge.dart';
import 'delivery_assignment_dialog.dart';

class OrderDetailsDialog extends StatefulWidget {
  final OrderModel order;

  const OrderDetailsDialog({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsDialog> createState() => _OrderDetailsDialogState();
}

class _OrderDetailsDialogState extends State<OrderDetailsDialog> {
  Map<String, dynamic>? _userData;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final provider = context.read<OrdersProvider>();
    final userData = await provider.getUserData(widget.order.userId);
    if (mounted) {
      setState(() {
        _userData = userData;
        _isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.base,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${widget.order.id}',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.order.getFormattedFulfillmentSlot(),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: widget.order.status),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Information
                    _buildSection(
                      'Customer Information',
                      Icons.person,
                      _isLoadingUser
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Name', _userData?['name'] ?? 'N/A'),
                                _buildInfoRow('Email', _userData?['email'] ?? 'N/A'),
                                _buildInfoRow('Role', _userData?['role'] ?? 'N/A'),
                                if (_userData?['class_id'] != null)
                                  _buildInfoRow('Class', _userData!['class_id']),
                                if (_userData?['designation'] != null)
                                  _buildInfoRow('Designation', _userData!['designation']),
                              ],
                            ),
                    ),
                    const SizedBox(height: 20),

                    // Order Items
                    _buildSection(
                      'Order Items',
                      Icons.restaurant_menu,
                      Column(
                        children: [
                          ...widget.order.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.base,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${item['quantity']}x',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'],
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (item['customizations'] != null &&
                                            item['customizations'].isNotEmpty)
                                          Text(
                                            item['customizations'],
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${item['price'].toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          Divider(color: AppColors.borderColor),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                              Text(
                                '₹${(widget.order.totalAmount - widget.order.deliveryFee).toStringAsFixed(2)}',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          if (widget.order.deliveryFee > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Delivery Fee',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                                Text(
                                  '₹${widget.order.deliveryFee.toStringAsFixed(2)}',
                                  style: TextStyle(color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '₹${widget.order.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Fulfillment Information
                    _buildSection(
                      'Fulfillment Information',
                      Icons.local_shipping,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            'Type',
                            widget.order.fulfillmentType[0].toUpperCase() +
                                widget.order.fulfillmentType.substring(1),
                          ),
                          _buildInfoRow(
                            'Slot',
                            widget.order.getFormattedFulfillmentSlot(),
                          ),
                          if (widget.order.isDeliveryOrder) ...[
                            _buildInfoRow(
                              'Delivery Status',
                              widget.order.hasDeliveryAssignment
                                  ? 'Assigned'
                                  : 'Unassigned',
                            ),
                            if (widget.order.hasDeliveryAssignment)
                              FutureBuilder<Map<String, dynamic>>(
                                future: context
                                    .read<OrdersProvider>()
                                    .getUserData(widget.order.deliveryStudentId!),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return _buildInfoRow(
                                      'Delivery Student',
                                      snapshot.data?['name'] ?? 'N/A',
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Order Timeline
                    _buildSection(
                      'Order Timeline',
                      Icons.timeline,
                      Column(
                        children: [
                          _buildTimelineItem(
                            'Order Placed',
                            widget.order.createdAt != null
                                ? DateFormat('MMM dd, yyyy h:mm a')
                                    .format(widget.order.createdAt!.toDate())
                                : 'N/A',
                            true,
                          ),
                          if (widget.order.status != 'pending')
                            _buildTimelineItem(
                              'Preparing',
                              widget.order.updatedAt != null
                                  ? DateFormat('MMM dd, yyyy h:mm a')
                                      .format(widget.order.updatedAt!.toDate())
                                  : 'N/A',
                              ['preparing', 'ready', 'assigned', 'delivering', 'delivered', 'completed']
                                  .contains(widget.order.status),
                            ),
                          if (['ready', 'assigned', 'delivering', 'delivered', 'completed']
                              .contains(widget.order.status))
                            _buildTimelineItem(
                              'Ready',
                              widget.order.updatedAt != null
                                  ? DateFormat('MMM dd, yyyy h:mm a')
                                      .format(widget.order.updatedAt!.toDate())
                                  : 'N/A',
                              true,
                            ),
                          if (['delivered', 'completed'].contains(widget.order.status))
                            _buildTimelineItem(
                              'Completed',
                              widget.order.updatedAt != null
                                  ? DateFormat('MMM dd, yyyy h:mm a')
                                      .format(widget.order.updatedAt!.toDate())
                                  : 'N/A',
                              true,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.base,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // Print button
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement print functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Print functionality coming soon'),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                    icon: Icon(Icons.print, size: 18, color: AppColors.textSecondary),
                    label: Text(
                      'Print',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.borderColor),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Assign delivery student (for delivery orders only)
                  if (widget.order.isDeliveryOrder &&
                      !widget.order.hasDeliveryAssignment &&
                      widget.order.status == 'ready')
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => DeliveryAssignmentDialog(
                            orderId: widget.order.id,
                          ),
                        );
                      },
                      icon: Icon(Icons.delivery_dining, size: 18),
                      label: Text('Assign Delivery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: AppColors.onPrimary,
                      ),
                    ),

                  const Spacer(),

                  // Status update button
                  if (widget.order.status == 'pending')
                    ElevatedButton.icon(
                      onPressed: () => _updateOrderStatus(context, 'preparing'),
                      icon: Icon(Icons.play_arrow, size: 18),
                      label: Text('Start Preparing'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                      ),
                    ),
                  if (widget.order.status == 'preparing')
                    ElevatedButton.icon(
                      onPressed: () => _updateOrderStatus(context, 'ready'),
                      icon: Icon(Icons.check, size: 18),
                      label: Text('Mark as Ready'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.onPrimary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.base,
            borderRadius: BorderRadius.circular(8),
          ),
          child: content,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String time, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.success : AppColors.borderColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(BuildContext context, String newStatus) async {
    final provider = context.read<OrdersProvider>();

    try {
      await provider.updateOrderStatus(widget.order.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $newStatus'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
