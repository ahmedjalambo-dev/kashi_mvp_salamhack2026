import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/result.dart';
import '../data/repositories/history_repository.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({required HistoryRepository repository, required this.publicKey})
    : _repository = repository,
      super(const HistoryInitial()) {
    // React to pending-table changes (new received QR scan, sync flipped a
    // row to synced/rejected) so the UI updates without manual triggers.
    _pendingSub = _repository.onPendingChange.listen((_) => _reloadLocal());
  }

  final HistoryRepository _repository;
  final String publicKey;
  StreamSubscription<void>? _pendingSub;

  /// Initial bootstrap: render local cache immediately, then attempt a
  /// remote refresh. Local-first means the screen is never blocked on
  /// network, which is the offline-mode contract.
  Future<void> load() async {
    if (state is HistoryInitial) emit(const HistoryLoading());
    final snapshot = await _repository.loadLocal(publicKey);
    emit(
      HistoryReady(pending: snapshot.pending, completed: snapshot.completed),
    );
    await refresh();
  }

  /// Pull-to-refresh / route-resurface entry point. Reloads local first
  /// (cheap, always works) then tries remote.
  Future<void> refresh() async {
    final current = state;
    if (current is HistoryReady) {
      emit(current.copyWith(refreshing: true, clearRemoteError: true));
    }
    final result = await _repository.refreshRemote(publicKey);
    switch (result) {
      case Success(:final data):
        emit(HistoryReady(pending: data.pending, completed: data.completed));
      case Failure(:final error):
        // Remote failed — keep showing local data, surface a soft error.
        final snapshot = await _repository.loadLocal(publicKey);
        emit(
          HistoryReady(
            pending: snapshot.pending,
            completed: snapshot.completed,
            remoteError: error.message,
          ),
        );
    }
  }

  Future<void> _reloadLocal() async {
    final snapshot = await _repository.loadLocal(publicKey);
    final current = state;
    if (current is HistoryReady) {
      emit(
        current.copyWith(
          pending: snapshot.pending,
          completed: snapshot.completed,
        ),
      );
    } else {
      emit(
        HistoryReady(pending: snapshot.pending, completed: snapshot.completed),
      );
    }
  }

  @override
  Future<void> close() async {
    await _pendingSub?.cancel();
    return super.close();
  }
}
