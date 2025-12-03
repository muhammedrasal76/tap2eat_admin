import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/audit_log_model.dart';

class AuditLogsProvider extends ChangeNotifier {
  List<AuditLogModel> _logs = [];
  List<AuditLogModel> _filteredLogs = [];
  bool _isLoading = false;
  String? _error;

  // Filters
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedUserId;
  String? _selectedAction;
  String _searchQuery = '';

  // Getters
  List<AuditLogModel> get logs => _filteredLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get selectedUserId => _selectedUserId;
  String? get selectedAction => _selectedAction;
  String get searchQuery => _searchQuery;

  // Load logs
  Future<void> loadLogs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Query query = FirebaseFirestore.instance
          .collection('audit_logs')
          .orderBy('timestamp', descending: true)
          .limit(500);

      // Apply date range filter
      if (_startDate != null) {
        query = query.where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!));
      }
      if (_endDate != null) {
        query = query.where('timestamp',
            isLessThanOrEqualTo: Timestamp.fromDate(_endDate!));
      }

      final snapshot = await query.get();
      _logs = snapshot.docs
          .map((doc) => AuditLogModel.fromFirestore(doc))
          .toList();

      _applyFilters();
    } catch (e) {
      _error = 'Failed to load audit logs: $e';
      _logs = [];
      _filteredLogs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply filters
  void _applyFilters() {
    _filteredLogs = _logs.where((log) {
      // User filter
      if (_selectedUserId != null && log.userId != _selectedUserId) {
        return false;
      }

      // Action filter
      if (_selectedAction != null && log.action != _selectedAction) {
        return false;
      }

      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!log.userName.toLowerCase().contains(query) &&
            !log.action.toLowerCase().contains(query) &&
            !log.id.toLowerCase().contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Update filters
  void updateDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    loadLogs();
  }

  void updateUserFilter(String? userId) {
    _selectedUserId = userId;
    _applyFilters();
    notifyListeners();
  }

  void updateActionFilter(String? action) {
    _selectedAction = action;
    _applyFilters();
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _startDate = null;
    _endDate = null;
    _selectedUserId = null;
    _selectedAction = null;
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Get unique action types
  List<String> getUniqueActions() {
    return _logs.map((log) => log.action).toSet().toList()..sort();
  }

  // Get unique user IDs
  Map<String, String> getUniqueUsers() {
    final users = <String, String>{};
    for (var log in _logs) {
      users[log.userId] = log.userName;
    }
    return users;
  }
}
