import 'package:flutter/services.dart';

class UniversalPassSNPnflInputFormatter extends TextInputFormatter {
  final RegExp _partialPassSerialNumberRegExp = RegExp(r'^\d{0,14}$');
  final RegExp _partialPassportRegExp = RegExp(r'^[A-Z]{0,2}\d{0,7}$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    if (newValue.text.isNotEmpty) {
      String firstChar = newValue.text[0];

      bool isLetter = RegExp(r'[a-zA-Z]').hasMatch(firstChar);
      bool isDigit = RegExp(r'[0-9]').hasMatch(firstChar);

      if (isDigit) {
        print("========== Birinchi symbol: Raqam ==========");
        if (_partialPassSerialNumberRegExp.hasMatch(text)) {
          return TextEditingValue(text: text, selection: newValue.selection);
        }
      } else if (isLetter) {
        text = text.toUpperCase();
        print("========== Birinchi symbol: Harf ==========");
        if (_partialPassportRegExp.hasMatch(text)) {
          return newValue.copyWith(text: text, selection: newValue.selection);
        }
      }
      return oldValue;
    }

    return newValue;
  }
}
