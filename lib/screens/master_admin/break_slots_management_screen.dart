import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/break_slots_provider.dart';
import '../../models/break_slot_model.dart';
import '../../widgets/dialogs/break_slot_form_dialog.dart';

class BreakSlotsManagementScreen extends StatefulWidget {
  const BreakSlotsManagementScreen({super.key});

  @override
  State<BreakSlotsManagementScreen> createState() =>
      _BreakSlotsManagementScreenState();
}

class _BreakSlotsManagementScreenState
    extends State<BreakSlotsManagementScreen> {
  final TextEditingController _cutoffController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<BreakSlotsProvider>();
    _cutoffController.text = provider.orderCutoffMinutes.toString();
  }

  @override
  void dispose() {
    _cutoffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final breakSlotsProvider = context.watch<BreakSlotsProvider>();

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
                _buildSettingsCard(context),
                Expanded(
                  child: StreamBuilder<List<BreakSlotModel>>(
                    stream: breakSlotsProvider.streamBreakSlots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final slots = snapshot.data ?? [];

                      if (slots.isEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildSlotsList(slots);
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
            route: Routes.masterDashboard,
          ),
          _buildSidebarMenuItem(
            icon: Icons.schedule,
            label: 'Break Slots',
            isActive: true,
          ),
          _buildSidebarMenuItem(
            icon: Icons.history,
            label: 'Audit Logs',
            route: Routes.masterAuditLogs,
          ),
          _buildSidebarMenuItem(
            icon: Icons.settings,
            label: 'System Settings',
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

  Widget _buildSidebarMenuItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    String? route,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Break Slots Management',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Configure time slots for student deliveries',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => _showBreakSlotDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Break Slot'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer, color: AppColors.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Cutoff Time',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Minimum minutes before slot start time',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              controller: _cutoffController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                suffixText: 'min',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => _saveOrderCutoff(),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsList(List<BreakSlotModel> slots) {
    // Group slots by day of week
    final groupedSlots = <int, List<BreakSlotModel>>{};
    for (var slot in slots) {
      groupedSlots.putIfAbsent(slot.dayOfWeek, () => []).add(slot);
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: groupedSlots.entries.map((entry) {
        final dayOfWeek = entry.key;
        final daySlots = entry.value;
        final dayName = [
          '',
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ][dayOfWeek];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                dayName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getDayColor(dayOfWeek),
                    ),
              ),
            ),
            ...daySlots.map((slot) => _buildTimeSlotCard(slot)),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlotCard(BreakSlotModel slot) {
    final index = int.parse(slot.id);
    final format = DateFormat('h:mm a');
    final start = slot.startTime.toDate();
    final end = slot.endTime.toDate();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: slot.isActive
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.textSecondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.access_time,
            color: slot.isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        title: Text(
          slot.label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${format.format(start)} - ${format.format(end)}'),
            Text(
              'Duration: ${slot.getDurationMinutes()} minutes',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: slot.isActive,
              onChanged: (value) => _toggleSlot(index, value),
              activeColor: AppColors.success,
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: () => _showBreakSlotDialog(slot: slot, index: index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _deleteSlot(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No break slots configured',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showBreakSlotDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add First Break Slot'),
          ),
        ],
      ),
    );
  }

  Color _getDayColor(int dayOfWeek) {
    const colors = [
      Colors.transparent,
      Color(0xFF4ADE80), // Monday - Green
      Color(0xFF60A5FA), // Tuesday - Blue
      Color(0xFFF59E0B), // Wednesday - Orange
      Color(0xFFEC4899), // Thursday - Pink
      Color(0xFF8B5CF6), // Friday - Purple
      Color(0xFF10B981), // Saturday - Teal
      Color(0xFFEF4444), // Sunday - Red
    ];
    return colors[dayOfWeek];
  }

  void _showBreakSlotDialog({BreakSlotModel? slot, int? index}) {
    showDialog(
      context: context,
      builder: (context) => BreakSlotFormDialog(
        slot: slot,
        index: index,
      ),
    );
  }

  void _toggleSlot(int index, bool isActive) async {
    try {
      await context.read<BreakSlotsProvider>().toggleBreakSlot(index, isActive);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Break slot ${isActive ? 'activated' : 'deactivated'}'),
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

  void _deleteSlot(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Break Slot'),
        content: const Text('Are you sure you want to delete this break slot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await context.read<BreakSlotsProvider>().deleteBreakSlot(index);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Break slot deleted successfully'),
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

  void _saveOrderCutoff() async {
    final minutes = int.tryParse(_cutoffController.text);
    if (minutes == null || minutes < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number (minimum 1 minute)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      await context
          .read<BreakSlotsProvider>()
          .updateOrderCutoffMinutes(minutes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order cutoff updated successfully'),
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
