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

  /// Non-null when the confirmation scan returned a verifiable error.
  final String? errorMessage;

  const ReceiveShowingRequest({
    required this.qrData,
    required this.request,
    this.errorMessage,
  });
  @override
  List<Object?> get props => [qrData, request, errorMessage];
}

class ReceiveScanningConfirmation extends ReceiveState {
  final PaymentRequest request;
  final String qrData;
  const ReceiveScanningConfirmation(this.request, this.qrData);
  @override
  List<Object?> get props => [request, qrData];
}

class ReceiveConfirmingPayment extends ReceiveState {
  final PaymentRequest request;
  final String qrData;
  const ReceiveConfirmingPayment(this.request, this.qrData);
  @override
  List<Object?> get props => [request, qrData];
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
