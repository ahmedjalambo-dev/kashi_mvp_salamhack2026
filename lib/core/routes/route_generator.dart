import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/receive/state/receive_cubit.dart';
import '../../features/receive/ui/my_address_screen.dart';
import '../../features/receive/ui/receive_screen.dart';
import '../../features/send/state/send_cubit.dart';
import '../../features/send/ui/scan_recipient_screen.dart';
import '../../features/send/ui/send_screen.dart';
import '../../features/wallet/state/wallet_cubit.dart';
import '../../features/wallet/ui/wallet_screen.dart';
import '../di/injector.dart';
import '../../features/receive/data/repositories/receive_repository.dart';
import '../../features/send/data/repositories/send_repository.dart';
import '../../features/wallet/data/repositories/wallet_repository.dart';
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
        final args =
            settings.arguments as ({String senderPub, String receiverPub});
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => SendCubit(
              repository: getIt<SendRepository>(),
              senderPublicKey: args.senderPub,
              receiverPublicKey: args.receiverPub,
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
      case Routes.scanRecipient:
        final senderPub = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ScanRecipientScreen(senderPub: senderPub),
        );
      case Routes.myAddress:
        final myPub = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MyAddressScreen(publicKey: myPub),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
