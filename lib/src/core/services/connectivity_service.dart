import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Emits `true` only when both a network interface is available AND an
  /// actual internet endpoint is reachable.
  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.asyncMap((events) async {
        final hasInterface =
            events.any((e) => e != ConnectivityResult.none);
        if (!hasInterface) return false;
        return _hasRealConnectivity();
      });

  /// Returns `true` only if a network interface is up AND an internet
  /// endpoint responds within 3 seconds.
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    final hasInterface =
        results.any((e) => e != ConnectivityResult.none);
    if (!hasInterface) return false;
    return _hasRealConnectivity();
  }

  /// Lightweight probe — HTTP HEAD to Google's connectivity-check endpoint.
  /// Returns `true` if a 204 response comes back within 3 seconds.
  Future<bool> _hasRealConnectivity() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);
      final request = await client
          .headUrl(
            Uri.parse('https://connectivitycheck.gstatic.com/generate_204'),
          )
          .timeout(const Duration(seconds: 3));
      final response = await request.close().timeout(
            const Duration(seconds: 3),
          );
      client.close(force: true);
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}
