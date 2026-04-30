import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/components/offline_banner.dart';
import 'core/di/injector.dart';
import 'core/network/network_cubit.dart';
import 'core/routes/route_generator.dart';
import 'core/routes/route_observer.dart';
import 'core/routes/routes.dart';
import 'core/theme/app_theme.dart';
import 'features/sync/state/sync_cubit.dart';

class KashiApp extends StatelessWidget {
  const KashiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SyncCubit>.value(value: getIt<SyncCubit>()),
        BlocProvider<NetworkCubit>.value(value: getIt<NetworkCubit>()),
      ],
      child: MaterialApp(
        title: 'Kashi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: Routes.wallet,
        onGenerateRoute: RouteGenerator.generate,
        navigatorObservers: [appRouteObserver],
        // Wraps every routed page so the offline banner sits beneath the
        // AppBar without each screen needing to opt in.
        builder: (context, child) =>
            OfflineBanner(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
