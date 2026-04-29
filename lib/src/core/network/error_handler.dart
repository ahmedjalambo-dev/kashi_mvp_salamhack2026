import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'error_model.dart';

class ErrorHandler {
  const ErrorHandler();

  ErrorModel map(Object error) {
    if (error is PostgrestException) {
      return ErrorModel(message: error.message, code: error.code);
    }
    if (error is AuthException) {
      return ErrorModel(message: error.message, code: error.statusCode);
    }
    if (error is SocketException) {
      return const ErrorModel(message: 'No internet connection', code: 'OFFLINE');
    }
    if (error is FormatException) {
      return ErrorModel(message: 'Invalid data format: ${error.message}', code: 'FORMAT');
    }
    return ErrorModel(message: error.toString(), code: 'UNKNOWN');
  }
}
