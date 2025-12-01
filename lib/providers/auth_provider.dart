import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? _userRole;
  String? _canteenId;
  bool _isLoading = false;

  bool get isAuthenticated => _user != null;
  String? get userRole => _userRole;
  String? get canteenId => _canteenId;
  bool get isLoading => _isLoading;
  User? get user => _user;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      await _loadUserRole();
    } else {
      _userRole = null;
      _canteenId = null;
    }
    notifyListeners();
  }

  Future<void> _loadUserRole() async {
    try {
      final doc = await FirebaseService.users.doc(_user!.uid).get();
      final data = doc.data() as Map<String, dynamic>?;
      _userRole = data?['role'];
      _canteenId = data?['canteen_id'];
    } catch (e) {
      debugPrint('Error loading user role: $e');
    }
  }

  Future<String?> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Authentication failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
