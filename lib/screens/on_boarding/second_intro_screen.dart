import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/pager/dashboard_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/preference_utils.dart';

import 'third_intro_screen.dart';

class SecondIntroScreen extends StatelessWidget {
  const SecondIntroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFBC2030),
            Color(0xFFBC2030),
            Color(0xFF7A151F),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Constants.colorGray,
                            size: 24,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Spacer(flex: 1),
                        Hero(
                          tag: 'App_logo',
                          child: Image.asset(
                            'assets/ic_intro_logo_white.png',
                            width: 140.0,
                            height: 80,
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                  LottieBuilder.asset('animations/second_onboarding.json'),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          Languages.of(context)!.labelScreenIntro2Line1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: Constants.appFont,
                            color: Constants.colorWhite,
                            fontWeight: FontWeight.w900,
                            fontSize: 28.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Text(
                            Languages.of(context)!.labelScreenIntro2Line2,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Constants.colorWhite.withOpacity(0.7), fontFamily: Constants.appFont, fontSize: 16.0),
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        child: Text(
                          Languages.of(context)!.labelSkip,
                          style: TextStyle(
                            color: Constants.colorGray,
                            fontFamily: Constants.appFont,
                            fontSize: 16.0,
                          ),
                        ),
                        onPressed: () {
                          PreferenceUtils.setIsIntroDone("isIntroDone", true);
                          Navigator.of(context).pushAndRemoveUntil(
                              Transitions(
                                transitionType: TransitionType.fade,
                                curve: Curves.bounceInOut,
                                reverseCurve: Curves.fastLinearToSlowEaseIn,
                                widget: DashboardScreen(0),
                              ),
                              (Route<dynamic> route) => false);
                        },
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 4,
                            backgroundColor: Constants.colorGray.withOpacity(0.5),
                          ),
                          const SizedBox(width: 5),
                          CircleAvatar(
                            radius: 4,
                            backgroundColor: Constants.colorWhite,
                          ),
                          const SizedBox(width: 5),
                          CircleAvatar(
                            radius: 4,
                            backgroundColor: Constants.colorGray.withOpacity(0.5),
                          ),
                        ],
                      ),
                      const Spacer(),
                      TextButton(
                        child: Text(
                          'Next',
                          style: TextStyle(
                            color: Constants.colorYellow,
                            fontFamily: Constants.appFontBold,
                            fontWeight: FontWeight.normal,
                            fontSize: 16.0,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            Transitions(
                              transitionType: TransitionType.fade,
                              curve: Curves.easeInOut,
                              duration: const Duration(milliseconds: 250),
                              reverseCurve: Curves.easeInOut,
                              widget: const ThirdIntroScreen(),
                            ),
                          );
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget? page;
  SlideRightRoute({this.page})
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) => page!,
          transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
}
