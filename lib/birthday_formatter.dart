import 'package:flutter/services.dart';

class BirthdayInputFormatter extends TextInputFormatter {
    final RegExp _birthdayPartialRegExp = RegExp(r'^\d{0,4}-?\d{0,2}-?\d{0,2}$');

    @override
    TextEditingValue formatEditUpdate(
        TextEditingValue oldValue,
        TextEditingValue newValue,
    ) {
        String text = newValue.text;

        if (text.length < oldValue.text.length) {
            return newValue;
        }
        if (text.length > 10) {
            return oldValue;
        }

        if (text.length == 4 && oldValue.text.length == 3) {
            return TextEditingValue(
                text: '$text-',
                selection: const TextSelection.collapsed(offset: 5),
            );
        }
        if (text.length == 7 && oldValue.text.length == 6) {
            return TextEditingValue(
                text: '$text-',
                selection: const TextSelection.collapsed(offset: 8)
            );
        }

        return newValue;
    }
}