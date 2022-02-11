import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/pager/dashboard_screen.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:simple_shadow/simple_shadow.dart';

class GeneralHomeScreen extends StatelessWidget {
  const GeneralHomeScreen({Key? key}) : super(key: key);

  static const List<String> _moduleNames = [
    'Food',
    'Grocery',
    'Medicine',
    'Catering',
    'Cylinder',
    'Vegetables',
  ];

  static const List<String> _moduleIcons = [
    'ic_food_icon.svg',
    'ic_grocery_icon.svg',
    'ic_medicine_icon.svg',
    'ic_catering_icon.svg',
    'ic_cylinder_icon.svg',
    'ic_vegetable_icon.svg',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/backgrounds/ic_general_background.png'),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
        child: Container(
          decoration:
              BoxDecoration(color: const Color(0xFFF2F2F4).withOpacity(0.94)),
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 220.w,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        runSpacing: 5.w,
                        spacing: 5.w,
                        children: _moduleNames
                            .map(
                              (name) => Text(
                                name,
                                style: TextStyle(
                                    color: Constants.colorTheme,
                                    fontFamily: Constants.appFontBold,
                                    fontSize: 16.sp),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: 260.w,
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 22.w,
                          crossAxisSpacing: 22.w),
                      itemCount: _moduleNames.length,
                      itemBuilder: (_, index) {
                        return GestureDetector(
                          onTap: () {
                            if (index == 0) {
                              Navigator.push(
                                context,
                                Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.easeInOut,
                                  duration: const Duration(milliseconds: 1000),
                                  reverseCurve: Curves.easeInOut,
                                  widget: DashboardScreen(0),
                                ),
                              );
                            } /*else if (index == 3) {
                              Navigator.push(
                                context,
                                Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.easeInOut,
                                  duration: const Duration(milliseconds: 1000),
                                  reverseCurve: Curves.easeInOut,
                                  widget: DashboardScreen(3),
                                ),
                              );
                            }*/
                            else {
                              Constants.toastMessage(
                                  'This feature is currently unavailable. We currently just have Food Delivery setup!');
                            }
                          },
                          child: SimpleShadow(
                            opacity: 0.8,
                            color: Colors.black12,
                            offset: const Offset(0, 0),
                            sigma: 10,
                            child: Container(
                              width: 72.w,
                              height: 72.w,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r)),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/svgs/${_moduleIcons[index]}',
                                    height: 36.w,
                                    width: 36.w,
                                    color: Constants.colorTheme,
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    _moduleNames[index],
                                    style: TextStyle(
                                        color: Constants.colorTheme,
                                        fontFamily: Constants.appFontBold,
                                        fontSize: 12.sp),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 22.h),
                  Text(
                    'All just a click away'.toUpperCase(),
                    style: TextStyle(
                        color: Constants.colorBlack,
                        fontFamily: Constants.appFontBold,
                        fontSize: 16.sp),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
