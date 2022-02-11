import 'package:flutter/material.dart';

class HeroImage extends StatelessWidget {
  const HeroImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Hero(
          tag: 'App_logo',
          child: Center(
            child: Image.asset(
              'assets/ic_logo_red.png',
              width: 140.0,
              height: 80,
            ),
          ),
        ),
      ),
    );
  }
}
