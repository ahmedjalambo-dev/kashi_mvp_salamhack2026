import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/result.dart';
import '../data/repositories/receive_repository.dart';
import 'receive_state.dart';

class ReceiveCubit extends Cubit<ReceiveState> {
  ReceiveCubit({
    required ReceiveRepository repository,
    required this.myPublicKey,
  })  : _repository = repository,
        super(const ReceiveScanning());

  final ReceiveRepository _repository;
  final String myPublicKey;
  bool _busy = false;

  Future<void> onScan(String raw) async {
    if (_busy || state is ReceiveSuccess) return;
    _busy = true;
    emit(const ReceiveVerifying());
    final result = await _repository.handleScan(raw, myPublicKey);
    switch (result) {
      case Success(:final data):
        emit(ReceiveSuccess(data.payload));
      case Failure(:final error):
        emit(ReceiveFailure(error.message));
    }
    _busy = false;
  }

  void rescan() => emit(const ReceiveScanning());
}
