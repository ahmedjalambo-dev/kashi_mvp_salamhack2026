import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/result.dart';
import '../data/repositories/send_repository.dart';
import 'send_state.dart';

class SendCubit extends Cubit<SendState> {
  SendCubit({required SendRepository repository, required this.senderPublicKey})
    : _repository = repository,
      super(const SendInitial());

  final SendRepository _repository;
  final String senderPublicKey;

  final amountController = TextEditingController();
  final recipientController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> createPayment() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    final recipient = recipientController.text.trim();

    emit(const SendLoading());
    final result = await _repository.buildSignedQr(
      senderPublicKey: senderPublicKey,
      receiverPublicKey: recipient,
      amount: amount,
    );
    switch (result) {
      case Success(:final data):
        emit(
          SendReady(
            qrData: data.qrData,
            transactionId: data.transactionId,
            amount: amount,
            receiverPublicKey: recipient,
          ),
        );
      case Failure(:final error):
        emit(SendFailure(error.message));
    }
  }

  Future<void> cancelTransfer() async {
    final s = state;
    if (s is! SendReady) return;
    emit(const SendLoading());
    final result = await _repository.cancelPendingTransaction(
      s.transactionId,
      s.amount,
    );
    if (isClosed) return;
    switch (result) {
      case Success():
        amountController.clear();
        recipientController.clear();
        emit(const SendInitial());
      case Failure(:final error):
        emit(SendFailure(error.message));
    }
  }

  void reset() {
    amountController.clear();
    recipientController.clear();
    emit(const SendInitial());
  }

  @override
  Future<void> close() {
    amountController.dispose();
    recipientController.dispose();
    return super.close();
  }
}
