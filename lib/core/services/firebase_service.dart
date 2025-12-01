import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Firestore references
  static CollectionReference get users =>
      _firestore.collection('users');

  static CollectionReference get orders =>
      _firestore.collection('orders');

  static CollectionReference get canteens =>
      _firestore.collection('canteens');

  static DocumentReference get settings =>
      _firestore.collection('settings').doc('global');

  static CollectionReference get auditLogs =>
      _firestore.collection('audit_logs');

  static CollectionReference get earnings =>
      _firestore.collection('earnings');

  // Cloud Functions wrapper
  static Future<dynamic> callFunction(
    String name, [
    Map<String, dynamic>? data,
  ]) async {
    try {
      final result = await _functions.httpsCallable(name).call(data);
      return result.data;
    } catch (e) {
      throw Exception('Cloud Function error: $e');
    }
  }
}
