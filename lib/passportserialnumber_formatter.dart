import 'package:flutter/services.dart';

class PassportserialnumberFormatter extends TextInputFormatter{
  // final RegExp _partialPassportRegExp = RegExp(r'^[A-Z]{2}\d{7}$');
  final RegExp _partialPassportRegExp = RegExp(r'^[A-Z]{0,2}\d{0,7}$');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ){
    String text = newValue.text.toUpperCase();

    if(_partialPassportRegExp.hasMatch(text)){
      return newValue.copyWith(
        text: text,
        selection: newValue.selection,
      );
    }

    /*
    if(text.length < oldValue.text.length){
      return newValue;
    }
    if(text.length > 9){
      return oldValue;
    }te
    
    if (text.length == 2 && oldValue.text.length == 1){
      print("========== 2 && 1 ===========");
      return TextEditingValue(
        text: '$text'.toUpperCase(),
        // selection: const TextSelection.collapsed(offset: 2),
      );
    }
     */

    return newValue;
  }
}