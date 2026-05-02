import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/receive/state/receive_cubit.dart';
import '../../features/receive/ui/my_address_screen.dart';
import '../../features/receive/ui/receive_screen.dart';
import '../../features/send/state/send_cubit.dart';
import '../../features/send/ui/scan_recipient_screen.dart';
import '../../features/send/ui/send_screen.dart';
import '../../features/wallet/data/models/wallet_profile.dart';
import '../../features/wallet/state/wallet_cubit.dart';
import '../../features/wallet/ui/wallet_screen.dart';
import '../di/injector.dart';
import '../../features/receive/data/repositories/receive_repository.dart';
import '../../features/send/data/repositories/send_repository.dart';
import '../../features/wallet/data/repositories/wallet_repository.dart';
import 'routes.dart';

typedef SendArgs = ({
  String senderPub,
  String receiverPub,
  WalletProfile senderProfile,
  WalletProfile receiverProfile,
});

typedef ScanRecipientArgs = ({String senderPub, WalletProfile senderProfile});

typedef MyAddressArgs = ({String publicKey, WalletProfile profile});

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
        final args = settings.arguments as SendArgs;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => SendCubit(
              repository: getIt<SendRepository>(),
              senderPublicKey: args.senderPub,
              receiverPublicKey: args.receiverPub,
              senderProfile: args.senderProfile,
              receiverProfile: args.receiverProfile,
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
        final args = settings.arguments as ScanRecipientArgs;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ScanRecipientScreen(
            senderPub: args.senderPub,
            senderProfile: args.senderProfile,
          ),
        );
      case Routes.myAddress:
        final args = settings.arguments as MyAddressArgs;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MyAddressScreen(
            publicKey: args.publicKey,
            profile: args.profile,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
