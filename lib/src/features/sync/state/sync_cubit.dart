import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/result.dart';
import '../../../core/services/connectivity_service.dart';
import '../data/repositories/sync_repository.dart';
import 'sync_state.dart';

const _retryDelay = Duration(seconds: 30);

class SyncCubit extends Cubit<SyncState> {
  SyncCubit({
    required SyncRepository repository,
    required ConnectivityService connectivity,
  })  : _repository = repository,
        _connectivity = connectivity,
        super(const SyncIdle()) {
    _sub = _connectivity.onStatusChange.listen((online) {
      if (online) runOnce();
    });
  }

  final SyncRepository _repository;
  final ConnectivityService _connectivity;
  StreamSubscription<bool>? _sub;
  Timer? _retryTimer;
  bool _running = false;

  Future<void> runOnce() async {
    if (_running) return;
    _retryTimer?.cancel();
    _running = true;
    emit(const SyncRunning());
    final result = await _repository.drainPending();
    switch (result) {
      case Success(:final data):
        emit(SyncIdle(synced: data.synced, failed: data.failed));
      case Failure(:final error):
        emit(SyncFailure(error.message));
    }
    _running = false;

    // If rows still pending (retryable errors or socket abort), schedule a
    // retry so we don't wait for the next connectivity edge.
    final remaining = await _repository.pendingCount();
    if (remaining > 0) {
      _retryTimer = Timer(_retryDelay, runOnce);
    }
  }

  @override
  Future<void> close() async {
    _retryTimer?.cancel();
    await _sub?.cancel();
    return super.close();
  }
}
