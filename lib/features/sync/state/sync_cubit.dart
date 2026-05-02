import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/result.dart';
import '../../../core/services/connectivity_service.dart';
import '../../wallet/data/repositories/wallet_repository.dart';
import '../data/repositories/sync_repository.dart';
import 'sync_state.dart';

const _retryDelay = Duration(seconds: 30);

class SyncCubit extends Cubit<SyncState> {
  SyncCubit({
    required SyncRepository repository,
    required ConnectivityService connectivity,
    required WalletRepository walletRepository,
  }) : _repository = repository,
       _connectivity = connectivity,
       _walletRepository = walletRepository,
       super(const SyncIdle()) {
    _resetStaleDuplicateRejections();
    _sub = _connectivity.onStatusChange.listen((online) {
      if (online) runOnce();
    });
  }

  final SyncRepository _repository;
  final ConnectivityService _connectivity;
  final WalletRepository _walletRepository;
  StreamSubscription<bool>? _sub;
  Timer? _retryTimer;
  bool _running = false;

  Future<void> runOnce() async {
    if (_running) return;
    _retryTimer?.cancel();
    _running = true;
    if (!isClosed) emit(const SyncRunning());
    try {
      final drainResult = await _repository.drainPending();
      if (isClosed) return;
      switch (drainResult) {
        case Success(:final data):
          var reconciled = 0;
          try {
            final (:publicKey, :profile) =
                await _walletRepository.ensureKeyPair();
            final reconcileResult = await _repository.pullAndReconcile(
              publicKey,
            );
            if (reconcileResult case Success(:final data)) {
              reconciled = data.reconciled;
            }
          } catch (_) {
            // Reconciliation is best-effort; a failure here must not prevent
            // the cubit from settling into SyncIdle.
          }
          if (!isClosed) {
            emit(
              SyncIdle(
                synced: data.synced,
                failed: data.failed,
                reconciled: reconciled,
              ),
            );
          }
        case Failure(:final error):
          emit(SyncFailure(error.message));
      }
    } finally {
      _running = false;
    }

    if (isClosed) return;
    // If rows still pending (retryable errors or socket abort), schedule a
    // retry so we don't wait for the next connectivity edge.
    final remaining = await _repository.pendingCount();
    if (remaining > 0 && !isClosed) {
      _retryTimer = Timer(_retryDelay, runOnce);
    }
  }

  Future<void> _resetStaleDuplicateRejections() async {
    try {
      await _repository.requeueDuplicateRejections();
    } catch (_) {
      // Startup cleanup — silently ignore if DB isn't ready yet.
    }
  }

  @override
  Future<void> close() async {
    _retryTimer?.cancel();
    await _sub?.cancel();
    return super.close();
  }
}
