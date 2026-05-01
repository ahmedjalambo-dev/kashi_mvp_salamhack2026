import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/result.dart';
import '../data/repositories/send_repository.dart';
import 'send_state.dart';

class SendCubit extends Cubit<SendState> {
  SendCubit({required SendRepository repository, required this.senderPublicKey})
    : _repository = repository,
      super(const SendScanning());

  final SendRepository _repository;
  final String senderPublicKey;
  bool _busy = false;

  Future<void> onScan(String raw) async {
    if (_busy || state is! SendScanning) return;
    _busy = true;
    emit(const SendVerifying());
    final result = await _repository.validateScannedRequest(raw, senderPublicKey);
    if (isClosed) {
      _busy = false;
      return;
    }
    switch (result) {
      case Success(:final data):
        emit(SendConfirming(
          amount: data.amount,
          receiverPublicKey: data.receiverPublicKey,
          request: data,
        ));
      case Failure(:final error):
        emit(SendFailure(error.message));
    }
    _busy = false;
  }

  Future<void> confirmAndSign() async {
    final s = state;
    if (s is! SendConfirming) return;
    emit(const SendVerifying());
    final result = await _repository.signAndStore(s.request, senderPublicKey);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(SendSuccess(
          amount: s.amount,
          receiverPublicKey: s.receiverPublicKey,
          transactionId: data.transactionId,
          qrData: data.qrData,
        ));
      case Failure(:final error):
        emit(SendFailure(error.message));
    }
  }

  void cancelReview() {
    if (state is! SendConfirming) return;
    emit(const SendScanning());
  }

  void rescan() => emit(const SendScanning());
}
