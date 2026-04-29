import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/core/di/injector.dart';
import 'src/core/routes/route_generator.dart';
import 'src/core/routes/routes.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/sync/state/sync_cubit.dart';

class KashiApp extends StatelessWidget {
  const KashiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SyncCubit>.value(
      value: getIt<SyncCubit>(),
      child: MaterialApp(
        title: 'Kashi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: Routes.wallet,
        onGenerateRoute: RouteGenerator.generate,
      ),
    );
  }
}
