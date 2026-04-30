import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/loading_view.dart';
import '../../send/data/models/payment_payload.dart';
import '../../sync/state/sync_cubit.dart';
import '../state/receive_cubit.dart';
import '../state/receive_state.dart';
import 'components/scanner_view.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receive')),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ReceiveCubit, ReceiveState>(
            listenWhen: (_, s) => s is ReceiveSuccess,
            listener: (context, _) => context.read<SyncCubit>().runOnce(),
          ),
          BlocListener<ReceiveCubit, ReceiveState>(
            listenWhen: (_, s) => s is ReceiveConfirming,
            listener: (context, state) {
              final cubit = context.read<ReceiveCubit>();
              final payload = (state as ReceiveConfirming).payload;
              showModalBottomSheet<void>(
                context: context,
                isDismissible: false,
                enableDrag: false,
                isScrollControlled: true,
                builder: (sheetCtx) => _ConfirmSheet(
                  payload: payload,
                  onAccept: () {
                    Navigator.pop(sheetCtx);
                    cubit.confirmTransaction(payload);
                  },
                  onCancel: () {
                    Navigator.pop(sheetCtx);
                    cubit.cancelTransaction();
                  },
                ),
              );
            },
          ),
        ],
        child: BlocBuilder<ReceiveCubit, ReceiveState>(
          builder: (context, state) {
            final cubit = context.read<ReceiveCubit>();
            return switch (state) {
              ReceiveScanning() => ScannerView(onDetect: cubit.onScan),
              ReceiveConfirming() =>
                ScannerView(onDetect: cubit.onScan, paused: true),
              ReceiveVerifying() => const LoadingView(
                message: 'Verifying signature…',
              ),
              ReceiveSuccess(:final payload) => _ResultView(
                title: 'Saved as pending sync',
                message:
                    'Received ${payload.amount.toStringAsFixed(2)}.\nWill sync on next online check.',
                onAction: cubit.rescan,
                actionLabel: 'Scan another',
                isError: false,
              ),
              ReceiveFailure(:final message) => _ResultView(
                title: 'Cannot accept',
                message: message,
                onAction: cubit.rescan,
                actionLabel: 'Try again',
                isError: true,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _ConfirmSheet extends StatelessWidget {
  const _ConfirmSheet({
    required this.payload,
    required this.onAccept,
    required this.onCancel,
  });

  final PaymentPayload payload;
  final VoidCallback onAccept;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Confirm Payment', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(
              payload.amount.toStringAsFixed(2),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('From', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            SelectableText(
              payload.senderPublicKey,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: onAccept,
              child: const Text('Accept & Sync'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onCancel,
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.title,
    required this.message,
    required this.onAction,
    required this.actionLabel,
    required this.isError,
  });

  final String title;
  final String message;
  final VoidCallback onAction;
  final String actionLabel;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            size: 64,
            color: isError ? Colors.redAccent : Colors.green,
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
