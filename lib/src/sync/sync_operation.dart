import 'package:dayder_chat/src/src.dart';

/// Represents a sync operation to be executed
class SyncOperation {

  SyncOperation({
    required this.type,
    required this.operation,
    this.entityId,
    this.discussionId,
    this.data,
  }) : timestamp = DateTime.now();
  final SyncOperationType type;
  final String operation;
  final String? entityId;
  final String? discussionId;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
}
