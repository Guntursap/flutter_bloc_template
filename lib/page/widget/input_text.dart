// lib/page/widget/input_text.dart
import 'package:flutter/material.dart';

class InputText extends StatelessWidget {
  final Key? fieldKey;
  final String label;
  final TextEditingController controller;
  final bool obscure;
  const InputText(
      {super.key, this.fieldKey, required this.label,
       required this.controller, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: fieldKey,
      controller: controller,
      obscureText: obscure,
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }
}
