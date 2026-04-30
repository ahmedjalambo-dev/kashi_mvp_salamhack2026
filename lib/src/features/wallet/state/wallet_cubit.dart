import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/result.dart';
import '../data/repositories/wallet_repository.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit(this._repository) : super(const WalletInitial()) {
    _cacheChangeSub = _repository.onCacheChange.listen((_) {
      _onCacheChanged();
    });
  }

  final WalletRepository _repository;
  StreamSubscription<void>? _cacheChangeSub;

  Future<void> initialize() async {
    emit(const WalletLoading());

    // Cache-first: surface the last-known balance immediately so the user
    // is never stuck on a loading screen (or shown $0) while offline.
    final publicKey = await _tryEnsureKeyPair();
    if (publicKey != null) {
      final cached = await _repository.loadCached(publicKey);
      if (cached != null) {
        final pendingOut = await _repository.pendingOutgoing(publicKey);
        emit(WalletReady(cached, pendingOut: pendingOut));
        // Fire remote refresh in the background without awaiting. If it
        // succeeds the UI will update; if it fails we keep the cached state.
        _silentRemoteRefresh(publicKey);
        return;
      }
    }

    // No cache yet (first ever launch) — must complete the remote round-trip.
    final result = await _repository.initializeWallet();
    switch (result) {
      case Success(:final data):
        final pendingOut = await _repository.pendingOutgoing(data.publicKey);
        emit(WalletReady(data, pendingOut: pendingOut));
      case Failure(:final error):
        // Truly first launch with no network and no cached key — we can't
        // do anything useful. Let the user retry once online.
        emit(WalletFailure(error.message));
    }
  }

  Future<void> refresh() async {
    final current = state;
    if (current is! WalletReady) return;
    final result = await _repository.refresh(current.wallet.publicKey);
    switch (result) {
      case Success(:final data):
        final pendingOut = await _repository.pendingOutgoing(data.publicKey);
        emit(WalletReady(data, pendingOut: pendingOut));
      case Failure():
        // Refresh failed (likely offline). Keep the existing WalletReady so
        // the user can keep interacting; OfflineBanner communicates the state.
        final pendingOut = await _repository.pendingOutgoing(
          current.wallet.publicKey,
        );
        emit(WalletReady(current.wallet, pendingOut: pendingOut));
    }
  }

  @override
  Future<void> close() async {
    await _cacheChangeSub?.cancel();
    return super.close();
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  Future<void> _onCacheChanged() async {
    final current = state;
    if (isClosed || current is! WalletReady) return;
    final cached = await _repository.loadCached(current.wallet.publicKey);
    if (isClosed || cached == null) return;
    final pendingOut = await _repository.pendingOutgoing(cached.publicKey);
    if (!isClosed) emit(WalletReady(cached, pendingOut: pendingOut));
  }

  Future<String?> _tryEnsureKeyPair() async {
    try {
      return await _repository.ensureKeyPair();
    } catch (_) {
      return null;
    }
  }

  Future<void> _silentRemoteRefresh(String publicKey) async {
    try {
      final result = await _repository.initializeWallet();
      if (isClosed) return;
      switch (result) {
        case Success(:final data):
          final pendingOut = await _repository.pendingOutgoing(data.publicKey);
          if (!isClosed) emit(WalletReady(data, pendingOut: pendingOut));
        case Failure():
          // Stay on cached state — already emitted above.
          break;
      }
    } catch (_) {
      // Swallow — the cached state is already displayed.
    }
  }
}
