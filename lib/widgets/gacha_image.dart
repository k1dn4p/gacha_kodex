import 'package:flutter/material.dart';

// Display a neutral placeholder until the Christmas artwork is supplied.
Widget missingGachaImage(
    BuildContext context, Object error, StackTrace? stack) {
  return const ColoredBox(
    color: Color(0xFFFAF5EB),
    child: Center(
        child: Icon(Icons.confirmation_number_outlined,
            color: Color(0xFF254F43), size: 32)),
  );
}
