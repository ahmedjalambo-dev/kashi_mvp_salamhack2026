import 'package:equatable/equatable.dart';

import '../../send/data/models/payment_payload.dart';

sealed class ReceiveState extends Equatable {
  const ReceiveState();
  @override
  List<Object?> get props => [];
}

class ReceiveRequestInput extends ReceiveState {
  const ReceiveRequestInput();
}

class ReceiveBuildingRequest extends ReceiveState {
  const ReceiveBuildingRequest();
}

class ReceiveShowingRequest extends ReceiveState {
  final String qrData;
  final PaymentRequest request;
  const ReceiveShowingRequest({required this.qrData, required this.request});
  @override
  List<Object?> get props => [qrData, request];
}

class ReceiveDone extends ReceiveState {
  const ReceiveDone();
}

class ReceiveFailure extends ReceiveState {
  final String message;
  const ReceiveFailure(this.message);
  @override
  List<Object?> get props => [message];
}
