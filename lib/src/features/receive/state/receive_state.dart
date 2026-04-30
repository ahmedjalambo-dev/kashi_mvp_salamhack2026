import 'package:equatable/equatable.dart';

import '../../send/data/models/payment_payload.dart';

sealed class ReceiveState extends Equatable {
  const ReceiveState();
  @override
  List<Object?> get props => [];
}

class ReceiveScanning extends ReceiveState {
  const ReceiveScanning();
}

class ReceiveVerifying extends ReceiveState {
  const ReceiveVerifying();
}

class ReceiveConfirming extends ReceiveState {
  final SignedEnvelope envelope;
  const ReceiveConfirming(this.envelope);
  PaymentPayload get payload => envelope.payload;
  @override
  List<Object?> get props => [envelope];
}

class ReceiveSuccess extends ReceiveState {
  final PaymentPayload payload;
  const ReceiveSuccess(this.payload);
  @override
  List<Object?> get props => [payload];
}

class ReceiveFailure extends ReceiveState {
  final String message;
  const ReceiveFailure(this.message);
  @override
  List<Object?> get props => [message];
}
