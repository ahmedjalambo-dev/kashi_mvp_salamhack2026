import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/connectivity_service.dart';
import 'network_state.dart';

class NetworkCubit extends Cubit<NetworkState> {
  NetworkCubit(this._connectivity) : super(const NetworkInitial()) {
    _bootstrap();
    _sub = _connectivity.onStatusChange.listen(_emitFromOnline);
  }

  final ConnectivityService _connectivity;
  StreamSubscription<bool>? _sub;

  bool get isOnline => state is NetworkOnline;

  Future<void> _bootstrap() async {
    final online = await _connectivity.isOnline();
    _emitFromOnline(online);
  }

  void _emitFromOnline(bool online) {
    final next = online ? const NetworkOnline() : const NetworkOffline();
    if (next != state) emit(next);
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
