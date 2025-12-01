import 'package:flutter/material.dart';
import '../core/services/firebase_service.dart';
import '../models/menu_item_model.dart';

class MenuProvider extends ChangeNotifier {
  final List<MenuItemModel> _menuItems = [];
  bool _isLoading = false;
  String? _error;

  List<MenuItemModel> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Stream menu items for a specific canteen
  Stream<List<MenuItemModel>> streamMenuItems(String canteenId) {
    return FirebaseService.canteens
        .doc(canteenId)
        .collection('menu_items')
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((doc) => MenuItemModel.fromFirestore(doc))
          .toList();

      // Sort in memory instead of using Firestore index
      items.sort((a, b) {
        final categoryCompare = a.category.compareTo(b.category);
        if (categoryCompare != 0) return categoryCompare;
        return a.name.compareTo(b.name);
      });

      return items;
    });
  }

  /// Add a new menu item
  Future<void> addMenuItem(String canteenId, MenuItemModel item) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Adding menu item to canteen: $canteenId');
      debugPrint('Item data: ${item.toFirestore()}');

      await FirebaseService.canteens
          .doc(canteenId)
          .collection('menu_items')
          .add(item.toFirestore());

      debugPrint('Menu item added successfully');
    } catch (e) {
      _error = 'Failed to add menu item: $e';
      debugPrint('ERROR adding menu item: $_error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing menu item
  Future<void> updateMenuItem(
    String canteenId,
    String itemId,
    MenuItemModel item,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await FirebaseService.canteens
          .doc(canteenId)
          .collection('menu_items')
          .doc(itemId)
          .update(item.toFirestore());
    } catch (e) {
      _error = 'Failed to update menu item: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a menu item
  Future<void> deleteMenuItem(String canteenId, String itemId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await FirebaseService.canteens
          .doc(canteenId)
          .collection('menu_items')
          .doc(itemId)
          .delete();
    } catch (e) {
      _error = 'Failed to delete menu item: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle menu item availability
  Future<void> toggleItemAvailability(
    String canteenId,
    String itemId,
    bool isAvailable,
  ) async {
    try {
      await FirebaseService.canteens
          .doc(canteenId)
          .collection('menu_items')
          .doc(itemId)
          .update({'is_available': isAvailable});
    } catch (e) {
      _error = 'Failed to toggle availability: $e';
      debugPrint(_error);
      rethrow;
    }
  }

  /// Load max concurrent orders setting
  Future<int> getMaxConcurrentOrders(String canteenId) async {
    try {
      final doc = await FirebaseService.canteens.doc(canteenId).get();
      final data = doc.data() as Map<String, dynamic>?;
      return data?['max_concurrent_orders'] ?? 10;
    } catch (e) {
      debugPrint('Error loading max concurrent orders: $e');
      return 10;
    }
  }

  /// Update max concurrent orders setting
  Future<void> updateMaxConcurrentOrders(
    String canteenId,
    int maxOrders,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await FirebaseService.canteens.doc(canteenId).update({
        'max_concurrent_orders': maxOrders,
      });
    } catch (e) {
      _error = 'Failed to update max concurrent orders: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
