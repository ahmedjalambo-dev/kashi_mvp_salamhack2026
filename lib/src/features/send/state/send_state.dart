import 'package:equatable/equatable.dart';

sealed class SendState extends Equatable {
  const SendState();
  @override
  List<Object?> get props => [];
}

class SendInitial extends SendState {
  const SendInitial();
}

class SendLoading extends SendState {
  const SendLoading();
}

class SendReady extends SendState {
  final String qrData;
  final String transactionId;
  final double amount;
  final String receiverPublicKey;
  const SendReady({
    required this.qrData,
    required this.transactionId,
    required this.amount,
    required this.receiverPublicKey,
  });
  @override
  List<Object?> get props => [qrData, transactionId, amount, receiverPublicKey];
}

class SendFailure extends SendState {
  final String message;
  const SendFailure(this.message);
  @override
  List<Object?> get props => [message];
}
