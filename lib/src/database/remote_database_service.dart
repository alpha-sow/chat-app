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
  Future<void> set(String path, Map<String, dynamic> data) async {
    final ref = _database.ref(path);
    await ref.set(data);
  }

  /// Pushes data to the specified [path] with an auto-generated key.
  ///
  /// Creates a new child with an automatically generated unique key
  /// and sets the provided [data]. Returns the generated key.
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
  Future<void> update(String path, Map<String, dynamic> updates) async {
    final ref = _database.ref(path);
    await ref.update(updates);
  }

  /// Deletes data at the specified [path].
  ///
  /// Removes all data at the specified path and its children.
  Future<void> delete(String path) async {
    final ref = _database.ref(path);
    await ref.remove();
  }

  /// Retrieves data from the specified [path].
  ///
  /// Returns the data as a [Map<String, dynamic>] if it exists,
  /// otherwise returns null.
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

}
