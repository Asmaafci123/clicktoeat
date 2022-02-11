import 'package:flutter/material.dart';

import 'constants.dart';

class AppLabelWidget extends StatelessWidget {
  const AppLabelWidget({required this.title, Key? key}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Text(
        title,
        style: Constants.kAppLabelWidget,
      ),
    );
  }
}
