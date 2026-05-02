import 'package:equatable/equatable.dart';

import '../../../features/wallet/data/models/wallet_profile.dart';

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

class SendConfirming extends SendState {
  final double amount;
  final String receiverPublicKey;
  final WalletProfile receiverProfile;
  const SendConfirming({
    required this.amount,
    required this.receiverPublicKey,
    required this.receiverProfile,
  });
  @override
  List<Object?> get props => [amount, receiverPublicKey, receiverProfile];
}

class SendReady extends SendState {
  final String qrData;
  final String transactionId;
  final double amount;
  final String receiverPublicKey;
  final WalletProfile receiverProfile;
  const SendReady({
    required this.qrData,
    required this.transactionId,
    required this.amount,
    required this.receiverPublicKey,
    required this.receiverProfile,
  });
  @override
  List<Object?> get props => [
    qrData,
    transactionId,
    amount,
    receiverPublicKey,
    receiverProfile,
  ];
}

class SendFailure extends SendState {
  final String message;
  const SendFailure(this.message);
  @override
  List<Object?> get props => [message];
}
