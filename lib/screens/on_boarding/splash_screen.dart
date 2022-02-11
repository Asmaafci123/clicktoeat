import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mealup/model/app_setting_model.dart';
import 'package:mealup/model/cart_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/pager/general_home_screen.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:mealup/utils/widgets/database_helper.dart';
import 'package:mealup/utils/widgets/preference_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'first_intro_screen.dart';

final dbHelper = DatabaseHelper.instance;

class SplashScreen extends StatefulWidget {
  final CartModel? model;

  const SplashScreen({Key? key, this.model}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _queryFirst(context, widget.model);
    Constants.checkNetwork().whenComplete(() => callAppSettingData());
    // print('ok =======2');
    changeRoute();
  }

  Future changeRoute() async {
    await Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        Transitions(
          transitionType: TransitionType.fade,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 1000),
          reverseCurve: Curves.easeInOut,
          widget: PreferenceUtils.isIntroDone("isIntroDone") ? const GeneralHomeScreen() : const FirstIntroScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFBC2030),
            Color(0xFF7A151F),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            const Spacer(flex: 2),
            Center(
              child: Hero(
                tag: 'App_logo',
                child: Image.asset(
                  'assets/ic_logo_white.png',
                  width: 200,
                ),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/ic_splash_bottom.png',
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<BaseModel<AppSettingModel>> callAppSettingData() async {
    AppSettingModel response;
    try {
      response = await RestClient(RetroApi().dioData()).setting();

      if (response.success!) {
        if (response.data!.currencySymbol != null) {
          SharedPreferenceUtil.putString(Constants.appSettingCurrencySymbol, response.data!.currencySymbol!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingCurrencySymbol, '\$');
        }
        if (response.data!.currency != null) {
          SharedPreferenceUtil.putString(Constants.appSettingCurrency, response.data!.currency!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingCurrency, 'USD');
        }
        if (response.data!.aboutUs != null) {
          SharedPreferenceUtil.putString(Constants.appSettingAboutUs, response.data!.aboutUs!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingAboutUs, '');
        }
        if (response.data!.aboutUs != null) {
          SharedPreferenceUtil.putString(Constants.appSettingAboutUs, response.data!.aboutUs!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingAboutUs, '');
        }

        if (response.data!.termsAndCondition != null) {
          SharedPreferenceUtil.putString(Constants.appSettingTerm, response.data!.termsAndCondition!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingTerm, '');
        }

        if (response.data!.help != null) {
          SharedPreferenceUtil.putString(Constants.appSettingHelp, response.data!.help!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingHelp, '');
        }

        if (response.data!.privacyPolicy != null) {
          SharedPreferenceUtil.putString(Constants.appSettingPrivacyPolicy, response.data!.privacyPolicy!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingPrivacyPolicy, '');
        }

        if (response.data!.companyDetails != null) {
          SharedPreferenceUtil.putString(Constants.appAboutCompany, response.data!.companyDetails!);
        } else {
          SharedPreferenceUtil.putString(Constants.appAboutCompany, '');
        }
        if (response.data!.driverAutoRefresh != null) {
          SharedPreferenceUtil.putInt(Constants.appSettingDriverAutoRefresh, response.data!.driverAutoRefresh);
        } else {
          SharedPreferenceUtil.putInt(Constants.appSettingDriverAutoRefresh, 0);
        }

        if (response.data!.isPickup != null) {
          SharedPreferenceUtil.putInt(Constants.appSettingIsPickup, response.data!.isPickup);
        } else {
          SharedPreferenceUtil.putInt(Constants.appSettingIsPickup, 0);
        }

        if (response.data!.customerAppId != null) {
          SharedPreferenceUtil.putString(Constants.appSettingCustomerAppId, response.data!.customerAppId!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingCustomerAppId, '');
        }

        if (response.data!.androidCustomerVersion != null) {
          SharedPreferenceUtil.putString(Constants.appSettingAndroidCustomerVersion, response.data!.androidCustomerVersion!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingAndroidCustomerVersion, '');
        }

        SharedPreferenceUtil.putInt(Constants.appSettingBusinessAvailability, response.data!.businessAvailability);

        if (SharedPreferenceUtil.getInt(Constants.appSettingBusinessAvailability) == 0) {
          SharedPreferenceUtil.putString(Constants.appSettingBusinessMessage, response.data!.message!);
        }

        if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken).isEmpty) {
          getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
        }
      } else {
        Constants.toastMessage('Error while get app setting data.');
      }
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  getOneSingleToken(String appId) async {
    // String push_token = '';
    String? userId = '';
    // OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);

    /*var settings = {
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
    userId = status!.userId;
    // print("pushToken123456:$pushToken");
    // push_token = pushToken-;

    if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken).isEmpty) {
      //getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
    } else {
      SharedPreferenceUtil.putString(Constants.appPushOneSingleToken, userId!);
    }
  }
}

void _queryFirst(BuildContext context, CartModel? model) async {
  final allRows = await dbHelper.queryAllRows();
  for (int i = 0; i < allRows.length; i++) {
    model!.addProduct(Product(
      id: allRows[i]['pro_id'],
      restaurantsName: allRows[i]['restName'],
      title: allRows[i]['pro_name'],
      imgUrl: allRows[i]['pro_image'],
      price: double.parse(allRows[i]['pro_price']),
      qty: allRows[i]['pro_qty'],
      restaurantsId: allRows[i]['restId'],
      restaurantImage: allRows[i]['restImage'],
      foodCustomization: allRows[i]['pro_customization'],
      isRepeatCustomization: allRows[i]['isRepeatCustomization'],
      tempPrice: double.parse(allRows[i]['itemTempPrice'].toString()),
      itemQty: allRows[i]['itemQty'],
      isCustomization: allRows[i]['isCustomization'],
    ));
  }
}

// /*new*/
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:mealup/model/app_setting_model.dart';
// import 'package:mealup/model/cart_model.dart';
// import 'package:mealup/retrofit/api_client.dart';
// import 'package:mealup/retrofit/api_header.dart';
// import 'package:mealup/retrofit/base_model.dart';
// import 'package:mealup/retrofit/server_error.dart';
// // import 'package:mealup/network_api/Retro_Api.dart';
// // import 'package:mealup/network_api/api_client.dart';
// // import 'package:mealup/screens/login_screen.dart';
// import 'package:mealup/utils/custom_shared_preference_util.dart';
// import 'package:mealup/utils/constants.dart';
// import 'package:mealup/utils/database_helper.dart';
// import 'package:mealup/utils/localization/language/languages.dart';
// import 'package:mealup/utils/preference_utils.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
// // import 'package:progress_dialog/progress_dialog.dart';
// import 'package:dio/dio.dart';
//
// import 'pager/dashboard_screen.dart';
// import 'on_boarding/first_intro_screen.dart';
// // import 'dashboard_screen.dart';
// // import 'first_intro_screen.dart';
//
// final dbHelper = DatabaseHelper.instance;
//
// class SplashScreen extends StatefulWidget {
//   final CartModel model;
//
//   const SplashScreen({required this.model});
//
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//
//   void initState() {
//     super.initState();
//     changeRoute();
//   //  if(this.mounted){
//     //  print('ander');
//     //  Timer(
//     //  Duration(seconds: 5),
//           //() =>
//        //   PreferenceUtils.isIntroDone("isIntroDone") ? Navigator.pushReplacementNamed(context, "dashBoard") : Navigator.pushReplacementNamed(context, "on_boarding");
//       //     () => Navigator.pushReplacement(
//       //   this.context,
//       //   MaterialPageRoute(
//       //     builder: (BuildContext context) => PreferenceUtils.isIntroDone("isIntroDone")
//       //         ? DashboardScreen(0)
//       //         : IntroScreen1(),
//       //   ),
//       // ),
//   //  );
//
//    // }
//     _queryFirst(context, widget.model);
//     Constants.checkNetwork().whenComplete(() => callAppSettingData());
//
//   }
//
//   Future changeRoute() async{
//     await Future.delayed(Duration(seconds: 2),(){
//       Navigator.pushReplacement(
//         this.context,
//         MaterialPageRoute(
//           builder: (BuildContext context) => PreferenceUtils.isIntroDone("isIntroDone")
//               ? DashboardScreen(0)
//               : IntroScreen1(),
//         ),
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage('assets/ic_background_image.png'),
//               fit: BoxFit.cover,
//             )),
//         alignment: Alignment.center,
//         child: Hero(
//           tag: 'App_logo',
//           child: Image.asset('assets/ic_logo.png'),
//         ),
//       ),
//       backgroundColor: Constants.colorTheme,
//     );
//   }
//
//     Future<BaseModel<AppSettingModel>> callAppSettingData() async {
//     AppSettingModel response;
//     try {
//       response = await RestClient(RetroApi().dioData()).setting();
//       Constants.hideDialog(context);
//       print(response.success);
//       print('businessAvailability' + response.data!.businessAvailability.toString());
//
//       if (response.success!) {
//         if (response.data!.currencySymbol != null) {
//           SharedPreferenceUtil.putString(
//               Constants.appSettingCurrencySymbol, response.data!.currencySymbol!);
//         } else {
//           SharedPreferenceUtil.putString(Constants.appSettingCurrencySymbol, '\$');
//         }
//         if (response.data!.currency != null) {
//           SharedPreferenceUtil.putString(Constants.appSettingCurrency, response.data!.currency!);
//         } else {
//           SharedPreferenceUtil.putString(Constants.appSettingCurrency, 'USD');
//         }
//         if (response.data!.aboutUs != null) {
//           SharedPreferenceUtil.putString(Constants.appSettingAboutUs, response.data!.aboutUs!);
//         } else {
//           SharedPreferenceUtil.putString(Constants.appSettingAboutUs, '');
//         }
//         if (response.data!.aboutUs != null) {
//           SharedPreferenceUtil.putString(Constants.appSettingAboutUs, response.data!.aboutUs!);
//         } else {
//           SharedPreferenceUtil.putString(Constants.appSettingAboutUs, '');
//         }
//
//         if (response.data!.termsAndCondition != null) {
//           SharedPreferenceUtil.putString(
//               Constants.appSettingTerm, response.data!.termsAndCondition!);
//         } else {
//           SharedPreferenceUtil.putString(Constants.appSettingTerm, '');
//         }
//
//         if (response.data!.help != null) {
//           SharedPreferenceUtil.putString(Constants.appSettingHelp, response.data!.help!);
//         } else {
//           SharedPreferenceUtil.putString(Constants.appSettingHelp, '');
//         }
//
//         if (response.data!.privacyPolicy != null) {
//           SharedPreferenceUtil.putString(
//               Constants.appSettingPrivacyPolicy, response.data!.privacyPolicy!);
//         } else {
//           SharedPreferenceUtil.putString(Constants.appSettingPrivacyPolicy, '');
//         }
//
//         if (response.data!.companyDetails != null) {
//           SharedPreferenceUtil.putString(Constants.appAboutCompany, response.data!.companyDetails!);
//         } else {
//           SharedPreferenceUtil.putString(Constants.appAboutCompany, '');
//         }
//         if (response.data!.driverAutoRefrese != null) {
//           SharedPreferenceUtil.putInt(
//               Constants.appSettingDriverAutoRefresh, response.data!.driverAutoRefrese);
//         } else {
//           SharedPreferenceUtil.putInt(Constants.appSettingDriverAutoRefresh, 0);
//         }
//
//         if (response.data!.isPickup != null) {
//           SharedPreferenceUtil.putInt(Constants.appSettingIsPickup, response.data!.isPickup);
//         } else {
//           SharedPreferenceUtil.putInt(Constants.appSettingIsPickup, 0);
//         }
//
//         if (response.data!.customerAppId != null) {
//           SharedPreferenceUtil.putString(
//               Constants.appSettingCustomerAppId, response.data!.customerAppId!);
//         } else {
//           SharedPreferenceUtil.putString(Constants.appSettingCustomerAppId, '');
//         }
//
//         if (response.data!.androidCustomerVersion != null) {
//           SharedPreferenceUtil.putString(
//               Constants.appSettingAndroidCustomerVersion, response.data!.androidCustomerVersion!);
//         } else {
//           SharedPreferenceUtil.putString(Constants.appSettingAndroidCustomerVersion, '');
//         }
//
//         SharedPreferenceUtil.putInt(
//             Constants.appSettingBusinessAvailability, response.data!.businessAvailability);
//
//         if (SharedPreferenceUtil.getInt(Constants.appSettingBusinessAvailability) == 0) {
//           SharedPreferenceUtil.putString(
//               Constants.appSettingBusinessMessage, response.data!.message!);
//         }
//
//         if (SharedPreferenceUtil
//             .getString(Constants.appPushOneSingleToken)
//             .isEmpty) {
//           getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
//         }
//       } else {
//         Constants.toastMessage('Error while get app setting data.');
//       }
//       print('ok =======4');
//     } catch (error, stacktrace) {
//       print("Exception occurred: $error stackTrace: $stacktrace");
//       return BaseModel()..setException(ServerError.withError(error: error));
//     }
//     return BaseModel()..data = response;
//   }
//
//   getOneSingleToken(String appId) async {
//     // String push_token = '';
//     String? userId = '';
//     // OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);
//
//     /*var settings = {
//       OSiOSSettings.autoPrompt: false,
//       OSiOSSettings.promptBeforeOpeningPushUrl: true
//     };*/
//     OneSignal.shared.consentGranted(true);
//     await OneSignal.shared.setAppId(appId);
//     OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
//     await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
//     OneSignal.shared.promptLocationPermission();
//     // OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
//     var status = await (OneSignal.shared.getDeviceState());
//     // var pushToken = await status.subscriptionStatus.pushToken;
//     userId = status!.userId;
//     print("pushToken1:$userId");
//     // print("pushToken123456:$pushToken");
//     // push_token = pushToken-;
//
//     if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken).isEmpty) {
//       //getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
//     } else {
//       SharedPreferenceUtil.putString(Constants.appPushOneSingleToken, userId!);
//     }
//     print('ok =======5');
//   }
// }
// void _queryFirst(BuildContext context, CartModel model) async {
//   final allRows = await dbHelper.queryAllRows();
//   print('query all rows:');
//   allRows.forEach((row) => print(row));
//   for (int i = 0; i < allRows.length; i++) {
//     model.addProduct(Product(
//       id: allRows[i]['pro_id'],
//       restaurantsName: allRows[i]['restName'],
//       title: allRows[i]['pro_name'],
//       imgUrl: allRows[i]['pro_image'],
//       price: double.parse(allRows[i]['pro_price']),
//       qty: allRows[i]['pro_qty'],
//       restaurantsId: allRows[i]['restId'],
//       restaurantImage: allRows[i]['restImage'],
//       foodCustomization: allRows[i]['pro_customization'],
//       isRepeatCustomization: allRows[i]['isRepeatCustomization'],
//       tempPrice: double.parse(allRows[i]['itemTempPrice'].toString()),
//       itemQty: allRows[i]['itemQty'],
//       isCustomization: allRows[i]['isCustomization'],
//     ));
//   }
// }
