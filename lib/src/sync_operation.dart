import 'package:chat_app_package/src/src.dart';

/// Represents a sync operation to be executed
class SyncOperation {
  final SyncOperationType type;
  final String operation;
  final String? entityId;
  final String? discussionId;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  SyncOperation({
    required this.type,
    required this.operation,
    this.entityId,
    this.discussionId,
    this.data,
  }) : timestamp = DateTime.now();
}
