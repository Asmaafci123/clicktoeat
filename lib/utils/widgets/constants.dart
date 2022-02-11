import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../localization/language/languages.dart';

class Constants {
  /*map key*/
  static const String androidKey = 'AIzaSyCKoxl76hNVJECAryu0cunruhjLL9UU3c4';
  static const String iosKey = 'AIzaSyAiYvkahj_Z7iH94mMUP01eBTOyr4egU7Q';

  static Color colorBlack = const Color(0xFF090E21);
  static Color colorGray = const Color(0xFFCDCDD2);
  static Color colorLike = const Color(0xFFff6060);
  static Color colorLikeLight = const Color(0xFFe2bcbc);
  static Color colorTheme = const Color(0xFFBC2030);
  static Color colorYellow = const Color(0xFFFFC700);
  static Color colorOrderPending = const Color(0xFFF4AE36);
  static Color colorOrderPickup = const Color(0xFFd1286b);
  static Color colorBackground = const Color(0xFFFAFAFA);
  static Color colorRate = const Color(0xFFffc107);
  static Color colorBlue = const Color(0xFF1492e6);
  static Color colorHint = const Color(0xFFb9b9b9);
  static Color colorWhite = const Color(0xFFFFFFFF);

  static String appFont = 'Proxima';
  static String appFontBold = 'ProximaBold';

  static String registrationOTP = 'regOTP';
  static String registrationEmail = 'regEmail';
  static String registrationPhone = 'regPhone';
  static String registrationUserId = 'userId';

  static String bankIFSC = 'bank_IFSC';
  static String bankMICR = 'bank_MICR';
  static String bankACCName = 'bank_ACC_Name';
  static String bankACCNumber = 'bank_ACC_Number';

  static String loginOTP = 'loginOTP';
  static String loginEmail = 'loginEmail';
  static String loginPhone = 'loginPhone';
  static String loginPhoneCode = 'loginPhoneCode';
  static String loginUserId = 'loggeduserId';
  static String loginUserImage = 'loggedImage';
  static String loginUserName = 'loggedName';

/*  static String loginLanguage = 'loginLanguage';
  static String loginIFSC_CODE = 'loginIFSC_CODE';
  static String loginMICR_CODE = 'loginMICR_CODE';
  static String loginBankAccountName = 'loginBankAccountName';
  static String loginBankAccountNumber = 'loginBankAccountNumber';*/

  static String headerToken = 'headerToken';
  static String isLoggedIn = 'isLoggedIn';
  static String stripePaymentToken = 'stripePaymentToken';

  static String selectedAddress = 'selectedAddress';
  static String selectedAddressId = 'selectedAddressId';
  static String recentSearch = 'recentSearch';

  static String appSettingCurrency = 'appSettingCurrency';
  static String appSettingCurrencySymbol = 'appSettingCurrencySymbol';
  static String appSettingPrivacyPolicy = 'appSettingPrivacyPolicy';
  static String appSettingTerm = 'appSettingTerm';
  static String appAboutCompany = 'appAboutCompany';
  static String appSettingHelp = 'appSettingHelp';
  static String appSettingAboutUs = 'appSettingAboutUs';
  static String appSettingDriverAutoRefresh = 'appSettingDriverAutoRefresh';
  static String appSettingBusinessAvailability = 'appSettingBusiness_availability';
  static String appSettingBusinessMessage = 'appSettingBusiness_message';
  static String appSettingCustomerAppId = 'appSettingCustomerAppId';
  static String appSettingAndroidCustomerVersion = 'appSetting_android_customer_version';
  static String appSettingIsPickup = 'appSetting_isPickup';
  static String appPushOneSingleToken = 'push_oneSingleToken';

  static String previousLat = 'previousLat';
  static String previousLng = 'previousLng';
  static String cartCount = 'cartCount';
  static int cartCountInt = 0;

  // payment Setting
  static String appPaymentWallet = 'appPaymentWallet';
  static String appPaymentCOD = 'appPaymentCOD';
  static String appPaymentStripe = 'appPaymentStripe';
  static String appPaymentRazorPay = 'appPaymentRozerPay';
  static String appPaymentPaypal = 'appPaymentPaypal';
  static String appStripePublishKey = 'appStripePublishKey';
  static String appStripeSecretKey = 'appStripeSecretKey';
  static String appPaypalProduction = 'appPaypalProducation';
  static String appPaypalClientId = 'appPaypal_client_id';
  static String appPaypalSecretKey = 'appPaypal_secret_key';
  static String appPaypalSendBox = 'appPaypalSendbox';
  static String appRazorpayPublishKey = 'appRozerpayPublishKey';

  static Future<bool> checkNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      Constants.toastMessage("No Internet Connection");
      return false;
    }
  }

  static var kAppLabelWidget = TextStyle(fontWeight: FontWeight.normal, fontSize: 16.0, fontFamily: Constants.appFont, color: const Color(0xFF03041D));

  static var kTextFieldInputDecoration = InputDecoration(
    hintStyle: TextStyle(color: Constants.colorHint),
    errorStyle: TextStyle(fontFamily: Constants.appFont, color: Colors.red),
    filled: true,
    fillColor: Constants.colorWhite,
    contentPadding: const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0, right: 14),
    errorMaxLines: 2,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(width: 0.5, color: Colors.grey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(width: 0.5, color: Colors.grey),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(width: 0.5, color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(width: 0.5, color: Colors.grey),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(width: 0.5, color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(width: 1, color: Colors.red),
    ),
  );

  static toastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.black54, textColor: Constants.colorWhite, fontSize: 16.0);
  }

  static onLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Text(Languages.of(context)!.labelPleaseWait),
              ],
            ),
          ),
        );
      },
    );
  }

  static hideDialog(BuildContext context) {
    Navigator.pop(context);
  }
}
