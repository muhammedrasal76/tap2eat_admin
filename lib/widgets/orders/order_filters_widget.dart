import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/colors.dart';

class OrderFiltersWidget extends StatefulWidget {
  final String? selectedStatus;
  final String? selectedFulfillmentType;
  final DateTimeRange? dateRange;
  final String? searchQuery;
  final Function(String?) onStatusChanged;
  final Function(String?) onFulfillmentTypeChanged;
  final Function(DateTimeRange?) onDateRangeChanged;
  final Function(String?) onSearchChanged;
  final VoidCallback onClearFilters;

  const OrderFiltersWidget({
    super.key,
    this.selectedStatus,
    this.selectedFulfillmentType,
    this.dateRange,
    this.searchQuery,
    required this.onStatusChanged,
    required this.onFulfillmentTypeChanged,
    required this.onDateRangeChanged,
    required this.onSearchChanged,
    required this.onClearFilters,
  });

  @override
  State<OrderFiltersWidget> createState() => _OrderFiltersWidgetState();
}

class _OrderFiltersWidgetState extends State<OrderFiltersWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeFilterCount = _getActiveFilterCount();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar and Clear Button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: widget.onSearchChanged,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by order ID...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: AppColors.base,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Date Range Picker
              OutlinedButton.icon(
                onPressed: _pickDateRange,
                icon: Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
                label: Text(
                  widget.dateRange != null
                      ? '${DateFormat('MMM d').format(widget.dateRange!.start)} - ${DateFormat('MMM d').format(widget.dateRange!.end)}'
                      : 'Date Range',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  backgroundColor: widget.dateRange != null
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surface,
                  side: BorderSide(
                    color: widget.dateRange != null
                        ? AppColors.primary
                        : AppColors.borderColor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              if (activeFilterCount > 0) ...[
                const SizedBox(width: 12),
                // Clear Filters Button
                TextButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    widget.onClearFilters();
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: Text('Clear ($activeFilterCount)'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Status Filter Chips
          Row(
            children: [
              Text(
                'Status:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip('All', null, widget.selectedStatus, widget.onStatusChanged),
                    _buildFilterChip('Pending', 'pending', widget.selectedStatus, widget.onStatusChanged),
                    _buildFilterChip('Preparing', 'preparing', widget.selectedStatus, widget.onStatusChanged),
                    _buildFilterChip('Ready', 'ready', widget.selectedStatus, widget.onStatusChanged),
                    _buildFilterChip('Assigned', 'assigned', widget.selectedStatus, widget.onStatusChanged),
                    _buildFilterChip('Delivering', 'delivering', widget.selectedStatus, widget.onStatusChanged),
                    _buildFilterChip('Delivered', 'delivered', widget.selectedStatus, widget.onStatusChanged),
                    _buildFilterChip('Completed', 'completed', widget.selectedStatus, widget.onStatusChanged),
                    _buildFilterChip('Cancelled', 'cancelled', widget.selectedStatus, widget.onStatusChanged),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Fulfillment Type Filter Chips
          Row(
            children: [
              Text(
                'Type:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip('All', null, widget.selectedFulfillmentType, widget.onFulfillmentTypeChanged),
                  _buildFilterChip('Pickup', 'pickup', widget.selectedFulfillmentType, widget.onFulfillmentTypeChanged),
                  _buildFilterChip('Delivery', 'delivery', widget.selectedFulfillmentType, widget.onFulfillmentTypeChanged),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String? value,
    String? currentValue,
    Function(String?) onChanged,
  ) {
    final isSelected = currentValue == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        onChanged(selected ? value : null);
      },
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      backgroundColor: AppColors.base,
      selectedColor: AppColors.primary.withValues(alpha: 0.1),
      checkmarkColor: AppColors.primary,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.borderColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      currentDate: DateTime.now(),
      initialDateRange: widget.dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.base,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onDateRangeChanged(picked);
    }
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (widget.selectedStatus != null) count++;
    if (widget.selectedFulfillmentType != null) count++;
    if (widget.dateRange != null) count++;
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) count++;
    return count;
  }
}
