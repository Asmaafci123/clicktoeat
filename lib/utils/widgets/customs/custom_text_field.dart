import 'package:flutter/material.dart';

import '../constants.dart';

// ignore: must_be_immutable
class CustomTextField extends StatelessWidget {
  CustomTextField({
    Key? key,
    required this.hintText,
    required this.textInputType,
    required this.textInputAction,
    required this.textEditingController,
    this.errorText,
    this.validator,
    required this.onFieldSubmitted,
  }) : super(key: key);

  final String? hintText, errorText;
  String? Function(String?)? validator;
  Function(String)? onFieldSubmitted;
  final TextEditingController textEditingController;
  final TextInputType textInputType;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      keyboardType: textInputType,
      controller: textEditingController,
      decoration: Constants.kTextFieldInputDecoration.copyWith(hintText: hintText, errorText: errorText),
    );
  }
}
