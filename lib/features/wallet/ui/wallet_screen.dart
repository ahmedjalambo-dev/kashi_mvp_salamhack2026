import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/components/error_view.dart';
import '../../../core/components/loading_view.dart';
import '../../../core/di/injector.dart';
import '../../../core/network/network_cubit.dart';
import '../../../core/network/network_state.dart';
import '../../../core/routes/route_observer.dart';
import '../../../core/routes/routes.dart';
import '../../history/data/repositories/history_repository.dart';
import '../../history/state/history_cubit.dart';
import '../../history/ui/components/history_section.dart';
import '../../sync/state/sync_cubit.dart';
import '../../sync/state/sync_state.dart';
import '../data/models/wallet_profile.dart';
import '../state/wallet_cubit.dart';
import '../state/wallet_state.dart';
import 'components/balance_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with AutoRefreshRouteAware {
  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().initialize();
  }

  @override
  void onResurface() {
    context.read<WalletCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kashi Wallet')),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          return switch (state) {
            WalletInitial() ||
            WalletLoading() => const LoadingView(message: 'Preparing wallet…'),
            WalletFailure(:final message) => ErrorView(
              message: message,
              onRetry: () => context.read<WalletCubit>().initialize(),
            ),
            WalletReady(:final wallet, :final pendingOut) =>
              BlocProvider<HistoryCubit>(
                create: (_) => HistoryCubit(
                  repository: getIt<HistoryRepository>(),
                  publicKey: wallet.publicKey,
                )..load(),
                child: _WalletReadyView(
                  publicKey: wallet.publicKey,
                  balance: wallet.balance,
                  pendingOut: pendingOut,
                  profile: wallet.profile,
                ),
              ),
          };
        },
      ),
    );
  }
}

class _WalletReadyView extends StatelessWidget {
  const _WalletReadyView({
    required this.publicKey,
    required this.balance,
    required this.pendingOut,
    required this.profile,
  });

  final String publicKey;
  final double balance;
  final double pendingOut;
  final WalletProfile? profile;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final wallet = context.read<WalletCubit>();
        final history = context.read<HistoryCubit>();
        await wallet.refresh();
        await history.refresh();
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<NetworkCubit, NetworkState>(
            listenWhen: (a, b) => a is! NetworkOnline && b is NetworkOnline,
            listener: (context, _) {
              context.read<HistoryCubit>().refresh();
            },
          ),
          BlocListener<SyncCubit, SyncState>(
            listenWhen: (a, b) =>
                a is SyncRunning && b is SyncIdle && b.synced > 0,
            listener: (context, _) {
              context.read<WalletCubit>().refresh();
              context.read<HistoryCubit>().refresh();
            },
          ),
        ],
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (profile != null)
              BalanceCard(
                balance: balance,
                pendingOut: pendingOut,
                profile: profile!,
                onShowAddress: () => Navigator.pushNamed(
                  context,
                  Routes.myAddress,
                  arguments: (publicKey: publicKey, profile: profile!),
                ),
              )
            else
              BalanceCard(
                balance: balance,
                pendingOut: pendingOut,
                profile: const WalletProfile(
                  displayName: '—',
                  phone: '—',
                  iban: '—',
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: profile == null
                        ? null
                        : () => Navigator.pushNamed(
                            context,
                            Routes.scanRecipient,
                            arguments: (
                              senderPub: publicKey,
                              senderProfile: profile!,
                            ),
                          ),
                    icon: const Icon(LucideIcons.scanLine),
                    label: const Text('Send'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      Routes.receive,
                      arguments: publicKey,
                    ),
                    icon: const Icon(LucideIcons.qrCode),
                    label: const Text('Receive'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<SyncCubit, SyncState>(
              builder: (context, state) => switch (state) {
                SyncIdle(:final synced, :final failed)
                    when synced + failed > 0 =>
                  Text('Last sync: $synced ok, $failed failed'),
                SyncRunning() => const Text('Syncing…'),
                _ => const SizedBox.shrink(),
              },
            ),
            const SizedBox(height: 8),
            HistorySection(publicKey: publicKey),
          ],
        ),
      ),
    );
  }
}
