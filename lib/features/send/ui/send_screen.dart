import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/loading_view.dart';
import '../state/send_cubit.dart';
import '../state/send_state.dart';
import 'components/scanner_view.dart';

class SendScreen extends StatelessWidget {
  const SendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send')),
      body: BlocListener<SendCubit, SendState>(
        listenWhen: (_, s) => s is SendConfirming,
        listener: (context, state) {
          final cubit = context.read<SendCubit>();
          final s = state as SendConfirming;
          showModalBottomSheet<void>(
            context: context,
            isDismissible: false,
            enableDrag: false,
            isScrollControlled: true,
            builder: (sheetCtx) => _ConfirmSendSheet(
              amount: s.amount,
              receiverPublicKey: s.receiverPublicKey,
              onConfirm: () {
                Navigator.pop(sheetCtx);
                cubit.confirmAndSign();
              },
              onCancel: () {
                Navigator.pop(sheetCtx);
                cubit.cancelReview();
              },
            ),
          );
        },
        child: BlocBuilder<SendCubit, SendState>(
          builder: (context, state) {
            final cubit = context.read<SendCubit>();
            return switch (state) {
              SendScanning() => ScannerView(onDetect: cubit.onScan),
              SendVerifying() => const LoadingView(message: 'Verifying request…'),
              SendConfirming() =>
                ScannerView(onDetect: cubit.onScan, paused: true),
              SendSuccess(:final amount, :final receiverPublicKey) =>
                _SuccessView(
                  amount: amount,
                  receiverPublicKey: receiverPublicKey,
                  onDone: () => Navigator.of(context).pop(),
                ),
              SendFailure(:final message) => _FailureView(
                message: message,
                onRescan: cubit.rescan,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _ConfirmSendSheet extends StatelessWidget {
  const _ConfirmSendSheet({
    required this.amount,
    required this.receiverPublicKey,
    required this.onConfirm,
    required this.onCancel,
  });

  final double amount;
  final String receiverPublicKey;
  final VoidCallback onConfirm;
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
            Text('Review transfer', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('You are about to send', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              amount.toStringAsFixed(2),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('To', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            SelectableText(
              receiverPublicKey,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: onConfirm,
              child: const Text('Confirm & Send'),
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

class _SuccessView extends StatelessWidget {
  const _SuccessView({
    required this.amount,
    required this.receiverPublicKey,
    required this.onDone,
  });

  final double amount;
  final String receiverPublicKey;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
          const SizedBox(height: 12),
          Text(
            amount.toStringAsFixed(2),
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text('Will sync when online', textAlign: TextAlign.center),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: onDone,
            style: const ButtonStyle(
              minimumSize: WidgetStatePropertyAll(Size.fromHeight(48)),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.message, required this.onRescan});
  final String message;
  final VoidCallback onRescan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(
            'Cannot process',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: onRescan,
            style: const ButtonStyle(
              minimumSize: WidgetStatePropertyAll(Size.fromHeight(48)),
            ),
            child: const Text('Scan again'),
          ),
        ],
      ),
    );
  }
}
