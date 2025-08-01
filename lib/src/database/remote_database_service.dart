import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

/// A service class that provides Firebase Realtime Database operations.
/// 
/// This service wraps Firebase Realtime Database functionality and provides
/// a clean interface for common database operations including CRUD operations,
/// real-time listening, querying, transactions, and connection management.
class RemoteDatabaseService {
  /// Creates a new [RemoteDatabaseService] instance.
  /// 
  /// Optionally accepts a [FirebaseDatabase] instance for dependency injection,
  /// otherwise uses the default Firebase Database instance.
  RemoteDatabaseService({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;
  final FirebaseDatabase _database;

  /// Sets data at the specified [path].
  /// 
  /// Overwrites any existing data at the path with the provided [data].
  /// Throws a [FirebaseException] if the operation fails.
  Future<void> set(String path, Map<String, dynamic> data) async {
    final ref = _database.ref(path);
    await ref.set(data);
  }

  /// Pushes data to the specified [path] with an auto-generated key.
  /// 
  /// Creates a new child with an automatically generated unique key
  /// and sets the provided [data]. Returns the generated key.
  /// Throws a [FirebaseException] if the operation fails.
  Future<String> push(String path, Map<String, dynamic> data) async {
    final ref = _database.ref(path);
    final newRef = ref.push();
    await newRef.set(data);
    return newRef.key!;
  }

  /// Updates specific fields at the specified [path].
  /// 
  /// Performs a partial update, only modifying the fields specified in [updates].
  /// Existing fields not included in [updates] remain unchanged.
  /// Throws a [FirebaseException] if the operation fails.
  Future<void> update(String path, Map<String, dynamic> updates) async {
    final ref = _database.ref(path);
    await ref.update(updates);
  }

  /// Deletes data at the specified [path].
  /// 
  /// Removes all data at the specified path and its children.
  /// Throws a [FirebaseException] if the operation fails.
  Future<void> delete(String path) async {
    final ref = _database.ref(path);
    await ref.remove();
  }

  /// Retrieves data from the specified [path].
  /// 
  /// Returns the data as a [Map<String, dynamic>] if it exists,
  /// otherwise returns null.
  /// Throws a [FirebaseException] if the operation fails.
  Future<Map<String, dynamic>?> get(String path) async {
    final ref = _database.ref(path);
    final snapshot = await ref.get();

    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value! as Map);
    }
    return null;
  }

  /// Creates a real-time listener for data changes at the specified [path].
  /// 
  /// Returns a [Stream] that emits the current data whenever it changes.
  /// Emits null if the data doesn't exist or is deleted.
  Stream<Map<String, dynamic>?> listen(String path) {
    final ref = _database.ref(path);
    return ref.onValue.map((event) {
      if (event.snapshot.exists) {
        return Map<String, dynamic>.from(event.snapshot.value! as Map);
      }
      return null;
    });
  }

  /// Creates a listener for child addition events at the specified [path].
  /// 
  /// Returns a [Stream] of [DatabaseEvent] objects that are emitted
  /// whenever a new child is added to the specified location.
  Stream<DatabaseEvent> listenToChildren(String path) {
    final ref = _database.ref(path);
    return ref.onChildAdded;
  }

  /// Performs a query on the data at the specified [path].
  /// 
  /// Supports various query parameters:
  /// - [orderByChild]: Order results by a child key
  /// - [orderByKey]: Order results by keys
  /// - [orderByValue]: Order results by values
  /// - [equalTo]: Filter results equal to a specific value
  /// - [limitToFirst]: Limit to the first N results
  /// - [limitToLast]: Limit to the last N results
  /// 
  /// Returns a list of maps where each map contains the data along with its key.
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
      final data = snapshot.value! as Map<dynamic, dynamic>;
      for (final entry in data.entries) {
        results.add({
          'key': entry.key,
          ...Map<String, dynamic>.from(entry.value as Map),
        });
      }
    }

    return results;
  }

  /// Executes a transaction at the specified [path].
  /// 
  /// Transactions ensure atomic updates to data that might be modified
  /// concurrently. The [updateFunction] receives the current data and
  /// should return the updated data.
  /// 
  /// The transaction will automatically retry if the data changes during
  /// the update operation.
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

  /// Performs a batch update with multiple path-value pairs.
  /// 
  /// Updates multiple paths atomically. The [updates] map should contain
  /// path-value pairs where keys are database paths and values are the
  /// data to set at those paths.
  Future<void> batch(Map<String, dynamic> updates) async {
    await _database.ref().update(updates);
  }

  /// Returns a stream indicating the connection state to Firebase.
  /// 
  /// Emits true when connected to Firebase, false when disconnected.
  /// Useful for showing connection status in the UI.
  Stream<bool> get connectionState {
    return _database
        .ref('.info/connected')
        .onValue
        .map(
          (event) => event.snapshot.value as bool? ?? false,
        );
  }

  /// Forces the Firebase client to go offline.
  /// 
  /// While offline, read and write operations will be served from the local
  /// cache if available. Operations performed while offline will be queued
  /// and executed when the client comes back online.
  void goOffline() => _database.goOffline();

  /// Forces the Firebase client to go online.
  /// 
  /// Reconnects to Firebase and synchronizes any pending operations
  /// that were queued while offline.  
  void goOnline() => _database.goOnline();
}