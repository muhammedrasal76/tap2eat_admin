import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/firebase_service.dart';
import '../models/break_slot_model.dart';

class BreakSlotsProvider extends ChangeNotifier {
  List<BreakSlotModel> _breakSlots = [];
  bool _isLoading = false;
  String? _error;
  int _orderCutoffMinutes = 5;

  List<BreakSlotModel> get breakSlots => _breakSlots;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get orderCutoffMinutes => _orderCutoffMinutes;

  /// Stream break slots for real-time updates
  Stream<List<BreakSlotModel>> streamBreakSlots() {
    return FirebaseService.settings.snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return [];
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final breakSlotsData = data['break_slots'] as List? ?? [];

      // Update order cutoff minutes
      _orderCutoffMinutes = data['order_cutoff_minutes'] as int? ?? 5;

      // Convert array to list of BreakSlotModel
      final slots = breakSlotsData.asMap().entries.map((entry) {
        final index = entry.key;
        final slotData = entry.value as Map<String, dynamic>;
        return BreakSlotModel.fromFirestore(slotData, index);
      }).toList();

      // Sort by day of week, then start time
      slots.sort((a, b) {
        final dayCompare = a.dayOfWeek.compareTo(b.dayOfWeek);
        if (dayCompare != 0) return dayCompare;
        return a.startTime.compareTo(b.startTime);
      });

      _breakSlots = slots;
      return slots;
    });
  }

  /// Add a new break slot
  Future<void> addBreakSlot(BreakSlotModel slot) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Adding break slot: ${slot.label}');

      // Get current slots
      final doc = await FirebaseService.settings.get();
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final currentSlots = (data['break_slots'] as List? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();

      // Add new slot
      currentSlots.add(slot.toFirestore());

      // Update Firestore
      await FirebaseService.settings.set({
        'break_slots': currentSlots,
        'order_cutoff_minutes': _orderCutoffMinutes,
      }, SetOptions(merge: true));

      debugPrint('Break slot added successfully');
    } catch (e) {
      _error = 'Failed to add break slot: $e';
      debugPrint('ERROR: $_error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing break slot
  Future<void> updateBreakSlot(int index, BreakSlotModel slot) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Updating break slot at index $index');

      // Get current slots
      final doc = await FirebaseService.settings.get();
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final currentSlots = (data['break_slots'] as List? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();

      // Update slot at index
      if (index >= 0 && index < currentSlots.length) {
        currentSlots[index] = slot.toFirestore();

        // Update Firestore
        await FirebaseService.settings.update({
          'break_slots': currentSlots,
        });

        debugPrint('Break slot updated successfully');
      } else {
        throw Exception('Invalid slot index: $index');
      }
    } catch (e) {
      _error = 'Failed to update break slot: $e';
      debugPrint('ERROR: $_error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a break slot
  Future<void> deleteBreakSlot(int index) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Deleting break slot at index $index');

      // Get current slots
      final doc = await FirebaseService.settings.get();
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final currentSlots = (data['break_slots'] as List? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();

      // Remove slot at index
      if (index >= 0 && index < currentSlots.length) {
        currentSlots.removeAt(index);

        // Update Firestore
        await FirebaseService.settings.update({
          'break_slots': currentSlots,
        });

        debugPrint('Break slot deleted successfully');
      } else {
        throw Exception('Invalid slot index: $index');
      }
    } catch (e) {
      _error = 'Failed to delete break slot: $e';
      debugPrint('ERROR: $_error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle break slot active status
  Future<void> toggleBreakSlot(int index, bool isActive) async {
    try {
      debugPrint('Toggling break slot at index $index to $isActive');

      // Get current slots
      final doc = await FirebaseService.settings.get();
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final currentSlots = (data['break_slots'] as List? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();

      // Update active status
      if (index >= 0 && index < currentSlots.length) {
        currentSlots[index]['is_active'] = isActive;

        // Update Firestore
        await FirebaseService.settings.update({
          'break_slots': currentSlots,
        });

        debugPrint('Break slot toggled successfully');
      }
    } catch (e) {
      _error = 'Failed to toggle break slot: $e';
      debugPrint('ERROR: $_error');
      rethrow;
    }
  }

  /// Update order cutoff minutes
  Future<void> updateOrderCutoffMinutes(int minutes) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Updating order cutoff to $minutes minutes');

      await FirebaseService.settings.set({
        'order_cutoff_minutes': minutes,
      }, SetOptions(merge: true));

      _orderCutoffMinutes = minutes;
      debugPrint('Order cutoff updated successfully');
    } catch (e) {
      _error = 'Failed to update order cutoff: $e';
      debugPrint('ERROR: $_error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Validate no overlapping slots on same day
  bool hasOverlap(BreakSlotModel newSlot, {int? excludeIndex}) {
    final slotsOnSameDay = _breakSlots
        .asMap()
        .entries
        .where((entry) =>
            entry.value.dayOfWeek == newSlot.dayOfWeek &&
            (excludeIndex == null || entry.key != excludeIndex))
        .map((e) => e.value)
        .toList();

    final newStart = newSlot.startTime.toDate();
    final newEnd = newSlot.endTime.toDate();

    return slotsOnSameDay.any((slot) {
      final existingStart = slot.startTime.toDate();
      final existingEnd = slot.endTime.toDate();

      // Check if time ranges overlap
      return !(newEnd.isBefore(existingStart) ||
          newEnd.isAtSameMomentAs(existingStart) ||
          newStart.isAfter(existingEnd) ||
          newStart.isAtSameMomentAs(existingEnd));
    });
  }
}
