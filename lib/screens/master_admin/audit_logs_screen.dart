import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/audit_logs_provider.dart';
import '../../models/audit_log_model.dart';
import '../../widgets/layouts/page_header.dart';
import '../../widgets/loading/table_row_skeleton.dart';
import '../../widgets/errors/retry_error_widget.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final TextEditingController _searchController = TextEditingController();
  AuditLogModel? _expandedLog;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuditLogsProvider>().loadLogs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),

          // Main content
          Expanded(
            child: Column(
              children: [
                PageHeader(
                  title: 'Audit Logs',
                  subtitle: 'System activity and user actions',
                  actions: [
                    IconButton(
                      onPressed: () {
                        context.read<AuditLogsProvider>().loadLogs();
                      },
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
                Expanded(
                  child: Consumer<AuditLogsProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return _buildLoadingState();
                      }

                      if (provider.error != null) {
                        return RetryErrorWidget(
                          message: 'Failed to load audit logs',
                          errorDetails: provider.error,
                          onRetry: () => provider.loadLogs(),
                        );
                      }

                      return Column(
                        children: [
                          // Filters
                          _buildFilters(provider),

                          // Results count
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${provider.logs.length} log${provider.logs.length == 1 ? '' : 's'} found',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                if (provider.startDate != null ||
                                    provider.endDate != null ||
                                    provider.selectedUserId != null ||
                                    provider.selectedAction != null ||
                                    provider.searchQuery.isNotEmpty)
                                  TextButton.icon(
                                    onPressed: () {
                                      _searchController.clear();
                                      provider.clearFilters();
                                    },
                                    icon: const Icon(Icons.clear, size: 16),
                                    label: const Text('Clear Filters'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Data table
                          Expanded(
                            child: provider.logs.isEmpty
                                ? _buildEmptyState()
                                : _buildDataTable(provider.logs),
                          ),
                        ],
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

  Widget _buildFilters(AuditLogsProvider provider) {
    final users = provider.getUniqueUsers();
    final actions = provider.getUniqueActions();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Search and Date Range
          Row(
            children: [
              // Search
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => provider.updateSearchQuery(value),
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by user, action, or log ID...',
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
              const SizedBox(width: 16),

              // Date Range
              OutlinedButton.icon(
                onPressed: () => _showDateRangePicker(provider),
                icon: Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: (provider.startDate != null || provider.endDate != null)
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                label: Text(
                  _getDateRangeText(provider),
                  style: TextStyle(
                    color: (provider.startDate != null || provider.endDate != null)
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  side: BorderSide(
                    color: (provider.startDate != null || provider.endDate != null)
                        ? AppColors.primary
                        : AppColors.borderColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // User and Action filters
          Row(
            children: [
              // User filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: provider.selectedUserId,
                  hint: Text(
                    'All Users',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  onChanged: (value) => provider.updateUserFilter(value),
                  decoration: InputDecoration(
                    labelText: 'User',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
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
                      value: null,
                      child: Text('All Users'),
                    ),
                    ...users.entries.map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Action filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: provider.selectedAction,
                  hint: Text(
                    'All Actions',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  onChanged: (value) => provider.updateActionFilter(value),
                  decoration: InputDecoration(
                    labelText: 'Action',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
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
                      value: null,
                      child: Text('All Actions'),
                    ),
                    ...actions.map(
                      (action) => DropdownMenuItem(
                        value: action,
                        child: Text(action),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<AuditLogModel> logs) {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 900,
        headingRowColor: WidgetStateProperty.all(AppColors.base),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.1);
          }
          return AppColors.surface;
        }),
        columns: [
          DataColumn2(
            label: Text(
              'Timestamp',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            size: ColumnSize.S,
          ),
          DataColumn2(
            label: Text(
              'User',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            size: ColumnSize.M,
          ),
          DataColumn2(
            label: Text(
              'Role',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            size: ColumnSize.S,
          ),
          DataColumn2(
            label: Text(
              'Action',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Text(
              'Resource',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            size: ColumnSize.M,
          ),
          DataColumn2(
            label: Text(
              'Details',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            size: ColumnSize.S,
          ),
        ],
        rows: logs.map((log) {
          final isExpanded = _expandedLog?.id == log.id;
          return DataRow2(
            selected: isExpanded,
            onTap: () {
              setState(() {
                _expandedLog = isExpanded ? null : log;
              });
            },
            cells: [
              DataCell(
                Text(
                  log.getFormattedTimestamp(),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      log.userName,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      log.userId.substring(0, 8),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRoleColor(log.userRole).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    log.userRole,
                    style: TextStyle(
                      color: _getRoleColor(log.userRole),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  log.getActionDescription(),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              DataCell(
                Text(
                  log.resourceType != null
                      ? '${log.resourceType} (${log.resourceId?.substring(0, 8) ?? ''})'
                      : '-',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              DataCell(
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 10,
      itemBuilder: (context, index) => const TableRowSkeleton(columns: 6),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No audit logs found',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'master_admin':
        return AppColors.error;
      case 'canteen_admin':
        return AppColors.primary;
      case 'delivery_student':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getDateRangeText(AuditLogsProvider provider) {
    if (provider.startDate != null && provider.endDate != null) {
      return '${_formatDate(provider.startDate!)} - ${_formatDate(provider.endDate!)}';
    } else if (provider.startDate != null) {
      return 'From ${_formatDate(provider.startDate!)}';
    } else if (provider.endDate != null) {
      return 'Until ${_formatDate(provider.endDate!)}';
    }
    return 'Date Range';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showDateRangePicker(AuditLogsProvider provider) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: (provider.startDate != null && provider.endDate != null)
          ? DateTimeRange(
              start: provider.startDate!,
              end: provider.endDate!,
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
      provider.updateDateRange(picked.start, picked.end);
    }
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: AppColors.surface,
      child: Column(
        children: [
          _buildSidebarHeader(),
          _buildSidebarMenuItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            route: Routes.masterDashboard,
          ),
          _buildSidebarMenuItem(
            icon: Icons.schedule,
            label: 'Break Slots',
            route: Routes.masterBreakSlots,
          ),
          _buildSidebarMenuItem(
            icon: Icons.history,
            label: 'Audit Logs',
            isActive: true,
          ),
          _buildSidebarMenuItem(
            icon: Icons.settings,
            label: 'System Settings',
          ),
          const Spacer(),
          _buildLogoutButton(),
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
        color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
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

  Widget _buildLogoutButton() {
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
}
