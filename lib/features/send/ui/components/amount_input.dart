import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountInput extends StatelessWidget {
  const AmountInput({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: const InputDecoration(
        labelText: 'Amount',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final v = double.tryParse((value ?? '').trim());
        if (v == null || v <= 0) return 'Enter a valid amount';
        return null;
      },
    );
  }
}
