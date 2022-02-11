import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';

class CustomAppBarWithButton extends StatelessWidget with PreferredSizeWidget {
  CustomAppBarWithButton({Key? key, required this.title, required this.buttonText, required this.buttonColor, required this.onPressed}) : super(key: key);

  final String title;
  final String buttonText;
  final Color buttonColor;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Color(0xFF03041D)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(color: const Color(0xFF03041D), fontFamily: Constants.appFont),
      ),
      actions: [
        GestureDetector(
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Center(
              child: Text(
                buttonText,
                style: TextStyle(fontSize: 14.sp, color: buttonColor),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
