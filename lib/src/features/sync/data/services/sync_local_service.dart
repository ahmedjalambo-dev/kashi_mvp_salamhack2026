import '../../../receive/data/services/pending_tx_local_service.dart';

class SyncLocalService {
  SyncLocalService([PendingTxLocalService? pending])
      : _pending = pending ?? PendingTxLocalService();
  final PendingTxLocalService _pending;

  Future<List<Map<String, Object?>>> pending() => _pending.queryPending();
  Future<void> markSyncing(String id) => _pending.markSyncing(id);
  Future<void> markSynced(String id) => _pending.markSynced(id);
  Future<void> markRejected(String id, String reason) =>
      _pending.markRejected(id, reason);
  Future<void> incrementRetry(String id) => _pending.incrementRetry(id);
}
