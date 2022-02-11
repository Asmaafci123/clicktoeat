import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/auth/login_screen.dart';
import 'package:mealup/screens/wallet/wallet_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:share/share.dart';
import 'package:simple_shadow/simple_shadow.dart';

import '../order_history_screen.dart';
import '../preferences/favorites_screen.dart';
import '../preferences/setting_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    if (!SharedPreferenceUtil.getBool(Constants.isLoggedIn)) {
      Future.delayed(
        Duration.zero,
        () => Navigator.of(context).pushAndRemoveUntil(
            Transitions(
              transitionType: TransitionType.fade,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: const LoginScreen(),
            ),
            (Route<dynamic> route) => false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/ic_profile_background.png'), alignment: Alignment.topCenter),
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
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          primary: false,
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              const Spacer(),
              Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 63),
                      SimpleShadow(
                        opacity: 0.6,
                        color: Colors.black12,
                        offset: const Offset(0, 3),
                        sigma: 10,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20.0),
                          margin: const EdgeInsets.symmetric(horizontal: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 63),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  SharedPreferenceUtil.getString(Constants.loginUserName).toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontFamily: Constants.appFontBold, fontWeight: FontWeight.bold, fontSize: 34, height: 1),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '${SharedPreferenceUtil.getString(Constants.loginPhoneCode)} ${SharedPreferenceUtil.getString(Constants.loginPhone)}',
                                  style: TextStyle(fontFamily: Constants.appFont, fontSize: 16, color: Constants.colorBlack.withOpacity(0.57)),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Divider(
                                color: Constants.colorGray,
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(
                                  'Content',
                                  style: TextStyle(
                                    color: Constants.colorGray,
                                    fontSize: 16.0,
                                    fontFamily: Constants.appFont,
                                    height: 0.9,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              AccountMenuItem(
                                icon: Icons.favorite_rounded,
                                title: Languages.of(context)!.labelYourFavorites,
                                onTap: () {
                                  Navigator.of(context)
                                      .push(Transitions(transitionType: TransitionType.fade, curve: Curves.bounceInOut, reverseCurve: Curves.fastLinearToSlowEaseIn, widget: const FavoritesScreen()));
                                },
                              ),
                              AccountMenuItem(
                                icon: Icons.menu_book_rounded,
                                title: Languages.of(context)!.labelOrderHistory,
                                onTap: () {
                                  Navigator.of(context).push(Transitions(
                                      transitionType: TransitionType.fade,
                                      curve: Curves.bounceInOut,
                                      reverseCurve: Curves.fastLinearToSlowEaseIn,
                                      widget: const OrderHistoryScreen(
                                        isFromProfile: true,
                                      )));
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(
                                  'Preferences',
                                  style: TextStyle(
                                    color: Constants.colorGray,
                                    fontSize: 16.0,
                                    fontFamily: Constants.appFont,
                                    height: 0.9,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Visibility(
                                visible: SharedPreferenceUtil.getString(Constants.appPaymentWallet) == '1' ? true : false,
                                child: AccountMenuItem(
                                  icon: Icons.account_balance_wallet_rounded,
                                  title: Languages.of(context)!.walletSetting,
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(Transitions(transitionType: TransitionType.slideUp, curve: Curves.bounceInOut, reverseCurve: Curves.fastLinearToSlowEaseIn, widget: WalletScreen()));
                                  },
                                ),
                              ),
                              AccountMenuItem(
                                icon: Icons.settings_suggest_rounded,
                                title: Languages.of(context)!.screenSetting,
                                onTap: () {
                                  Navigator.of(context)
                                      .push(Transitions(transitionType: TransitionType.fade, curve: Curves.bounceInOut, reverseCurve: Curves.bounceOut, widget: const SettingScreen()));
                                },
                              ),
                              AccountMenuItem(
                                icon: Icons.share_rounded,
                                title: Languages.of(context)!.labelShareWithFriends,
                                onTap: () {
                                  Share.share("https://play.google.com/store/apps/details?id=app.saasmonsk.mealup");
                                  // share();
                                },
                              ),
                              AccountMenuItem(
                                icon: Icons.logout_rounded,
                                title: Languages.of(context)!.labelLogout,
                                isLogout: true,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(Languages.of(context)!.labelConfirmLogout),
                                        content: Text(Languages.of(context)!.labelAreYouSureLogout),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text(
                                              Languages.of(context)!.labelYES,
                                              style: TextStyle(color: Constants.colorBlack),
                                            ),
                                            onPressed: () {
                                              SharedPreferenceUtil.putBool(Constants.isLoggedIn, false);
                                              SharedPreferenceUtil.clear();
                                              Navigator.of(context).pushAndRemoveUntil(
                                                  Transitions(
                                                    transitionType: TransitionType.fade,
                                                    curve: Curves.bounceInOut,
                                                    reverseCurve: Curves.fastLinearToSlowEaseIn,
                                                    widget: const LoginScreen(),
                                                  ),
                                                  (Route<dynamic> route) => false);
                                            },
                                          ),
                                          TextButton(
                                            child: Text(
                                              Languages.of(context)!.labelNO,
                                              style: TextStyle(color: Constants.colorBlack),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: CircleAvatar(
                      radius: 63,
                      backgroundColor: Constants.colorGray,
                      child: ClipOval(
                        child: SizedBox(
                          width: 120,
                          height: 120,
                          child: CachedNetworkImage(
                            imageUrl: SharedPreferenceUtil.getString(Constants.loginUserImage),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountMenuItem extends StatelessWidget {
  final Function() onTap;
  final String title;
  final bool isLogout;
  final IconData icon;

  const AccountMenuItem({Key? key, required this.onTap, required this.icon, required this.title, this.isLogout = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: isLogout ? Colors.redAccent : Constants.colorBlack.withOpacity(0.7)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: Constants.appFont,
                  color: isLogout ? Colors.redAccent : Constants.colorBlack.withOpacity(0.7),
                ),
              ),
            ),
            if (!isLogout) Icon(Icons.navigate_next, color: Constants.colorBlack.withOpacity(0.7))
          ],
        ),
      ),
    );
  }
}
