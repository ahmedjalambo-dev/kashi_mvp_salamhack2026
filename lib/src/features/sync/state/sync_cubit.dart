import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/result.dart';
import '../../../core/services/connectivity_service.dart';
import '../data/repositories/sync_repository.dart';
import 'sync_state.dart';

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
  bool _running = false;

  /// Consecutive failure count — used for exponential backoff.
  int _failCount = 0;
  Timer? _backoffTimer;

  Future<void> runOnce() async {
    if (_running) return;
    _running = true;
    emit(const SyncRunning());
    final result = await _repository.drainPending();
    switch (result) {
      case Success(:final data):
        _failCount = 0;
        _backoffTimer?.cancel();
        emit(SyncIdle(synced: data.synced, failed: data.failed));
      case Failure(:final error):
        _failCount++;
        _scheduleRetry();
        emit(SyncFailure(error.message));
    }
    _running = false;
  }

  /// Schedules a retry with exponential backoff:
  /// delay = min(2^failCount * 2, 60) seconds.
  void _scheduleRetry() {
    _backoffTimer?.cancel();
    final delaySec = min(pow(2, _failCount).toInt() * 2, 60);
    _backoffTimer = Timer(Duration(seconds: delaySec), () {
      runOnce();
    });
  }

  @override
  Future<void> close() async {
    _backoffTimer?.cancel();
    await _sub?.cancel();
    return super.close();
  }
}
