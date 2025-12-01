import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/menu_provider.dart';
import '../../models/menu_item_model.dart';
import '../../widgets/dialogs/menu_item_form_dialog.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  final List<String> _categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Snacks',
    'Beverages',
    'Desserts',
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final menuProvider = context.watch<MenuProvider>();
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
                _buildHeader(context, canteenId),
                _buildFilters(),
                Expanded(
                  child: canteenId == null
                      ? const Center(child: Text('No canteen assigned'))
                      : StreamBuilder<List<MenuItemModel>>(
                          stream: menuProvider.streamMenuItems(canteenId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }

                            var menuItems = snapshot.data ?? [];

                            // Apply filters
                            menuItems = _applyFilters(menuItems);

                            if (menuItems.isEmpty) {
                              return _buildEmptyState();
                            }

                            return _buildDataTable(menuItems, canteenId);
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
            context,
            icon: Icons.dashboard,
            label: 'Dashboard',
            route: Routes.canteenDashboard,
          ),
          _buildSidebarMenuItem(
            context,
            icon: Icons.restaurant_menu,
            label: 'Menu Management',
            isActive: true,
          ),
          _buildSidebarMenuItem(
            context,
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

  Widget _buildHeader(BuildContext context, String? canteenId) {
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
            child: Text(
              'Menu Management',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(canteenId),
            icon: const Icon(Icons.add),
            label: const Text('Add Menu Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search menu items...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          // Category filter
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: _selectedCategory ?? 'All',
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              items: _categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value == 'All' ? null : value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  List<MenuItemModel> _applyFilters(List<MenuItemModel> items) {
    var filtered = items;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((item) =>
              item.name.toLowerCase().contains(_searchQuery) ||
              item.description.toLowerCase().contains(_searchQuery))
          .toList();
    }

    // Category filter
    if (_selectedCategory != null) {
      filtered = filtered
          .where((item) => item.category == _selectedCategory)
          .toList();
    }

    return filtered;
  }

  Widget _buildDataTable(List<MenuItemModel> items, String canteenId) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 900,
        columns: const [
          DataColumn2(label: Text('Image'), size: ColumnSize.S),
          DataColumn2(label: Text('Name'), size: ColumnSize.L),
          DataColumn2(label: Text('Category'), size: ColumnSize.M),
          DataColumn2(label: Text('Price'), size: ColumnSize.S),
          DataColumn2(label: Text('Available'), size: ColumnSize.S),
          DataColumn2(label: Text('Actions'), size: ColumnSize.M),
        ],
        rows: items.map((item) {
          return DataRow2(
            cells: [
              // Image
              DataCell(
                item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          item.imageUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported);
                          },
                        ),
                      )
                    : const Icon(Icons.restaurant_menu),
              ),
              // Name
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Category
              DataCell(
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.category,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              // Price
              DataCell(Text('₹${item.price.toStringAsFixed(2)}')),
              // Available
              DataCell(
                Switch(
                  value: item.isAvailable,
                  onChanged: (value) {
                    context
                        .read<MenuProvider>()
                        .toggleItemAvailability(canteenId, item.id, value);
                  },
                  activeColor: AppColors.success,
                ),
              ),
              // Actions
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditDialog(canteenId, item),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, size: 20, color: AppColors.error),
                      onPressed: () => _confirmDelete(canteenId, item),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: 64,
            color: AppColors.textSecondary.withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            'No menu items found',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _showAddDialog(context.read<AuthProvider>().canteenId),
            icon: const Icon(Icons.add),
            label: const Text('Add your first menu item'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(String? canteenId) {
    if (canteenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No canteen assigned to your account'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => MenuItemFormDialog(
        canteenId: canteenId,
      ),
    );
  }

  void _showEditDialog(String canteenId, MenuItemModel item) {
    showDialog(
      context: context,
      builder: (context) => MenuItemFormDialog(
        canteenId: canteenId,
        item: item,
      ),
    );
  }

  void _confirmDelete(String canteenId, MenuItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context
                    .read<MenuProvider>()
                    .deleteMenuItem(canteenId, item.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Menu item deleted successfully'),
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
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
