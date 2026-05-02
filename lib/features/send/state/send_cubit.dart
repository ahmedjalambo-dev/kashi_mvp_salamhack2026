import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/result.dart';
import '../../../features/wallet/data/models/wallet_profile.dart';
import '../data/repositories/send_repository.dart';
import 'send_state.dart';

class SendCubit extends Cubit<SendState> {
  SendCubit({
    required SendRepository repository,
    required this.senderPublicKey,
    required this.receiverPublicKey,
    required this.senderProfile,
    required this.receiverProfile,
  }) : _repository = repository,
       super(const SendInitial());

  final SendRepository _repository;
  final String senderPublicKey;
  final String receiverPublicKey;
  final WalletProfile senderProfile;
  final WalletProfile receiverProfile;

  final amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> reviewTransfer(double amount) async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    emit(const SendLoading());
    final result = await _repository.validateAmount(
      senderPublicKey: senderPublicKey,
      amount: amount,
    );
    if (isClosed) return;
    switch (result) {
      case Success():
        emit(SendConfirming(
          amount: amount,
          receiverPublicKey: receiverPublicKey,
          receiverProfile: receiverProfile,
        ));
      case Failure(:final error):
        emit(SendFailure(error.message));
    }
  }

  Future<void> confirmAndGenerateQR() async {
    final s = state;
    if (s is! SendConfirming) return;
    emit(const SendLoading());
    final result = await _repository.buildSignedQr(
      senderPublicKey: senderPublicKey,
      receiverPublicKey: s.receiverPublicKey,
      amount: s.amount,
      senderProfile: senderProfile,
      receiverProfile: receiverProfile,
    );
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(SendReady(
          qrData: data.qrData,
          transactionId: data.transactionId,
          amount: s.amount,
          receiverPublicKey: s.receiverPublicKey,
          receiverProfile: receiverProfile,
        ));
      case Failure(:final error):
        emit(SendFailure(error.message));
    }
  }

  void cancelReview() {
    if (state is! SendConfirming) return;
    emit(const SendInitial());
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
        emit(const SendInitial());
      case Failure(:final error):
        emit(SendFailure(error.message));
    }
  }

  void reset() {
    amountController.clear();
    emit(const SendInitial());
  }

  @override
  Future<void> close() {
    amountController.dispose();
    return super.close();
  }
}
