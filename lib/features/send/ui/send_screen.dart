import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/loading_view.dart';
import '../../wallet/data/models/wallet_profile.dart';
import '../state/send_cubit.dart';
import '../state/send_state.dart';
import 'components/amount_input.dart';
import 'components/qr_display.dart';

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
              receiverProfile: s.receiverProfile,
              onConfirm: () {
                Navigator.pop(sheetCtx);
                cubit.confirmAndGenerateQR();
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
              SendLoading() => const LoadingView(message: 'Signing payment…'),
              SendReady(:final qrData, :final amount) => _QrView(
                qrData: qrData,
                amount: amount,
                cubit: cubit,
              ),
              SendConfirming() => const _SendForm(error: null),
              _ => _SendForm(
                error: state is SendFailure ? state.message : null,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _QrView extends StatelessWidget {
  const _QrView({
    required this.qrData,
    required this.amount,
    required this.cubit,
  });

  final String qrData;
  final double amount;
  final SendCubit cubit;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmCancel(context)) {
          await cubit.cancelTransfer();
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: QrDisplay(data: qrData, amount: amount),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: cubit.reset,
              style: const ButtonStyle(
                minimumSize: WidgetStatePropertyAll(Size.fromHeight(48)),
              ),
              child: const Text('New payment'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> _confirmCancel(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Cancel transfer?'),
      content: const Text(
        'Warning: If the receiver has already scanned this QR code, '
        'the transfer will still be processed when they connect to '
        'the internet, and your balance will be adjusted accordingly. '
        'Do you still want to cancel?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Keep showing'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Cancel transfer'),
        ),
      ],
    ),
  );
  return ok ?? false;
}

class _SendForm extends StatelessWidget {
  const _SendForm({this.error});
  final String? error;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SendCubit>();
    final profile = cubit.receiverProfile;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: cubit.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sending to',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.displayName,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          profile.phone,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                        Text(
                          profile.iban,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AmountInput(controller: cubit.amountController),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                final amount =
                    double.tryParse(cubit.amountController.text.trim()) ?? 0;
                cubit.reviewTransfer(amount);
              },
              icon: const Icon(Icons.qr_code),
              label: const Text('Generate QR'),
            ),
            if (error != null) ...[
              const SizedBox(height: 16),
              Text(error!, style: const TextStyle(color: Colors.redAccent)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConfirmSendSheet extends StatelessWidget {
  const _ConfirmSendSheet({
    required this.amount,
    required this.receiverProfile,
    required this.onConfirm,
    required this.onCancel,
  });

  final double amount;
  final WalletProfile receiverProfile;
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
            Text(
              receiverProfile.displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              receiverProfile.phone,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
            Text(
              receiverProfile.iban,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: onConfirm,
              child: const Text('Confirm & Generate'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onCancel, child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }
}
