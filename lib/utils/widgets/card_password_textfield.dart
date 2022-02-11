import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'constants.dart';

// ignore: must_be_immutable
class CardPasswordTextFieldWidget extends StatefulWidget {
  CardPasswordTextFieldWidget({
    Key? key,
    required this.hintText,
    required this.isPasswordVisible,
    this.textEditingController,
    this.validator,
  }) : super(key: key);

  String hintText;
  bool isPasswordVisible;
  Function? validator;
  final TextEditingController? textEditingController;

  @override
  _CardTextFieldWidgetState createState() => _CardTextFieldWidgetState();
}

class _CardTextFieldWidgetState extends State<CardPasswordTextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator as String? Function(String?)?,
      controller: widget.textEditingController,
      obscureText: widget.isPasswordVisible,
      decoration: InputDecoration(
        hintStyle: TextStyle(color: Constants.colorHint),
        hintText: widget.hintText,
        suffixIcon: IconButton(
            icon: SvgPicture.asset(
              // Based on passwordVisible state choose the icon
              widget.isPasswordVisible ? 'assets/ic_eye_hide.svg' : 'assets/ic_eye.svg',
              height: ScreenUtil().setHeight(15),
              width: 15,
              color: Constants.colorTheme,
            ),
            onPressed: () {
              setState(() {
                widget.isPasswordVisible = !widget.isPasswordVisible;
              });
            }),
        errorStyle: TextStyle(fontFamily: Constants.appFont, color: Colors.red),
        filled: true,
        fillColor: Constants.colorWhite,
        contentPadding: const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0, right: 14),
        errorMaxLines: 2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(width: 0.5, color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(width: 0.5, color: Colors.grey),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(width: 0.5, color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(width: 0.5, color: Colors.grey),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(width: 0.5, color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(width: 1, color: Colors.red),
        ),
      ),
    );
  }
}
