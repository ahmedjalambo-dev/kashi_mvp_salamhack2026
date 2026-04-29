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
