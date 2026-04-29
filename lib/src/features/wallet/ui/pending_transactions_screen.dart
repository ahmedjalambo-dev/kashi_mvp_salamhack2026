import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/error_view.dart';
import '../../../core/components/loading_view.dart';
import '../data/models/pending_tx_display.dart';
import '../state/pending_tx_cubit.dart';
import '../state/pending_tx_state.dart';

class PendingTransactionsScreen extends StatefulWidget {
  const PendingTransactionsScreen({super.key});

  @override
  State<PendingTransactionsScreen> createState() =>
      _PendingTransactionsScreenState();
}

class _PendingTransactionsScreenState extends State<PendingTransactionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PendingTxCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Transactions')),
      body: BlocBuilder<PendingTxCubit, PendingTxState>(
        builder: (context, state) {
          return switch (state) {
            PendingTxLoading() =>
              const LoadingView(message: 'Loading transactions…'),
            PendingTxFailure(:final message) => ErrorView(
                message: message,
                onRetry: () => context.read<PendingTxCubit>().load(),
              ),
            PendingTxLoaded(:final transactions) => transactions.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
                    onRefresh: () => context.read<PendingTxCubit>().load(),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: transactions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (_, i) =>
                          _PendingTxTile(tx: transactions[i]),
                    ),
                  ),
          };
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64, color: Colors.green.shade400),
            const SizedBox(height: 12),
            Text(
              'All caught up!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'No pending transactions.\nEverything has been synced.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingTxTile extends StatelessWidget {
  const _PendingTxTile({required this.tx});
  final PendingTxDisplay tx;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isError = tx.status == 'rejected' || tx.status == 'failed_permanently';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: amount + status chip
            Row(
              children: [
                Icon(
                  tx.isPending ? Icons.hourglass_top : Icons.error_outline,
                  size: 20,
                  color: isError
                      ? Colors.redAccent
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  tx.amount.toStringAsFixed(2),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _StatusChip(tx: tx),
              ],
            ),
            const SizedBox(height: 10),

            // From / To
            _KeyValueRow(
              label: 'From',
              value: _truncateKey(tx.senderPublicKey),
            ),
            const SizedBox(height: 4),
            _KeyValueRow(
              label: 'To',
              value: _truncateKey(tx.receiverPublicKey),
            ),

            // Retry count (if > 0)
            if (tx.retryCount > 0) ...[
              const SizedBox(height: 4),
              _KeyValueRow(
                label: 'Retries',
                value: '${tx.retryCount}',
              ),
            ],

            // Error message
            if (tx.lastError != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tx.lastError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],

            // Timestamp
            const SizedBox(height: 8),
            Text(
              _formatDate(tx.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncateKey(String key) {
    if (key.length <= 16) return key;
    return '${key.substring(0, 8)}…${key.substring(key.length - 8)}';
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day}/${local.month}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.tx});
  final PendingTxDisplay tx;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (tx.status) {
      'pending_sync' || 'syncing' => (
        Colors.orange.shade50,
        Colors.orange.shade800,
      ),
      'rejected' => (
        Colors.red.shade50,
        Colors.red.shade800,
      ),
      'failed_permanently' => (
        Colors.red.shade100,
        Colors.red.shade900,
      ),
      _ => (Colors.grey.shade100, Colors.grey.shade800),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tx.statusLabel,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
