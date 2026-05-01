import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/result.dart';
import '../data/repositories/receive_repository.dart';
import 'receive_state.dart';

class ReceiveCubit extends Cubit<ReceiveState> {
  ReceiveCubit({
    required ReceiveRepository repository,
    required this.myPublicKey,
  }) : _repository = repository,
       super(const ReceiveRequestInput());

  final ReceiveRepository _repository;
  final String myPublicKey;

  final amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> buildRequest() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    emit(const ReceiveBuildingRequest());
    final result = await _repository.buildRequest(
      amountController.text,
      myPublicKey,
    );
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(ReceiveShowingRequest(qrData: data.qrData, request: data.request));
      case Failure(:final error):
        emit(ReceiveFailure(error.message));
    }
  }

  Future<void> markFulfilled() async {
    final current = state;
    if (current is! ReceiveShowingRequest) return;
    // Best-effort local persistence; UI dismissal proceeds regardless.
    await _repository.markFulfilledLocally(current.request.id);
    if (isClosed) return;
    emit(const ReceiveDone());
  }

  /// Transitions to [ReceiveScanningConfirmation] so the UI opens the QR
  /// scanner aimed at the sender's confirmation QR.
  void openConfirmationScanner() {
    final current = state;
    if (current is! ReceiveShowingRequest) return;
    emit(ReceiveScanningConfirmation(current.request, current.qrData));
  }

  /// Called by [ScannerView.onDetect] when the receiver scans the sender's
  /// confirmation QR.
  Future<void> onConfirmationScanned(String qr) async {
    final current = state;
    if (current is! ReceiveScanningConfirmation) return;
    final request = current.request;
    final qrData = current.qrData;
    emit(ReceiveConfirmingPayment(request, qrData));

    final result = await _repository.confirmEnvelope(qr, request);
    if (isClosed) return;
    switch (result) {
      case Success():
        emit(const ReceiveDone());
      case Failure(:final error):
        // Return to the request view with an inline error so the user can
        // retry scanning without losing the request QR.
        emit(
          ReceiveShowingRequest(
            qrData: qrData,
            request: request,
            errorMessage: error.message,
          ),
        );
    }
  }

  void restart() {
    amountController.clear();
    emit(const ReceiveRequestInput());
  }

  @override
  Future<void> close() {
    amountController.dispose();
    return super.close();
  }
}
