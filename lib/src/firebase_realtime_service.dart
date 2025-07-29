import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class FirebaseRealtimeService {
  final FirebaseDatabase _database;

  FirebaseRealtimeService({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  // Create or update data
  Future<void> set(String path, Map<String, dynamic> data) async {
    final ref = _database.ref(path);
    await ref.set(data);
  }

  // Push new data (generates unique key)
  Future<String> push(String path, Map<String, dynamic> data) async {
    final ref = _database.ref(path);
    final newRef = ref.push();
    await newRef.set(data);
    return newRef.key!;
  }

  // Update specific fields
  Future<void> update(String path, Map<String, dynamic> updates) async {
    final ref = _database.ref(path);
    await ref.update(updates);
  }

  // Delete data
  Future<void> delete(String path) async {
    final ref = _database.ref(path);
    await ref.remove();
  }

  // Get data once
  Future<Map<String, dynamic>?> get(String path) async {
    final ref = _database.ref(path);
    final snapshot = await ref.get();

    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }

  // Listen to data changes
  Stream<Map<String, dynamic>?> listen(String path) {
    final ref = _database.ref(path);
    return ref.onValue.map((event) {
      if (event.snapshot.exists) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return null;
    });
  }

  // Listen to child events (added, changed, removed)
  Stream<DatabaseEvent> listenToChildren(String path) {
    final ref = _database.ref(path);
    return ref.onChildAdded;
  }

  // Query data with filters
  Future<List<Map<String, dynamic>>> query(
    String path, {
    String? orderByChild,
    String? orderByKey,
    String? orderByValue,
    dynamic equalTo,
    int? limitToFirst,
    int? limitToLast,
  }) async {
    Query query = _database.ref(path);

    if (orderByChild != null) {
      query = query.orderByChild(orderByChild);
    } else if (orderByKey != null) {
      query = query.orderByKey();
    } else if (orderByValue != null) {
      query = query.orderByValue();
    }

    if (equalTo != null) {
      query = query.equalTo(equalTo);
    }

    if (limitToFirst != null) {
      query = query.limitToFirst(limitToFirst);
    } else if (limitToLast != null) {
      query = query.limitToLast(limitToLast);
    }

    final snapshot = await query.get();
    final results = <Map<String, dynamic>>[];

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      for (final entry in data.entries) {
        results.add({
          'key': entry.key,
          ...Map<String, dynamic>.from(entry.value as Map),
        });
      }
    }

    return results;
  }

  // Transaction for atomic updates
  Future<void> runTransaction(
    String path,
    Map<String, dynamic> Function(Map<String, dynamic>? currentData)
    updateFunction,
  ) async {
    final ref = _database.ref(path);
    await ref.runTransaction((mutableData) {
      final currentData = mutableData != null
          ? Map<String, dynamic>.from(mutableData as Map)
          : null;

      final updatedData = updateFunction(currentData);
      return Transaction.success(updatedData);
    });
  }

  /// Batch operations
  Future<void> batch(Map<String, dynamic> updates) async {
    await _database.ref().update(updates);
  }

  /// Check connection status
  Stream<bool> get connectionState {
    return _database
        .ref('.info/connected')
        .onValue
        .map(
          (event) => event.snapshot.value as bool? ?? false,
        );
  }

  /// Go offline/online
  void goOffline() => _database.goOffline();

  /// Go online
  void goOnline() => _database.goOnline();
}
