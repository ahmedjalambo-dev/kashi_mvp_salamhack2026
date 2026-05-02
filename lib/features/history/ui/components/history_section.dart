import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kashi_mvp_salamhack2026/features/sync/state/sync_cubit.dart';
import 'package:kashi_mvp_salamhack2026/features/sync/state/sync_state.dart';

import '../../state/history_cubit.dart';
import '../../state/history_state.dart';
import 'transaction_tile.dart';

class HistorySection extends StatelessWidget {
  const HistorySection({super.key, required this.publicKey});

  final String publicKey;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        return switch (state) {
          HistoryInitial() || HistoryLoading() => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          HistoryReady() => _Ready(state: state, publicKey: publicKey),
        };
      },
    );
  }
}

class _Ready extends StatelessWidget {
  const _Ready({required this.state, required this.publicKey});

  final HistoryReady state;
  final String publicKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.refreshing) const LinearProgressIndicator(minHeight: 2),
        if (state.remoteError != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Showing cached data — ${state.remoteError}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        _Header(
          title: 'Pending offline',
          count: state.pending.length,
          subtitle: state.pending.isEmpty
              ? 'No transactions waiting to sync.'
              : 'Will sync automatically when online.',
        ),
        if (state.pending.isNotEmpty)
          ...state.pending.map(
            (tx) => TransactionTile(tx: tx, myPublicKey: publicKey),
          )
        else
          const _EmptyHint(text: 'You\'re all caught up.'),
        const SizedBox(height: 16),
        _Header(
          title: 'History',
          count: state.completed.length,
          subtitle: 'Sent and received transactions.',
        ),
        if (state.completed.isNotEmpty)
          ...state.completed.map(
            (tx) => TransactionTile(tx: tx, myPublicKey: publicKey),
          )
        else
          const _EmptyHint(text: 'No transactions yet.'),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.count,
    required this.subtitle,
  });

  final String title;
  final int count;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$count', style: theme.textTheme.labelSmall),
              ),
              Spacer(),
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
          Text(subtitle, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
