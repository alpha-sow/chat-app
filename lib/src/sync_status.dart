/// Current sync status
class SyncStatus {

  const SyncStatus({
    required this.isOnline,
    required this.pendingOperations,
    required this.syncInProgress,
  });
  final bool isOnline;
  final int pendingOperations;
  final bool syncInProgress;
}
