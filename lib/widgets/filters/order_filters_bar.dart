import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../models/order_filter_state.dart';
import '../../providers/orders_provider.dart';
import 'filter_chip_widget.dart';

class OrderFiltersBar extends StatefulWidget {
  const OrderFiltersBar({super.key});

  @override
  State<OrderFiltersBar> createState() => _OrderFiltersBarState();
}

class _OrderFiltersBarState extends State<OrderFiltersBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<OrdersProvider>();
    _searchController.text = provider.filterState.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersProvider>(
      builder: (context, provider, _) {
        final filterState = provider.filterState;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with clear filters button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (filterState.activeFilterCount > 0)
                    TextButton.icon(
                      onPressed: () {
                        provider.clearFilters();
                        _searchController.clear();
                      },
                      icon: Icon(Icons.clear, size: 16, color: AppColors.error),
                      label: Text(
                        'Clear (${filterState.activeFilterCount})',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Search field
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  provider.updateFilters(
                    filterState.copyWith(searchQuery: value),
                  );
                },
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search by Order ID...',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.base,
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
              const SizedBox(height: 16),

              // Status filters
              Text(
                'Status',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'pending',
                  'preparing',
                  'ready',
                  'assigned',
                  'delivering',
                  'delivered',
                  'completed',
                  'cancelled',
                ].map((status) {
                  return FilterChipWidget(
                    label: status[0].toUpperCase() + status.substring(1),
                    isSelected: filterState.statusFilters.contains(status),
                    onTap: () {
                      final newFilters = Set<String>.from(filterState.statusFilters);
                      if (newFilters.contains(status)) {
                        newFilters.remove(status);
                      } else {
                        newFilters.add(status);
                      }
                      provider.updateFilters(
                        filterState.copyWith(statusFilters: newFilters),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Fulfillment type filters
              Text(
                'Fulfillment Type',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChipWidget(
                    label: 'Pickup',
                    icon: Icons.store,
                    isSelected: filterState.fulfillmentTypeFilters.contains('pickup'),
                    onTap: () {
                      final newFilters = Set<String>.from(
                        filterState.fulfillmentTypeFilters,
                      );
                      if (newFilters.contains('pickup')) {
                        newFilters.remove('pickup');
                      } else {
                        newFilters.add('pickup');
                      }
                      provider.updateFilters(
                        filterState.copyWith(fulfillmentTypeFilters: newFilters),
                      );
                    },
                  ),
                  FilterChipWidget(
                    label: 'Delivery',
                    icon: Icons.delivery_dining,
                    isSelected: filterState.fulfillmentTypeFilters.contains('delivery'),
                    onTap: () {
                      final newFilters = Set<String>.from(
                        filterState.fulfillmentTypeFilters,
                      );
                      if (newFilters.contains('delivery')) {
                        newFilters.remove('delivery');
                      } else {
                        newFilters.add('delivery');
                      }
                      provider.updateFilters(
                        filterState.copyWith(fulfillmentTypeFilters: newFilters),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date range and sort
              Row(
                children: [
                  // Date range
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date Range',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => _showDateRangePicker(context, provider, filterState),
                          icon: Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: (filterState.startDate != null || filterState.endDate != null)
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          label: Text(
                            _getDateRangeText(filterState),
                            style: TextStyle(
                              color: (filterState.startDate != null || filterState.endDate != null)
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: (filterState.startDate != null || filterState.endDate != null)
                                  ? AppColors.primary
                                  : AppColors.borderColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Sort options
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sort By',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: filterState.sortBy,
                          onChanged: (value) {
                            if (value != null) {
                              provider.updateFilters(
                                filterState.copyWith(sortBy: value),
                              );
                            }
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.base,
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          dropdownColor: AppColors.surface,
                          style: TextStyle(color: AppColors.textPrimary),
                          items: [
                            DropdownMenuItem(
                              value: 'time',
                              child: Row(
                                children: [
                                  Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Text('Time'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'amount',
                              child: Row(
                                children: [
                                  Icon(Icons.currency_rupee, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Text('Amount'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'status',
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Text('Status'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Sort direction toggle
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: IconButton(
                      onPressed: () {
                        provider.updateFilters(
                          filterState.copyWith(sortAscending: !filterState.sortAscending),
                        );
                      },
                      icon: Icon(
                        filterState.sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: AppColors.primary,
                      ),
                      tooltip: filterState.sortAscending ? 'Ascending' : 'Descending',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDateRangeText(OrderFilterState filterState) {
    if (filterState.startDate != null && filterState.endDate != null) {
      return '${_formatDate(filterState.startDate!)} - ${_formatDate(filterState.endDate!)}';
    } else if (filterState.startDate != null) {
      return 'From ${_formatDate(filterState.startDate!)}';
    } else if (filterState.endDate != null) {
      return 'Until ${_formatDate(filterState.endDate!)}';
    }
    return 'Select Range';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showDateRangePicker(
    BuildContext context,
    OrdersProvider provider,
    OrderFilterState filterState,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
      initialDateRange: (filterState.startDate != null && filterState.endDate != null)
          ? DateTimeRange(
              start: filterState.startDate!,
              end: filterState.endDate!,
            )
          : null,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      provider.updateFilters(
        filterState.copyWith(
          startDate: picked.start,
          endDate: picked.end,
        ),
      );
    }
  }
}
