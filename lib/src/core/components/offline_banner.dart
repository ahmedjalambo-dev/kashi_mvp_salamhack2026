import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../network/network_cubit.dart';
import '../network/network_state.dart';

/// Persistent banner shown beneath the AppBar of every screen when the
/// device is offline. Wrap the app's body via [MaterialApp.builder] so it
/// sits above all routed screens without each screen needing to opt in.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Column(
        children: [
          BlocBuilder<NetworkCubit, NetworkState>(
            buildWhen: (a, b) => a.runtimeType != b.runtimeType,
            builder: (context, state) {
              final offline = state is NetworkOffline;
              return AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topCenter,
                child: offline ? const _OfflineBar() : const SizedBox.shrink(),
              );
            },
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _OfflineBar extends StatelessWidget {
  const _OfflineBar();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        color: scheme.errorContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 16, color: scheme.onErrorContainer),
            const SizedBox(width: 8),
            Text(
              'Offline · No internet connection',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
