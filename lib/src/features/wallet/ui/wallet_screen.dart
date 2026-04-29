import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/error_view.dart';
import '../../../core/components/loading_view.dart';
import '../../../core/routes/routes.dart';
import '../../sync/state/sync_cubit.dart';
import '../../sync/state/sync_state.dart';
import '../state/wallet_cubit.dart';
import '../state/wallet_state.dart';
import 'components/balance_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kashi Wallet'),
        actions: [
          BlocBuilder<SyncCubit, SyncState>(
            builder: (context, state) {
              return IconButton(
                tooltip: 'Sync',
                onPressed: state is SyncRunning
                    ? null
                    : () => context.read<SyncCubit>().runOnce(),
                icon: state is SyncRunning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          return switch (state) {
            WalletInitial() || WalletLoading() =>
              const LoadingView(message: 'Preparing wallet…'),
            WalletFailure(:final message) => ErrorView(
                message: message,
                onRetry: () => context.read<WalletCubit>().initialize(),
              ),
            WalletReady(:final wallet) => RefreshIndicator(
                onRefresh: () => context.read<WalletCubit>().refresh(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    BalanceCard(
                      balance: wallet.balance,
                      publicKey: wallet.publicKey,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        Routes.send,
                        arguments: wallet.publicKey,
                      ),
                      icon: const Icon(Icons.qr_code),
                      label: const Text('Send'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        Routes.receive,
                        arguments: wallet.publicKey,
                      ),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Receive'),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<SyncCubit, SyncState>(
                      builder: (context, state) => switch (state) {
                        SyncIdle(:final synced, :final failed) when synced + failed > 0 =>
                          Text('Last sync: $synced ok, $failed failed'),
                        SyncRunning() => const Text('Syncing…'),
                        _ => const SizedBox.shrink(),
                      },
                    ),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }
}
