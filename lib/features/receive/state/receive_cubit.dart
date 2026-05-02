import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/result.dart';
import '../../send/data/models/payment_payload.dart';
import '../data/repositories/receive_repository.dart';
import 'receive_state.dart';

class ReceiveCubit extends Cubit<ReceiveState> {
  ReceiveCubit({
    required ReceiveRepository repository,
    required this.myPublicKey,
  }) : _repository = repository,
       super(const ReceiveScanning());

  final ReceiveRepository _repository;
  final String myPublicKey;
  bool _busy = false;

  Future<void> onScan(String raw) async {
    if (_busy || state is! ReceiveScanning) return;
    _busy = true;
    emit(const ReceiveVerifying());
    final result = await _repository.validateScan(raw, myPublicKey);
    switch (result) {
      case Success(:final data):
        emit(ReceiveConfirming(data));
      case Failure(:final error):
        emit(ReceiveFailure(error.message));
    }
    _busy = false;
  }

  Future<void> confirmTransaction(PaymentPayload payload) async {
    final s = state;
    if (s is! ReceiveConfirming) return;
    assert(s.payload == payload);
    emit(const ReceiveVerifying());
    final result = await _repository.acceptValidated(s.envelope);
    switch (result) {
      case Success(:final data):
        emit(ReceiveSuccess(data.payload));
      case Failure(:final error):
        emit(ReceiveFailure(error.message));
    }
  }

  void cancelTransaction() => emit(const ReceiveScanning());

  void rescan() => emit(const ReceiveScanning());
}
