import '../../../../core/network/error_handler.dart';
import '../../../../core/network/result.dart';
import '../models/transaction_model.dart';
import '../services/history_local_service.dart';
import '../services/history_remote_service.dart';

class HistorySnapshot {
  final List<TransactionModel> pending;
  final List<TransactionModel> completed;
  const HistorySnapshot({required this.pending, required this.completed});

  bool get isEmpty => pending.isEmpty && completed.isEmpty;
}

class HistoryRepository {
  HistoryRepository({
    required HistoryLocalService local,
    required HistoryRemoteService remote,
    required ErrorHandler errors,
  }) : _local = local,
       _remote = remote,
       _errors = errors;

  final HistoryLocalService _local;
  final HistoryRemoteService _remote;
  final ErrorHandler _errors;

  Stream<void> get onPendingChange => _local.onPendingChange;

  /// Reads the local cache (pending + previously-synced transactions).
  /// Always succeeds; returns empty lists if nothing is cached yet.
  Future<HistorySnapshot> loadLocal(String publicKey) async {
    final pending = await _local.pendingFor(publicKey);
    final completed = await _local.cachedFor(publicKey);
    return HistorySnapshot(pending: pending, completed: completed);
  }

  /// Fetches the latest confirmed transactions from Supabase, writes them
  /// into the cache, and returns a fresh snapshot.
  Future<Result<HistorySnapshot>> refreshRemote(String publicKey) async {
    try {
      final remote = await _remote.fetchFor(publicKey);
      await _local.upsertAll(remote);
      final pending = await _local.pendingFor(publicKey);
      final completed = await _local.cachedFor(publicKey);
      return Success(HistorySnapshot(pending: pending, completed: completed));
    } catch (e) {
      return Failure(_errors.map(e));
    }
  }
}
