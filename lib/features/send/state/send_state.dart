import 'package:equatable/equatable.dart';

import '../data/models/payment_payload.dart';

sealed class SendState extends Equatable {
  const SendState();
  @override
  List<Object?> get props => [];
}

class SendScanning extends SendState {
  const SendScanning();
}

class SendVerifying extends SendState {
  const SendVerifying();
}

class SendConfirming extends SendState {
  final double amount;
  final String receiverPublicKey;
  final PaymentRequest request;
  const SendConfirming({
    required this.amount,
    required this.receiverPublicKey,
    required this.request,
  });
  @override
  List<Object?> get props => [amount, receiverPublicKey, request];
}

class SendSuccess extends SendState {
  final double amount;
  final String receiverPublicKey;
  final String transactionId;
  const SendSuccess({
    required this.amount,
    required this.receiverPublicKey,
    required this.transactionId,
  });
  @override
  List<Object?> get props => [amount, receiverPublicKey, transactionId];
}

class SendFailure extends SendState {
  final String message;
  const SendFailure(this.message);
  @override
  List<Object?> get props => [message];
}
