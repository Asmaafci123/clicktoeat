import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/pager/dashboard_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:mealup/utils/widgets/preference_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'second_intro_screen.dart';

class FirstIntroScreen extends StatelessWidget {
  const FirstIntroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken).isEmpty) {
      getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
    }

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
                    child: Hero(
                      tag: 'App_logo',
                      child: Image.asset(
                        'assets/ic_intro_logo_white.png',
                        width: 140.0,
                        height: 80,
                      ),
                    ),
                  ),
                  LottieBuilder.asset('animations/first_onboarding.json'),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          Languages.of(context)!.labelScreenIntro1Line1,
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
                            Languages.of(context)!.labelScreenIntro1Line2,
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
                            backgroundColor: Constants.colorWhite,
                          ),
                          const SizedBox(width: 5),
                          CircleAvatar(
                            radius: 4,
                            backgroundColor: Constants.colorGray.withOpacity(0.5),
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
                              duration: const Duration(milliseconds: 500),
                              reverseCurve: Curves.easeInOut,
                              widget: const SecondIntroScreen(),
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

  getOneSingleToken(String appId) async {
    String? userId = '';

    /* var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };*/

    OneSignal.shared.consentGranted(true);
    await OneSignal.shared.setAppId(appId);
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
    OneSignal.shared.promptLocationPermission();

    // OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

    var status = await (OneSignal.shared.getDeviceState());

    // var pushToken = await status.subscriptionStatus.pushToken;

    if (status != null) {
      userId = status.userId;
      if (status.userId != null) SharedPreferenceUtil.putString(Constants.appPushOneSingleToken, userId!);
    }

    /*if(SharedPreferenceUtil.getString(Constants.appPushOneSingleToken).isEmpty){
      getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
    }*/
  }
}
