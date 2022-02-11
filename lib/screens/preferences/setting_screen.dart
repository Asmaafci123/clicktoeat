import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/preferences/settings/about_app_screen.dart';
import 'package:mealup/screens/preferences/settings/about_company_screen.dart';
import 'package:mealup/screens/preferences/settings/change_password_user.dart';
import 'package:mealup/screens/preferences/settings/feedback_screen.dart';
import 'package:mealup/screens/preferences/settings/languages_screen.dart';
import 'package:mealup/screens/preferences/settings/privacy_policy_screen.dart';
import 'package:mealup/screens/terms_of_use_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:mealup/utils/widgets/customs/custom_app_bar.dart';
import 'package:simple_shadow/simple_shadow.dart';

import 'settings/edit_personal_information_screen.dart';
import 'settings/manage_addresses_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF2F2F4),
            Color(0xFFF2F2F4),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(
            title: Languages.of(context)!.screenSetting,
          ),
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              const Spacer(flex: 1),
              SimpleShadow(
                opacity: 0.6,
                color: Colors.black12,
                offset: const Offset(0, 3),
                sigma: 10,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      SettingMenuItem(
                        onTap: () {
                          Navigator.of(context).push(
                              Transitions(transitionType: TransitionType.fade, curve: Curves.bounceInOut, reverseCurve: Curves.fastLinearToSlowEaseIn, widget: const EditProfileInformationScreen()));
                        },
                        title: Languages.of(context)!.labelEditProfile,
                        icon: Icons.drive_file_rename_outline_rounded,
                      ),
                      SettingMenuItem(
                        onTap: () {
                          Navigator.of(context)
                              .push(Transitions(transitionType: TransitionType.fade, curve: Curves.bounceInOut, reverseCurve: Curves.fastLinearToSlowEaseIn, widget: const ManageAddressesScreen()));
                        },
                        title: Languages.of(context)!.labelManageYourLocation,
                        icon: Icons.edit_location_alt_rounded,
                      ),
                      SettingMenuItem(
                        onTap: () {
                          Navigator.of(context)
                              .push(Transitions(transitionType: TransitionType.fade, curve: Curves.bounceInOut, reverseCurve: Curves.fastLinearToSlowEaseIn, widget: const ChangePasswordScreen()));
                        },
                        title: Languages.of(context)!.labelChangePassword,
                        icon: Icons.vpn_key_rounded,
                      ),
                      SettingMenuItem(
                        onTap: () {
                          // _showDialog(context);
                          Navigator.of(context)
                              .push(Transitions(transitionType: TransitionType.fade, curve: Curves.bounceInOut, reverseCurve: Curves.fastLinearToSlowEaseIn, widget: const LanguagesScreen()));
                        },
                        title: Languages.of(context)!.labelLanguage,
                        icon: Icons.translate_rounded,
                      ),
                      SettingMenuItem(
                        onTap: () {
                          Navigator.of(context).push(Transitions(transitionType: TransitionType.fade, curve: Curves.bounceInOut, reverseCurve: Curves.fastLinearToSlowEaseIn, widget: AboutApp()));
                        },
                        title: Languages.of(context)!.labelAboutApp,
                        icon: Icons.info_rounded,
                      ),
                      SettingMenuItem(
                        onTap: () {
                          Navigator.of(context)
                              .push(Transitions(transitionType: TransitionType.fade, curve: Curves.bounceInOut, reverseCurve: Curves.fastLinearToSlowEaseIn, widget: AboutCompanyScreen()));
                        },
                        title: Languages.of(context)!.labelAboutCompany,
                        icon: Icons.store_rounded,
                      ),
                      SettingMenuItem(
                        onTap: () {
                          Navigator.of(context)
                              .push(Transitions(transitionType: TransitionType.fade, curve: Curves.bounceInOut, reverseCurve: Curves.fastLinearToSlowEaseIn, widget: PrivacyPolicyScreen()));
                        },
                        title: Languages.of(context)!.labelPrivacyPolicy,
                        icon: Icons.privacy_tip_rounded,
                      ),
                      SettingMenuItem(
                        onTap: () {
                          Navigator.of(context)
                              .push(Transitions(transitionType: TransitionType.fade, curve: Curves.bounceInOut, reverseCurve: Curves.fastLinearToSlowEaseIn, widget: TermsOfUseScreen()));
                        },
                        title: Languages.of(context)!.labelTermOfUse,
                        icon: Icons.chrome_reader_mode_rounded,
                      ),
                      SettingMenuItem(
                        onTap: () {
                          Navigator.of(context)
                              .push(Transitions(transitionType: TransitionType.fade, curve: Curves.bounceInOut, reverseCurve: Curves.fastLinearToSlowEaseIn, widget: const FeedbackScreen()));
                        },
                        title: Languages.of(context)!.labelFeedbackAndSupport,
                        icon: Icons.edit_location_alt_rounded,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 8),
              Text(
                Languages.of(context)!.labelAppVersion + SharedPreferenceUtil.getString(Constants.appSettingAndroidCustomerVersion),
                style: TextStyle(color: Constants.colorGray, fontSize: 12, fontFamily: Constants.appFont),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingMenuItem extends StatelessWidget {
  final Function()? onTap;
  final String title;
  final IconData icon;

  const SettingMenuItem({Key? key, required this.onTap, required this.title, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: Constants.colorBlack.withOpacity(0.75)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontFamily: Constants.appFont, color: Constants.colorBlack.withOpacity(0.75)),
              ),
            ),
            Icon(Icons.navigate_next, color: Constants.colorBlack.withOpacity(0.75)),
          ],
        ),
      ),
    );
  }
}
