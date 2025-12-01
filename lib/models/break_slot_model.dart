import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BreakSlotModel {
  final String id;
  final Timestamp startTime;
  final Timestamp endTime;
  final int dayOfWeek; // 1=Monday, 7=Sunday
  final String label;
  final bool isActive;

  BreakSlotModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    required this.label,
    this.isActive = true,
  });

  // Factory from Map (for Firestore deserialization)
  factory BreakSlotModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return BreakSlotModel(
      id: id ?? map['id'] ?? '',
      startTime: map['start_time'] as Timestamp,
      endTime: map['end_time'] as Timestamp,
      dayOfWeek: map['day_of_week'] as int,
      label: map['label'] as String? ?? '',
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  // Factory from DocumentSnapshot
  factory BreakSlotModel.fromFirestore(Map<String, dynamic> data, int index) {
    return BreakSlotModel.fromMap(data, id: index.toString());
  }

  // Serialize to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'start_time': startTime,
      'end_time': endTime,
      'day_of_week': dayOfWeek,
      'label': label,
      'is_active': isActive,
    };
  }

  // Immutability helper
  BreakSlotModel copyWith({
    String? id,
    Timestamp? startTime,
    Timestamp? endTime,
    int? dayOfWeek,
    String? label,
    bool? isActive,
  }) {
    return BreakSlotModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      label: label ?? this.label,
      isActive: isActive ?? this.isActive,
    );
  }

  // Helper: Get duration in minutes
  int getDurationMinutes() {
    final start = startTime.toDate();
    final end = endTime.toDate();
    return end.difference(start).inMinutes;
  }

  // Helper: Get day name
  String getDayName() {
    const days = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[dayOfWeek];
  }

  // Helper: Format time range
  String getTimeRange() {
    final start = startTime.toDate();
    final end = endTime.toDate();
    final format = DateFormat('h:mm a');
    return '${format.format(start)} - ${format.format(end)}';
  }
}
