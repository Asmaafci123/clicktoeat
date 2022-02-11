// ignore_for_file: non_constant_identifier_names

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mealup/model/cart_model.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/auth/login_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:scoped_model/scoped_model.dart';

import 'cart_screen.dart';
import 'explore_screen.dart';
import 'home_screens/CateringHomeScreen.dart';
import 'home_screens/food_home_screen.dart';
import 'profile_screen.dart';

// ignore: must_be_immutable
class DashboardScreen extends StatefulWidget {
  int? _currentIndex;
  int? savePrevIndex;

  DashboardScreen(_currentIndex, {Key? key}) : super(key: key) {
    this._currentIndex = _currentIndex;
  }

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  final List<Widget> _children = [
    const FoodHomeScreen(),
    const ExploreScreen(),
    const CartScreen(),
    const ProfileScreen()
  ];

  // ignore: missing_return
  Future<bool> _onWillPop() {
    Future<bool> value = Future.value(false);
    setState(
      () {
        if (widget._currentIndex != 0) {
          /*if (widget._currentIndex == widget.savePrevIndex) {
          value  = Future.value(false);
          widget._currentIndex =  widget._currentIndex! - 1;
          setState(() {});
        } else if (widget.savePrevIndex != null) {
          value  = Future.value(false);
          widget._currentIndex = widget.savePrevIndex;
          setState(() {});
        } else {*/
          value = Future.value(false);
          widget._currentIndex = 0;
          setState(() {});
          // }
        } else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                title: Text(Languages.of(context)!.labelConfirmExit),
                content: Text(Languages.of(context)!.labelAreYouSureExit),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      Languages.of(context)!.labelYES,
                      style: const TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      value = Future.value(false);
                      SystemNavigator.pop();
                    },
                  ),
                  TextButton(
                    child: Text(
                      Languages.of(context)!.labelNO,
                      style: const TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      value = Future.value(true);
                    },
                  )
                ],
              );
            },
          );
        }
      },
    );
    return value;
  }

  @override
  Widget build(BuildContext context) {
    dynamic screenWidth = MediaQuery.of(context).size.width;
    dynamic screenHeight = MediaQuery.of(context).size.height;

    ScreenUtil.init(
        BoxConstraints(maxWidth: screenWidth, maxHeight: screenHeight),
        designSize: const Size(360, 690),
        orientation: Orientation.portrait);

    return Scaffold(
        body: _children[widget._currentIndex!],
        bottomNavigationBar: /*widget._currentIndex == 0
          ? */
            BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Constants.colorWhite,
          selectedItemColor: Constants.colorTheme,
          unselectedItemColor: const Color(0xFF403F4C),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          currentIndex: widget._currentIndex!,
          onTap: (value) {
            print(value);
            setState(() {
              widget.savePrevIndex = widget._currentIndex;
              widget._currentIndex = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 5.h),
                child: const Icon(
                  Icons.home_rounded,
                  color: Color(0xFF403F4C),
                ),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 5.h),
                child: Icon(
                  Icons.home_rounded,
                  color: Constants.colorTheme,
                ),
              ),
              label: Languages.of(context)!.labelHome,
            ),
            BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 5.h),
                  child: const Icon(
                    Icons.explore_rounded,
                    color: Color(0xFF403F4C),
                  ),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 5.h),
                  child: Icon(
                    Icons.explore_rounded,
                    color: Constants.colorTheme,
                  ),
                ),
                label: Languages.of(context)!.labelExplore),
            BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 5.h),
                  child: Badge(
                    badgeContent: Text(
                      ScopedModel.of<CartModel>(context, rebuildOnChange: true)
                          .total
                          .toString(),
                      style: TextStyle(color: Colors.white, fontSize: 10.sp),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_rounded,
                      color: Color(0xFF403F4C),
                    ),
                  ),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 5.h),
                  child: Badge(
                    badgeContent: Text(
                      ScopedModel.of<CartModel>(context, rebuildOnChange: true)
                          .total
                          .toString(),
                      style: TextStyle(color: Colors.white, fontSize: 10.sp),
                    ),
                    child: Icon(
                      Icons.shopping_cart_rounded,
                      color: Constants.colorTheme,
                    ),
                  ),
                ),
                label: Languages.of(context)!.labelCart),
            BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 5.h),
                  child: Container(
                    width: 25.w,
                    height: 25.w,
                    decoration: BoxDecoration(
                      color: const Color(0xfffbfaf8),
                      image: DecorationImage(
                        image: NetworkImage(SharedPreferenceUtil.getString(
                            Constants.loginUserImage)),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(50.r)),
                      border: Border.all(
                        color: const Color(0xFF403F4C),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 5.h),
                  child: Container(
                    width: 25.w,
                    height: 25.w,
                    decoration: BoxDecoration(
                      color: const Color(0xfffbfaf8),
                      image: DecorationImage(
                        image: NetworkImage(SharedPreferenceUtil.getString(
                            Constants.loginUserImage)),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(50.r)),
                      border: Border.all(
                        color: Constants.colorTheme,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                label: Languages.of(context)!.labelProfile),
          ],
        )
        //: Catering(),
        );
  }

  /*Catering() {
    if (SharedPreferenceUtil.getBool(Constants.isLoggedIn) == true) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => CateringHomeScreen()));
      });
    } else {
      if (!SharedPreferenceUtil.getBool(Constants.isLoggedIn)) {
        Future.delayed(
          const Duration(seconds: 0),
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
  }*/
}
