import 'package:equatable/equatable.dart';

sealed class NetworkState extends Equatable {
  const NetworkState();
  @override
  List<Object?> get props => [];
}

class NetworkInitial extends NetworkState {
  const NetworkInitial();
}

class NetworkOnline extends NetworkState {
  const NetworkOnline();
}

class NetworkOffline extends NetworkState {
  const NetworkOffline();
}
