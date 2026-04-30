import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../crypto/ecdsa_signer.dart';
import '../crypto/payload_codec.dart';
import '../network/error_handler.dart';
import '../network/network_cubit.dart';
import '../services/connectivity_service.dart';
import '../services/secure_storage.dart';
import '../../features/history/data/repositories/history_repository.dart';
import '../../features/history/data/services/history_local_service.dart';
import '../../features/history/data/services/history_remote_service.dart';
import '../../features/receive/data/repositories/receive_repository.dart';
import '../../features/receive/data/services/pending_tx_local_service.dart';
import '../../features/receive/data/services/scanner_service.dart';
import '../../features/send/data/repositories/send_repository.dart';
import '../../features/send/data/services/payment_signer.dart';
import '../../features/sync/data/repositories/sync_repository.dart';
import '../../features/sync/data/services/sync_local_service.dart';
import '../../features/sync/data/services/sync_remote_service.dart';
import '../../features/sync/state/sync_cubit.dart';
import '../../features/wallet/data/repositories/wallet_repository.dart';
import '../../features/wallet/data/services/wallet_remote_service.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // Supabase client
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Core
  getIt.registerLazySingleton(() => const ErrorHandler());
  getIt.registerLazySingleton(() => SecureStorage());
  getIt.registerLazySingleton(() => ConnectivityService());
  getIt.registerLazySingleton(() => EcdsaSigner());
  getIt.registerLazySingleton(() => const PayloadCodec());
  getIt.registerLazySingleton(() => const Uuid());

  // Wallet
  getIt.registerLazySingleton(
    () => WalletRemoteService(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton(
    () => WalletRepository(
      remote: getIt<WalletRemoteService>(),
      secureStorage: getIt<SecureStorage>(),
      signer: getIt<EcdsaSigner>(),
      errors: getIt<ErrorHandler>(),
      pendingTx: getIt<PendingTxLocalService>(),
    ),
  );

  // Send
  getIt.registerLazySingleton(
    () => PaymentSigner(
      signer: getIt<EcdsaSigner>(),
      codec: getIt<PayloadCodec>(),
    ),
  );
  getIt.registerLazySingleton(
    () => SendRepository(
      paymentSigner: getIt<PaymentSigner>(),
      secureStorage: getIt<SecureStorage>(),
      uuid: getIt<Uuid>(),
      errors: getIt<ErrorHandler>(),
    ),
  );

  // Receive
  getIt.registerLazySingleton(() => const ScannerService());
  getIt.registerLazySingleton(() => PendingTxLocalService());
  getIt.registerLazySingleton(
    () => ReceiveRepository(
      scanner: getIt<ScannerService>(),
      pendingTx: getIt<PendingTxLocalService>(),
      signer: getIt<EcdsaSigner>(),
      codec: getIt<PayloadCodec>(),
      errors: getIt<ErrorHandler>(),
    ),
  );

  // Sync
  getIt.registerLazySingleton(() => SyncRemoteService(getIt<SupabaseClient>()));
  getIt.registerLazySingleton(() => SyncLocalService());
  getIt.registerLazySingleton(
    () => SyncRepository(
      remote: getIt<SyncRemoteService>(),
      local: getIt<SyncLocalService>(),
      errors: getIt<ErrorHandler>(),
    ),
  );
  getIt.registerLazySingleton(
    () => SyncCubit(
      repository: getIt<SyncRepository>(),
      connectivity: getIt<ConnectivityService>(),
    ),
  );

  // Network status (offline banner + offline-aware features)
  getIt.registerLazySingleton(() => NetworkCubit(getIt<ConnectivityService>()));

  // History (sent + received transactions, local-first)
  getIt.registerLazySingleton(
    () => HistoryRemoteService(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton(
    () => HistoryLocalService(pending: getIt<PendingTxLocalService>()),
  );
  getIt.registerLazySingleton(
    () => HistoryRepository(
      local: getIt<HistoryLocalService>(),
      remote: getIt<HistoryRemoteService>(),
      errors: getIt<ErrorHandler>(),
    ),
  );
}
