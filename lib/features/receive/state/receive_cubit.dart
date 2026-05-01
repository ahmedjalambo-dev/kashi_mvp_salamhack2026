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

  void markFulfilled() {
    if (state is! ReceiveShowingRequest) return;
    emit(const ReceiveDone());
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
