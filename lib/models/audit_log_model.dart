import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLogModel {
  final String id;
  final String userId;
  final String userName;
  final String userRole;
  final String action;
  final String? resourceType;
  final String? resourceId;
  final Map<String, dynamic>? metadata;
  final Timestamp timestamp;

  AuditLogModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.action,
    this.resourceType,
    this.resourceId,
    this.metadata,
    required this.timestamp,
  });

  factory AuditLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AuditLogModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      userName: data['user_name'] ?? 'Unknown',
      userRole: data['user_role'] ?? '',
      action: data['action'] ?? '',
      resourceType: data['resource_type'],
      resourceId: data['resource_id'],
      metadata: data['metadata'] as Map<String, dynamic>?,
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_role': userRole,
      'action': action,
      'resource_type': resourceType,
      'resource_id': resourceId,
      'metadata': metadata,
      'timestamp': timestamp,
    };
  }

  String getFormattedTimestamp() {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String getActionDescription() {
    switch (action) {
      case 'order.created':
        return 'Created Order';
      case 'order.updated':
        return 'Updated Order Status';
      case 'menu.created':
        return 'Added Menu Item';
      case 'menu.updated':
        return 'Updated Menu Item';
      case 'menu.deleted':
        return 'Deleted Menu Item';
      case 'canteen.updated':
        return 'Updated Canteen Settings';
      case 'break_slot.created':
        return 'Created Break Slot';
      case 'break_slot.updated':
        return 'Updated Break Slot';
      case 'break_slot.deleted':
        return 'Deleted Break Slot';
      case 'user.login':
        return 'User Login';
      case 'user.logout':
        return 'User Logout';
      default:
        return action;
    }
  }
}
