import 'package:equatable/equatable.dart';

sealed class SyncState extends Equatable {
  const SyncState();
  @override
  List<Object?> get props => [];
}

class SyncIdle extends SyncState {
  final int synced;
  final int failed;
  const SyncIdle({this.synced = 0, this.failed = 0});
  @override
  List<Object?> get props => [synced, failed];
}

class SyncRunning extends SyncState {
  const SyncRunning();
}

class SyncFailure extends SyncState {
  final String message;
  const SyncFailure(this.message);
  @override
  List<Object?> get props => [message];
}
