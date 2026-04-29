import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Stream<bool> get onStatusChange => _connectivity.onConnectivityChanged
      .map((events) => events.any((e) => e != ConnectivityResult.none));

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((e) => e != ConnectivityResult.none);
  }
}
