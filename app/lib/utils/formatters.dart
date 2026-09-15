import 'package:flutter/services.dart';

/// Formats digits as `000.000.000-00` while typing, capped at 11 digits.
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text.replaceAll(RegExp(r'\D'), '');
    final digits = raw.length > 11 ? raw.substring(0, 11) : raw;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if (i == 2 || i == 5) {
        if (i != digits.length - 1) buffer.write('.');
      } else if (i == 8) {
        if (i != digits.length - 1) buffer.write('-');
      }
    }
    final text = buffer.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

/// Formats digits as `DD/MM/AAAA` while typing, capped at 8 digits.
class NascInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text.replaceAll(RegExp(r'\D'), '');
    final digits = raw.length > 8 ? raw.substring(0, 8) : raw;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if ((i == 1 || i == 3) && i != digits.length - 1) buffer.write('/');
    }
    final text = buffer.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

/// Allows digits, X/x, dots and hyphens, capped at 14 characters — no
/// auto-inserted separators (RG formats vary by state).
class RgInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text.replaceAll(RegExp(r'[^\dxX.\-]'), '');
    final text = raw.length > 14 ? raw.substring(0, 14) : raw;
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
