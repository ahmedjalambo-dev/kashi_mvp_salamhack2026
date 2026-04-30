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
            SendReady(:final qrData, :final amount) => Padding(
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
                  FilledButton(
                    onPressed: cubit.reset,
                    child: const Text('New payment'),
                  ),
                ],
              ),
            ),
            _ => _SendForm(error: state is SendFailure ? state.message : null),
          };
        },
      ),
    );
  }
}

class _SendForm extends StatelessWidget {
  const _SendForm({this.error});
  final String? error;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SendCubit>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: cubit.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant),
                boxShadow: isDark
                    ? null
                    : [
                        const BoxShadow(
                          color: Color(0x0F1A1A1A),
                          offset: Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AMOUNT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AmountInput(controller: cubit.amountController),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Recipient Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RECIPIENT PUBLIC KEY',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: cubit.recipientController,
                    decoration: InputDecoration(
                      hintText: 'Enter public key...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    maxLines: 3,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Required'
                        : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: cubit.createPayment,
              icon: const Icon(Icons.qr_code),
              label: const Text('Generate QR'),
            ),
            if (error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
