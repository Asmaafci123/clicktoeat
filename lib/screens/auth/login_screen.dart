import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:lottie/lottie.dart';
import 'package:mealup/model/app_setting_model.dart';
import 'package:mealup/model/login_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/auth/forgot_password.dart';
import 'package:mealup/screens/auth/get_phone_number.dart';
import 'package:mealup/screens/auth/registration_screen.dart';
import 'package:mealup/screens/pager/dashboard_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/localization/locale_constant.dart';
import 'package:mealup/utils/widgets/app_lable_widget.dart';
import 'package:mealup/utils/widgets/card_password_textfield.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:mealup/utils/widgets/customs/custom_elevated_button.dart';
import 'package:mealup/utils/widgets/customs/custom_text_field.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isRememberMe = false;
  final bool _passwordVisible = true;

  final _textEmail = TextEditingController();
  final _textPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  //bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken).isEmpty) {
      getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
    }
    callAppSettingData();
  }

  @override
  void dispose() {
    super.dispose();
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
          resizeToAvoidBottomInset: true,
          primary: true,
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(Transitions(transitionType: TransitionType.slideUp, curve: Curves.bounceInOut, reverseCurve: Curves.fastLinearToSlowEaseIn, widget: DashboardScreen(0)));
                        },
                        child: Text(
                          Languages.of(context)!.labelSkipNow,
                          style: TextStyle(
                            color: Constants.colorBlack,
                            fontSize: 14,
                            fontFamily: Constants.appFont,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: LottieBuilder.asset(
                        'animations/login.json',
                        frameRate: FrameRate(900),
                        height: 325,
                      ),
                    ),
                    Text(
                      'Login',
                      style: TextStyle(
                        color: const Color(0xFF03041D),
                        fontSize: 44.0,
                        fontFamily: Constants.appFontBold,
                        height: 0.9,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Welcome back you\'ve been missed!',
                      style: TextStyle(
                        color: Color(0xFF03041D),
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 20),
                    AppLabelWidget(
                      title: Languages.of(context)!.labelEmail,
                    ),
                    CustomTextField(
                      onFieldSubmitted: (v) {
                        FocusScope.of(context).nextFocus();
                      },
                      textInputAction: TextInputAction.next,
                      hintText: Languages.of(context)!.labelEnterYourEmailID,
                      textInputType: TextInputType.emailAddress,
                      textEditingController: _textEmail,
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 10),
                    AppLabelWidget(
                      title: Languages.of(context)!.labelPassword,
                    ),
                    CardPasswordTextFieldWidget(
                        textEditingController: _textPassword, validator: validatePassword, hintText: Languages.of(context)!.labelEnterYourPassword, isPasswordVisible: _passwordVisible),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              Transitions(
                                transitionType: TransitionType.fade,
                                curve: Curves.bounceInOut,
                                reverseCurve: Curves.bounceOut,
                                widget: const ForgotPassword(),
                              ),
                            );
                          },
                          child: Text(
                            Languages.of(context)!.labelForgotPassword,
                            style: TextStyle(
                              fontFamily: Constants.appFont,
                              fontSize: 16,
                              color: Constants.colorBlack,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: CustomElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Constants.checkNetwork().whenComplete(() => callUserLogin());
                              }
                            },
                            buttonLabel: Languages.of(context)!.labelLogin,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          Transitions(
                            transitionType: TransitionType.fade,
                            curve: Curves.bounceInOut,
                            reverseCurve: Curves.bounceOut,
                            widget: const RegistrationScreen(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Languages.of(context)!.labelDoNotHaveAccount,
                            style: TextStyle(
                              fontFamily: Constants.appFont,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            Languages.of(context)!.labelCreateNow,
                            style: TextStyle(fontFamily: Constants.appFontBold, fontSize: 16, color: Constants.colorTheme),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? validateEmail(String? value) {
    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern as String);
    if (value!.isEmpty) {
      return Languages.of(context)!.labelEmailRequired;
    } else if (!regex.hasMatch(value)) {
      return Languages.of(context)!.labelEnterValidEmail;
    } else {
      return null;
    }
  }

  String? validatePassword(String? value) {
    Pattern pattern = r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    RegExp regex = RegExp(pattern as String);
    if (value!.isEmpty) {
      return Languages.of(context)!.labelPasswordRequired;
    } else if (!regex.hasMatch(value)) {
      return Languages.of(context)!.labelPasswordValidation;
    } else {
      return null;
    }
  }

  getOneSingleToken(String appId) async {
    // String push_token = '';
    // String userId = '';
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
    // var status = await OneSignal.shared.getDeviceState();
    await OneSignal.shared.getDeviceState().then((value) => SharedPreferenceUtil.putString(Constants.appPushOneSingleToken, value!.userId!));
    // var pushToken = await status.subscriptionStatus.pushToken;
    // userId = status.userId;
    // print("pushToken1:$userId");
    // print("pushToken123456:$pushToken");
    // push_token = pushToken;
    //  userId == null ? userId = '' : userId = status.userId;
    //  SharedPreferenceUtil.putString(Constants.appPushOneSingleToken, userId);

    /* if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken).isEmpty) {
      getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
    }*/
  }

  Future<BaseModel<LoginModel>> callUserLogin() async {
    LoginModel response;
    debugPrint('Call user login');
    try {
      Constants.onLoading(context);
      Map<String, String> body = {
        'email_id': _textEmail.text,
        'password': _textPassword.text,
        'provider': 'LOCAL',
        'device_token': SharedPreferenceUtil.getString(Constants.appPushOneSingleToken),
      };
      var rawResponse = await RestClient(RetroApi().dioData()).userLogin(body);
      print(rawResponse);
      response = rawResponse;
      Constants.hideDialog(context);
      debugPrint(response.success!.toString());
      if (response.success!) {
        if (response.data!.isVerified == 1) {
          Constants.toastMessage(Languages.of(context)!.labelLoginSuccessfully);
          response.data!.otp == null ? SharedPreferenceUtil.putInt(Constants.loginOTP, 0) : SharedPreferenceUtil.putInt(Constants.loginOTP, response.data!.otp);
          SharedPreferenceUtil.putString(Constants.loginEmail, response.data!.emailId!);
          SharedPreferenceUtil.putString(Constants.loginPhone, response.data!.phone!);
          if (response.data!.phoneCode != null) {
            SharedPreferenceUtil.putString(Constants.loginPhoneCode, response.data!.phoneCode!);
          } else {
            SharedPreferenceUtil.putString(Constants.loginPhoneCode, '+91');
          }
          SharedPreferenceUtil.putString(Constants.loginUserId, response.data!.id.toString());
          SharedPreferenceUtil.putString(Constants.headerToken, response.data!.token!);
          SharedPreferenceUtil.putString(Constants.loginUserImage, response.data!.image!);
          SharedPreferenceUtil.putString(Constants.loginUserName, response.data!.name!);

          response.data!.ifscCode == null ? SharedPreferenceUtil.putString(Constants.bankIFSC, '') : SharedPreferenceUtil.putString(Constants.bankIFSC, response.data!.ifscCode!);
          response.data!.micrCode == null ? SharedPreferenceUtil.putString(Constants.bankMICR, '') : SharedPreferenceUtil.putString(Constants.bankMICR, response.data!.micrCode!);
          response.data!.accountName == null ? SharedPreferenceUtil.putString(Constants.bankACCName, '') : SharedPreferenceUtil.putString(Constants.bankACCName, response.data!.accountName!);
          response.data!.accountNumber == null ? SharedPreferenceUtil.putString(Constants.bankACCNumber, '') : SharedPreferenceUtil.putString(Constants.bankACCNumber, response.data!.accountNumber!);

          SharedPreferenceUtil.putBool(Constants.isLoggedIn, true);

          String languageCode = '';
          if (response.data!.language == 'english') {
            languageCode = 'en';
          } else if (response.data!.language == 'arabic') {
            languageCode = 'ar';
          } else {
            languageCode = 'es';
          }

          changeLanguage(context, languageCode);

          Navigator.of(context).pushReplacement(
            Transitions(
              transitionType: TransitionType.slideUp,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: DashboardScreen(0),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            Transitions(
              transitionType: TransitionType.slideUp,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: const GetPhoneNumber(),
            ),
          );
        }
      } else {
        Constants.toastMessage(Languages.of(context)!.labelEmailPasswordWrong);
      }
    } catch (error) {
      Constants.hideDialog(context);
      debugPrint('Error: $error');
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

/*  void callUserLogin() {


    Map<String, String> body = {
      'email_id': _textEmail.text,
      'password': _textPassword.text,
      'provider': 'LOCAL',
      'device_token': SharedPreferenceUtil.getString(Constants.appPushOneSingleToken),
    };
    RestClient(RetroApi().dioData()).userLogin(body).then((response) {
      Constants.hideDialog(context);
      print(response.success);
      if (response.success!) {
        Constants.toastMessage(Languages.of(context)!.labelLoginSuccessfully);
        response.data!.otp == null
            ? SharedPreferenceUtil.putInt(Constants.loginOTP, 0)
            : SharedPreferenceUtil.putInt(Constants.loginOTP, response.data!.otp);
        SharedPreferenceUtil.putString(Constants.loginEmail, response.data!.emailId!);
        SharedPreferenceUtil.putString(Constants.loginPhone, response.data!.phone!);
        SharedPreferenceUtil.putString(Constants.loginUserId, response.data!.id.toString());
        SharedPreferenceUtil.putString(Constants.headerToken, response.data!.token!);
        SharedPreferenceUtil.putString(Constants.loginUserImage, response.data!.image!);
        SharedPreferenceUtil.putString(Constants.loginUserName, response.data!.name!);

        response.data!.ifscCode == null
            ? SharedPreferenceUtil.putString(Constants.bankIFSC, '')
            : SharedPreferenceUtil.putString(Constants.bankIFSC, response.data!.ifscCode!);
        response.data!.micrCode == null
            ? SharedPreferenceUtil.putString(Constants.bankMICR, '')
            : SharedPreferenceUtil.putString(Constants.bankMICR, response.data!.micrCode!);
        response.data!.accountName == null
            ? SharedPreferenceUtil.putString(Constants.bankACCName, '')
            : SharedPreferenceUtil.putString(Constants.bankACCName, response.data!.accountName!);
        response.data!.accountNumber == null
            ? SharedPreferenceUtil.putString(Constants.bankACCNumber, '')
            : SharedPreferenceUtil.putString(
                Constants.bankACCNumber, response.data!.accountNumber!);

        SharedPreferenceUtil.putBool(Constants.isLoggedIn, true);

        String languageCode = '';
        if (response.data!.language == 'english') {
          languageCode = 'en';
        } else {
          languageCode = 'es';
        }

        changeLanguage(context, languageCode);

        Navigator.of(context).pushReplacement(
          Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: DashboardScreen(0),
          ),
        );
      } else {
        Constants.toastMessage(Languages.of(context)!.labelEmailPasswordWrong);
      }
    }).catchError((Object obj) {
      Constants.hideDialog(context);
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response!;
          var msg = res.statusMessage;
          var responseCode = res.statusCode;
          if (responseCode == 401) {
            Constants.toastMessage(Languages.of(context)!.labelEmailPasswordWrong);
            print(responseCode);
            print(res.statusMessage);
          } else if (responseCode == 422) {
            print("code:$responseCode");
            print("msg:$msg");
            Constants.toastMessage("code:$responseCode");
          } else if (responseCode == 500) {
            print("code:$responseCode");
            print("msg:$msg");
            Constants.toastMessage(Languages.of(context)!.labelInternalServerError);
          }
          break;
        default:
      }
    });
  }*/
}
