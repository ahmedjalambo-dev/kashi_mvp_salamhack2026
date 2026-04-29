import 'dart:async';

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

  Future<void> runOnce() async {
    if (_running) return;
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
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
