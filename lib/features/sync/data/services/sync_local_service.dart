import '../../../receive/data/services/incoming_pending_local_service.dart';
import '../../../receive/data/services/pending_tx_local_service.dart';

class SyncLocalService {
  SyncLocalService([
    PendingTxLocalService? pending,
    IncomingPendingLocalService? incoming,
  ]) : _pending = pending ?? PendingTxLocalService(),
       _incoming = incoming ?? IncomingPendingLocalService();

  final PendingTxLocalService _pending;
  final IncomingPendingLocalService _incoming;

  // ── Outgoing (sender-originated) ────────────────────────────────────────
  Future<List<Map<String, Object?>>> pending() => _pending.queryPending();
  Future<void> markSynced(String id) => _pending.markSynced(id);
  Future<void> markRejected(String id, String reason) =>
      _pending.markRejected(id, reason);
  Future<int> pendingCount() => _pending.pendingCount();
  Future<void> requeueDuplicateRejections() =>
      _pending.requeueDuplicateRejections();

  Future<List<Map<String, Object?>>> queryByStatus(String status) =>
      _pending.queryByStatus(status);

  Future<void> markSyncedFromVoided(String id) =>
      _pending.markSyncedFromVoided(id);

  // ── Incoming (receiver-originated, after confirmation QR scan) ───────────
  Future<List<Map<String, Object?>>> pendingIncoming() =>
      _incoming.queryPending();
  Future<void> markIncomingSynced(String id) => _incoming.markSynced(id);
  Future<void> markIncomingRejected(String id, String reason) =>
      _incoming.markRejected(id, reason);
}
