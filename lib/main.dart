import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'src/core/constants/app_constants.dart';
import 'src/core/di/injector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env[AppConstants.envSupabaseUrl] ?? '',
    anonKey: dotenv.env[AppConstants.envSupabaseAnonKey] ?? '',
  );

  configureDependencies();
  runApp(const KashiApp());
}
