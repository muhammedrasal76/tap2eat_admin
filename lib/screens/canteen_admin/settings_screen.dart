import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/routes.dart';
import '../../core/services/firebase_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/forms/form_section.dart';
import '../../widgets/inputs/custom_text_field.dart';
import '../../widgets/buttons/custom_button.dart';
import '../../widgets/layouts/page_header.dart';
import '../../widgets/feedback/loading_overlay.dart';

class CanteenSettingsScreen extends StatefulWidget {
  const CanteenSettingsScreen({super.key});

  @override
  State<CanteenSettingsScreen> createState() => _CanteenSettingsScreenState();
}

class _CanteenSettingsScreenState extends State<CanteenSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _maxOrdersController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();

  // Time controllers
  TimeOfDay _openTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 20, minute: 0);

  bool _isActive = true;
  bool _isLoading = false;
  bool _isSaving = false;

  Map<String, dynamic>? _originalSettings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _maxOrdersController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final canteenId = context.read<AuthProvider>().canteenId;
      if (canteenId == null) return;

      final doc = await FirebaseService.canteens.doc(canteenId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _originalSettings = Map<String, dynamic>.from(data);

        setState(() {
          _nameController.text = data['name'] ?? '';
          _maxOrdersController.text = (data['max_concurrent_orders'] ?? 10).toString();
          _isActive = data['is_active'] ?? true;

          // Contact info
          _contactPhoneController.text = data['contact_phone'] ?? '';
          _contactEmailController.text = data['contact_email'] ?? '';

          // Working hours (stored as strings like "08:00" and "20:00")
          if (data['opening_time'] != null) {
            final parts = (data['opening_time'] as String).split(':');
            _openTime = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }
          if (data['closing_time'] != null) {
            final parts = (data['closing_time'] as String).split(':');
            _closeTime = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load settings: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final canteenId = context.read<AuthProvider>().canteenId;
      if (canteenId == null) return;

      await FirebaseService.canteens.doc(canteenId).update({
        'name': _nameController.text.trim(),
        'max_concurrent_orders': int.parse(_maxOrdersController.text),
        'is_active': _isActive,
        'contact_phone': _contactPhoneController.text.trim(),
        'contact_email': _contactEmailController.text.trim(),
        'opening_time': '${_openTime.hour.toString().padLeft(2, '0')}:${_openTime.minute.toString().padLeft(2, '0')}',
        'closing_time': '${_closeTime.hour.toString().padLeft(2, '0')}:${_closeTime.minute.toString().padLeft(2, '0')}',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadSettings(); // Reload to update original settings
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _resetToDefaults() {
    if (_originalSettings != null) {
      setState(() {
        _nameController.text = _originalSettings!['name'] ?? '';
        _maxOrdersController.text = (_originalSettings!['max_concurrent_orders'] ?? 10).toString();
        _isActive = _originalSettings!['is_active'] ?? true;
        _contactPhoneController.text = _originalSettings!['contact_phone'] ?? '';
        _contactEmailController.text = _originalSettings!['contact_email'] ?? '';

        if (_originalSettings!['opening_time'] != null) {
          final parts = (_originalSettings!['opening_time'] as String).split(':');
          _openTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
        if (_originalSettings!['closing_time'] != null) {
          final parts = (_originalSettings!['closing_time'] as String).split(':');
          _closeTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings reset to saved values'),
          backgroundColor: AppColors.info,
        ),
      );
    }
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
            child: LoadingOverlay(
              isLoading: _isLoading,
              message: 'Loading settings...',
              child: Column(
                children: [
                  PageHeader(
                    title: 'Canteen Settings',
                    subtitle: 'Manage your canteen configuration',
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Basic Information Section
                            FormSection(
                              title: 'Basic Information',
                              description: 'Basic details about your canteen',
                              children: [
                                CustomTextField(
                                  label: 'Canteen Name',
                                  controller: _nameController,
                                  isRequired: true,
                                  hint: 'Enter canteen name',
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Canteen name is required';
                                    }
                                    return null;
                                  },
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Canteen Status',
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Switch(
                                                value: _isActive,
                                                onChanged: (value) {
                                                  setState(() => _isActive = value);
                                                },
                                                activeColor: AppColors.success,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                _isActive ? 'Active' : 'Inactive',
                                                style: TextStyle(
                                                  color: _isActive
                                                      ? AppColors.success
                                                      : AppColors.textSecondary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Operations Section
                            FormSection(
                              title: 'Operations',
                              description: 'Configure operational parameters',
                              children: [
                                CustomTextField(
                                  label: 'Max Concurrent Orders',
                                  controller: _maxOrdersController,
                                  isRequired: true,
                                  keyboardType: TextInputType.number,
                                  hint: '10',
                                  helperText: 'Maximum number of orders accepted per time slot',
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'This field is required';
                                    }
                                    final number = int.tryParse(value);
                                    if (number == null || number < 1) {
                                      return 'Must be a positive number';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Working Hours Section
                            FormSection(
                              title: 'Working Hours',
                              description: 'Set your canteen operating hours',
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTimePicker(
                                        'Opening Time',
                                        _openTime,
                                        (time) => setState(() => _openTime = time),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildTimePicker(
                                        'Closing Time',
                                        _closeTime,
                                        (time) => setState(() => _closeTime = time),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Contact Information Section
                            FormSection(
                              title: 'Contact Information',
                              description: 'Contact details for customer support',
                              children: [
                                CustomTextField(
                                  label: 'Phone Number',
                                  controller: _contactPhoneController,
                                  keyboardType: TextInputType.phone,
                                  hint: '+91 1234567890',
                                  prefixIcon: const Icon(Icons.phone, size: 20),
                                ),
                                CustomTextField(
                                  label: 'Email Address',
                                  controller: _contactEmailController,
                                  keyboardType: TextInputType.emailAddress,
                                  hint: 'canteen@example.com',
                                  prefixIcon: const Icon(Icons.email, size: 20),
                                  validator: (value) {
                                    if (value != null && value.trim().isNotEmpty) {
                                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                      if (!emailRegex.hasMatch(value)) {
                                        return 'Invalid email address';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Action Buttons
                            Row(
                              children: [
                                CustomButton(
                                  label: 'Save Changes',
                                  onPressed: _saveSettings,
                                  isLoading: _isSaving,
                                  icon: Icons.save,
                                  variant: ButtonVariant.primary,
                                ),
                                const SizedBox(width: 12),
                                CustomButton(
                                  label: 'Reset',
                                  onPressed: _resetToDefaults,
                                  icon: Icons.refresh,
                                  variant: ButtonVariant.secondary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(
    String label,
    TimeOfDay time,
    void Function(TimeOfDay) onTimeChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: time,
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
              onTimeChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  time.format(context),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
            route: Routes.canteenDashboard,
          ),
          _buildSidebarMenuItem(
            icon: Icons.restaurant_menu,
            label: 'Menu Management',
            route: Routes.canteenMenu,
          ),
          _buildSidebarMenuItem(
            icon: Icons.settings,
            label: 'Settings',
            isActive: true,
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
