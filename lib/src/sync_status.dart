/// Current sync status
class SyncStatus {
  final bool isOnline;
  final int pendingOperations;
  final bool syncInProgress;

  const SyncStatus({
    required this.isOnline,
    required this.pendingOperations,
    required this.syncInProgress,
  });
}
