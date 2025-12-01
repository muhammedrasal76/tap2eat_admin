import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/colors.dart';
import '../../providers/break_slots_provider.dart';
import '../../models/break_slot_model.dart';

class BreakSlotFormDialog extends StatefulWidget {
  final BreakSlotModel? slot;
  final int? index;

  const BreakSlotFormDialog({
    super.key,
    this.slot,
    this.index,
  });

  @override
  State<BreakSlotFormDialog> createState() => _BreakSlotFormDialogState();
}

class _BreakSlotFormDialogState extends State<BreakSlotFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();

  late int _selectedDayOfWeek;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isActive = true;
  bool _isLoading = false;

  bool get _isEditMode => widget.slot != null;

  @override
  void initState() {
    super.initState();

    if (_isEditMode && widget.slot != null) {
      _labelController.text = widget.slot!.label;
      _selectedDayOfWeek = widget.slot!.dayOfWeek;
      _isActive = widget.slot!.isActive;

      final startDate = widget.slot!.startTime.toDate();
      final endDate = widget.slot!.endTime.toDate();
      _startTime = TimeOfDay(hour: startDate.hour, minute: startDate.minute);
      _endTime = TimeOfDay(hour: endDate.hour, minute: endDate.minute);
    } else {
      _selectedDayOfWeek = 1; // Default to Monday
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildLabelField(),
              const SizedBox(height: 24),
              _buildDayOfWeekDropdown(),
              const SizedBox(height: 24),
              _buildTimeFields(),
              const SizedBox(height: 16),
              _buildDurationDisplay(),
              const SizedBox(height: 24),
              _buildActiveToggle(),
              const SizedBox(height: 32),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.schedule,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? 'Edit Break Slot' : 'Add Break Slot',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Configure time slot for student deliveries',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildLabelField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Label',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _labelController,
          decoration: const InputDecoration(
            hintText: 'e.g., Morning Break, Lunch Break',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.label),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDayOfWeekDropdown() {
    final days = [
      {'value': 1, 'name': 'Monday'},
      {'value': 2, 'name': 'Tuesday'},
      {'value': 3, 'name': 'Wednesday'},
      {'value': 4, 'name': 'Thursday'},
      {'value': 5, 'name': 'Friday'},
      {'value': 6, 'name': 'Saturday'},
      {'value': 7, 'name': 'Sunday'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Day of Week',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _selectedDayOfWeek,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.calendar_today),
          ),
          items: days.map((day) {
            return DropdownMenuItem<int>(
              value: day['value'] as int,
              child: Text(day['name'] as String),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedDayOfWeek = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildTimeFields() {
    return Row(
      children: [
        Expanded(
          child: _buildTimeField(
            label: 'Start Time',
            time: _startTime,
            onTap: () => _selectTime(isStart: true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTimeField(
            label: 'End Time',
            time: _endTime,
            onTap: () => _selectTime(isStart: false),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  time != null ? time.format(context) : 'Select time',
                  style: TextStyle(
                    color: time != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationDisplay() {
    if (_startTime == null || _endTime == null) {
      return const SizedBox.shrink();
    }

    final duration = _calculateDuration();
    if (duration == null || duration <= 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.error),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Text(
              'End time must be after start time',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            'Duration: $duration minutes',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveToggle() {
    return Row(
      children: [
        Text(
          'Active',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const Spacer(),
        Switch(
          value: _isActive,
          onChanged: (value) {
            setState(() {
              _isActive = value;
            });
          },
          activeColor: AppColors.success,
        ),
        Text(
          _isActive ? 'Enabled' : 'Disabled',
          style: TextStyle(
            color: _isActive ? AppColors.success : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveBreakSlot,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditMode ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Future<void> _selectTime({required bool isStart}) async {
    final initialTime = isStart
        ? (_startTime ?? TimeOfDay.now())
        : (_endTime ?? TimeOfDay.now());

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (time != null) {
      setState(() {
        if (isStart) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  int? _calculateDuration() {
    if (_startTime == null || _endTime == null) return null;

    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    return endMinutes - startMinutes;
  }

  Future<void> _saveBreakSlot() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startTime == null || _endTime == null) {
      _showError('Please select both start and end times');
      return;
    }

    final duration = _calculateDuration();
    if (duration == null || duration <= 0) {
      _showError('End time must be after start time');
      return;
    }

    // Create timestamps for today at the selected times
    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    final slot = BreakSlotModel(
      id: widget.slot?.id ?? '',
      label: _labelController.text.trim(),
      dayOfWeek: _selectedDayOfWeek,
      startTime: Timestamp.fromDate(startDateTime),
      endTime: Timestamp.fromDate(endDateTime),
      isActive: _isActive,
    );

    // Check for overlaps
    final provider = context.read<BreakSlotsProvider>();
    if (provider.hasOverlap(slot, excludeIndex: widget.index)) {
      _showError('This time slot overlaps with an existing slot on the same day');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isEditMode && widget.index != null) {
        await provider.updateBreakSlot(widget.index!, slot);
      } else {
        await provider.addBreakSlot(slot);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Break slot updated successfully'
                  : 'Break slot added successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
