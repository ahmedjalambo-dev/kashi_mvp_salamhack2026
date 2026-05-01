import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/components/amount_input.dart';
import '../../../core/components/loading_view.dart';
import '../../../core/components/qr_view.dart';
import '../../send/ui/components/scanner_view.dart';
import '../state/receive_cubit.dart';
import '../state/receive_state.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receive')),
      body: BlocBuilder<ReceiveCubit, ReceiveState>(
        builder: (context, state) {
          final cubit = context.read<ReceiveCubit>();
          return switch (state) {
            ReceiveRequestInput() => _RequestInputView(error: null),
            ReceiveFailure(:final message) => _RequestInputView(error: message),
            ReceiveBuildingRequest() => const LoadingView(
              message: 'Creating request…',
            ),
            ReceiveShowingRequest(
              :final qrData,
              :final request,
              :final errorMessage,
            ) =>
              _ShowRequestView(
                qrData: qrData,
                amount: request.amount,
                errorMessage: errorMessage,
                cubit: cubit,
              ),
            ReceiveScanningConfirmation() => ScannerView(
              onDetect: cubit.onConfirmationScanned,
            ),
            ReceiveConfirmingPayment() => const LoadingView(
              message: 'Verifying confirmation…',
            ),
            ReceiveDone() => _DoneView(cubit: cubit),
          };
        },
      ),
    );
  }
}

class _RequestInputView extends StatelessWidget {
  const _RequestInputView({required this.error});
  final String? error;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReceiveCubit>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: cubit.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AmountInput(controller: cubit.amountController),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: cubit.buildRequest,
              icon: const Icon(LucideIcons.qrCode),
              label: const Text('Generate Request'),
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

class _ShowRequestView extends StatelessWidget {
  const _ShowRequestView({
    required this.qrData,
    required this.amount,
    required this.cubit,
    this.errorMessage,
  });

  final String qrData;
  final double amount;
  final ReceiveCubit cubit;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      '₪ ${amount.toStringAsFixed(2)}',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 16),
                    QrView(data: qrData, label: 'Show this code to the sender'),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // const SizedBox(height: 12),
          // FilledButton(
          //   onPressed: cubit.markFulfilled,
          //   style: const ButtonStyle(
          //     minimumSize: WidgetStatePropertyAll(Size.fromHeight(48)),
          //   ),
          //   child: const Text('Mark fulfilled'),
          // ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: cubit.openConfirmationScanner,
            icon: const Icon(LucideIcons.scanLine),
            label: const Text("Scan sender's confirmation"),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: cubit.restart,
            child: const Text('New request'),
          ),
        ],
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  const _DoneView({required this.cubit});
  final ReceiveCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(LucideIcons.circleCheck, size: 64, color: Colors.green),
          const SizedBox(height: 12),
          Text(
            'Payment received',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'The transaction is queued for sync. It will confirm once either device is online.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
