import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/receive/data/services/pending_tx_local_service.dart';
import '../data/models/pending_tx_display.dart';
import 'pending_tx_state.dart';

class PendingTxCubit extends Cubit<PendingTxState> {
  PendingTxCubit(this._pendingTx) : super(const PendingTxLoading());

  final PendingTxLocalService _pendingTx;

  Future<void> load() async {
    try {
      emit(const PendingTxLoading());
      final rows = await _pendingTx.queryAllNonSynced();
      final txs = rows.map(PendingTxDisplay.fromRow).toList();
      emit(PendingTxLoaded(txs));
    } catch (e) {
      emit(PendingTxFailure(e.toString()));
    }
  }
}
