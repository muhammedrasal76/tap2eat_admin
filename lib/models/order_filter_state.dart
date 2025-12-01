class OrderFilterState {
  final Set<String> statusFilters;
  final Set<String> fulfillmentTypeFilters;
  final DateTime? startDate;
  final DateTime? endDate;
  final String searchQuery;
  final String sortBy; // 'time', 'amount', 'status'
  final bool sortAscending;

  OrderFilterState({
    this.statusFilters = const {'pending', 'preparing', 'ready'},
    this.fulfillmentTypeFilters = const {},
    this.startDate,
    this.endDate,
    this.searchQuery = '',
    this.sortBy = 'time',
    this.sortAscending = true,
  });

  OrderFilterState copyWith({
    Set<String>? statusFilters,
    Set<String>? fulfillmentTypeFilters,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? sortBy,
    bool? sortAscending,
  }) {
    return OrderFilterState(
      statusFilters: statusFilters ?? this.statusFilters,
      fulfillmentTypeFilters: fulfillmentTypeFilters ?? this.fulfillmentTypeFilters,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  int get activeFilterCount {
    int count = 0;
    if (statusFilters.isNotEmpty && statusFilters.length < 6) count++;
    if (fulfillmentTypeFilters.isNotEmpty) count++;
    if (startDate != null || endDate != null) count++;
    if (searchQuery.isNotEmpty) count++;
    return count;
  }
}
