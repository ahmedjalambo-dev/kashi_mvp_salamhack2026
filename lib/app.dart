import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/core/components/offline_banner.dart';
import 'src/core/di/injector.dart';
import 'src/core/network/network_cubit.dart';
import 'src/core/routes/route_generator.dart';
import 'src/core/routes/route_observer.dart';
import 'src/core/routes/routes.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/sync/state/sync_cubit.dart';

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
