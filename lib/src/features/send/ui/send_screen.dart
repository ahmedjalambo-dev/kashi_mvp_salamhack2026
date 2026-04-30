import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/loading_view.dart';
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
      body: BlocBuilder<SendCubit, SendState>(
        builder: (context, state) {
          final cubit = context.read<SendCubit>();
          return switch (state) {
            SendLoading() => const LoadingView(message: 'Signing payment…'),
            SendReady(:final qrData, :final amount) => _QrView(
              qrData: qrData,
              amount: amount,
              cubit: cubit,
            ),
            _ => _SendForm(error: state is SendFailure ? state.message : null),
          };
        },
      ),
    );
  }
}

/// Shown while the QR code is visible. Intercepts back-navigation (AppBar and
/// hardware back) with a confirmation dialog so the user doesn't accidentally
/// lock their funds.
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
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                if (await _confirmCancel(context)) {
                  await cubit.cancelTransfer();
                  // Stays on screen; BlocBuilder rebuilds to SendInitial form.
                }
              },
              // icon: const Icon(Icons.cancel_outlined),
              // label:
              style: OutlinedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Cancel transfer'),
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
        'The receiver will no longer be able to scan this QR code. '
        'Your funds will be returned to your available balance.',
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: cubit.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: cubit.recipientController,
              decoration: const InputDecoration(
                labelText: 'Recipient public key',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            AmountInput(controller: cubit.amountController),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: cubit.createPayment,
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
