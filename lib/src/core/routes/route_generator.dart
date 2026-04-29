import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/receive/data/repositories/receive_repository.dart';
import '../../features/receive/data/services/pending_tx_local_service.dart';
import '../../features/receive/state/receive_cubit.dart';
import '../../features/receive/ui/receive_screen.dart';
import '../../features/send/data/repositories/send_repository.dart';
import '../../features/send/state/send_cubit.dart';
import '../../features/send/ui/send_screen.dart';
import '../../features/wallet/data/repositories/wallet_repository.dart';
import '../../features/wallet/state/pending_tx_cubit.dart';
import '../../features/wallet/state/wallet_cubit.dart';
import '../../features/wallet/ui/pending_transactions_screen.dart';
import '../../features/wallet/ui/wallet_screen.dart';
import '../di/injector.dart';
import 'routes.dart';

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case Routes.wallet:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => WalletCubit(getIt<WalletRepository>()),
            child: const WalletScreen(),
          ),
        );
      case Routes.send:
        final senderPub = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => SendCubit(
              repository: getIt<SendRepository>(),
              senderPublicKey: senderPub,
            ),
            child: const SendScreen(),
          ),
        );
      case Routes.receive:
        final myPub = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => ReceiveCubit(
              repository: getIt<ReceiveRepository>(),
              myPublicKey: myPub,
            ),
            child: const ReceiveScreen(),
          ),
        );
      case Routes.pendingTx:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => PendingTxCubit(getIt<PendingTxLocalService>()),
            child: const PendingTransactionsScreen(),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
