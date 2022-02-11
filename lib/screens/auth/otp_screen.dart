import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:mealup/model/check_opt_model.dart';
import 'package:mealup/model/check_otp_model_for_forgot_password.dart';
import 'package:mealup/model/send_otp_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/auth/login_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/app_lable_widget.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:mealup/utils/widgets/customs/custom_app_bar.dart';
import 'package:mealup/utils/widgets/customs/custom_elevated_button.dart';

import 'change_password_1.dart';

class OTPScreen extends StatefulWidget {
  final bool isFromRegistration;
  final String? emailForOTP;
  final String? phoneNo;

  const OTPScreen({Key? key, required this.isFromRegistration, this.emailForOTP, this.phoneNo}) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController textEditingController1 = TextEditingController();
  TextEditingController textEditingController2 = TextEditingController();
  TextEditingController textEditingController3 = TextEditingController();
  TextEditingController textEditingController4 = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  int _start = 59;
  late Timer _timer;

  int? getOTP;

  @override
  void initState() {
    super.initState();
    startTimer();
    _focusNode.addListener(() {
      log("Has focus: ${_focusNode.hasFocus}");
    });

    getOTP = SharedPreferenceUtil.getInt(Constants.registrationOTP);
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
        oneSec,
        (Timer timer) => setState(() {
              if (_start < 1) {
                timer.cancel();
              } else {
                _start = _start - 1;
              }
            }));
  }

  @override
  Widget build(BuildContext context) {
    dynamic screenWidth = MediaQuery.of(context).size.width;
    dynamic screenHeight = MediaQuery.of(context).size.height;

    ScreenUtil.init(BoxConstraints(maxWidth: screenWidth, maxHeight: screenHeight), designSize: const Size(360, 690), orientation: Orientation.portrait);

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
          appBar: CustomAppBar(title: Languages.of(context)!.labelOTP),
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(30.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: LottieBuilder.asset(
                      'animations/otp.json',
                      frameRate: FrameRate.max,
                      height: 250,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Text(
                    'Verify OTP',
                    style: TextStyle(
                      color: const Color(0xFF03041D),
                      fontSize: 44.0,
                      fontFamily: Constants.appFontBold,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    Languages.of(context)!.labelOTPBottomLine + ' +92${widget.phoneNo}',
                    style: const TextStyle(
                      color: Color(0xFF03041D),
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 20),
                  AppLabelWidget(
                    title: Languages.of(context)!.labelEnterOTP,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OTPTextField(
                        isFirst: true,
                        editingController: textEditingController1,
                        textInputAction: TextInputAction.next,
                        focus: (v) {
                          FocusScope.of(context).nextFocus();
                        },
                      ),
                      OTPTextField(
                        editingController: textEditingController2,
                        textInputAction: TextInputAction.next,
                        focus: (v) {
                          FocusScope.of(context).nextFocus();
                        },
                      ),
                      OTPTextField(
                        editingController: textEditingController3,
                        textInputAction: TextInputAction.next,
                        focus: (v) {
                          FocusScope.of(context).nextFocus();
                        },
                      ),
                      OTPTextField(
                        editingController: textEditingController4,
                        textInputAction: TextInputAction.done,
                        focus: (v) {
                          FocusScope.of(context).dispose();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      Expanded(
                        child: CustomElevatedButton(
                            buttonLabel: Languages.of(context)!.labelVerifyNow,
                            onPressed: () {
                              String one = textEditingController1.text + textEditingController2.text + textEditingController3.text + textEditingController4.text;
                              //int enteredOTP = int.parse(one);
                              log(one);
                              if (one.length == 4) {
                                if (widget.isFromRegistration) {
                                  // if(enteredOTP == getOTP){
                                  //if (one == '0000') {
                                  callVerifyOTP(one);
                                  // }
                                } else {
                                  // if (one == '0000') {
                                  callForgotPasswordVerifyOTP(one);
                                  // }
                                }
                              } else {
                                Constants.toastMessage('Enter OTP');
                              }
                            }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30.0),
                  _start != 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.alarm_on_rounded,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            SizedBox(
                              width: 60,
                              child: Text(
                                '00 : ${_start < 10 ? '0' + _start.toString() : _start}',
                                style: TextStyle(
                                  fontFamily: Constants.appFont,
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Languages.of(context)!.labelDoNotReceiveCode,
                              style: TextStyle(
                                fontFamily: Constants.appFont,
                                fontSize: 14,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                callSendOTP();
                              },
                              child: Text(
                                Languages.of(context)!.labelResendAgain,
                                style: TextStyle(
                                  fontFamily: Constants.appFontBold,
                                  fontSize: 16,
                                  color: Constants.colorTheme,
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<SendOTPModel>> callSendOTP() async {
    SendOTPModel response;
    try {
      Constants.onLoading(context);
      Map<String, String?> body;
      if (widget.isFromRegistration) {
        body = {
          'phone_code': '+92',
          'phone': widget.phoneNo,
          'where': 'register',
        };
      } else {
        body = {
          'phone_code': '+92',
          'phone': widget.phoneNo,
          'where': 'forgot_password',
        };
      }
      response = await RestClient(RetroApi().dioData()).sendOtp(body);
      Constants.hideDialog(context);
      log(response.success.toString());
      if (response.success!) {
        Constants.toastMessage('OTP Sent');

        SharedPreferenceUtil.putString(Constants.loginUserId, response.data!.id.toString());
      } else {
        Constants.toastMessage('Error while sending OTP.');
      }
    } catch (error, stacktrace) {
      setState(() {
        Constants.hideDialog(context);
      });
      log('Exception occurred: $error stackTrace: $stacktrace');
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CheckOTPModel>> callVerifyOTP(String enteredOTP) async {
    CheckOTPModel response;
    try {
      log('=======' + SharedPreferenceUtil.getString('userId'));
      log(enteredOTP);

      Constants.onLoading(context);
      Map<String, String> body = {
        'user_id': SharedPreferenceUtil.getString(Constants.registrationUserId),
        'otp': enteredOTP,
        'where': 'register',
      };
      response = await RestClient(RetroApi().dioData()).checkOtp(body);
      Constants.hideDialog(context);
      log(response.success.toString());
      if (response.success!) {
        Constants.toastMessage(response.msg!);
        Navigator.of(context).pushReplacement(
          Transitions(
            transitionType: TransitionType.fade,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: const LoginScreen(),
          ),
        );
      } else {
        Constants.toastMessage(response.msg!);
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      log('Exception occurred: $error stackTrace: $stacktrace');
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CheckOTPForForgotPasswordModel>> callForgotPasswordVerifyOTP(String enteredOTP) async {
    CheckOTPForForgotPasswordModel response;
    try {
      log('=======' + SharedPreferenceUtil.getString('userId'));
      log(enteredOTP);

      Constants.onLoading(context);
      Map<String, String> body = {
        'user_id': SharedPreferenceUtil.getString(Constants.loginUserId),
        'otp': enteredOTP,
        'where': 'change_password',
      };
      response = await RestClient(RetroApi().dioData()).checkOtpForForgotPassword(body);
      Constants.hideDialog(context);
      log(response.success.toString());
      if (response.success!) {
        Constants.toastMessage(response.msg!);

        Navigator.of(context).push(Transitions(transitionType: TransitionType.fade, curve: Curves.bounceInOut, reverseCurve: Curves.fastLinearToSlowEaseIn, widget: ChangePassword1()));
      } else {
        Constants.toastMessage(response.msg!);
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      log('Exception occurred: $error stackTrace: $stacktrace');
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}

// ignore: must_be_immutable
class OTPTextField extends StatelessWidget {
  TextEditingController editingController = TextEditingController();
  TextInputAction textInputAction;
  Function(String)? focus;
  bool isFirst;
  bool isLast;

  OTPTextField({
    Key? key,
    required this.editingController,
    required this.textInputAction,
    required this.focus,
    this.isFirst = false,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Center(
        child: TextFormField(
          onFieldSubmitted: focus,
          controller: editingController,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          textInputAction: textInputAction,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (str) {
            if (!isFirst && !isLast) {
              if (str.length == 1) {
                FocusScope.of(context).nextFocus();
              } else {
                FocusScope.of(context).previousFocus();
              }
            } else if (isFirst) {
              if (str.length == 1) {
                FocusScope.of(context).nextFocus();
              }
            } else if (isLast) {
              if (str.length != 1) {
                FocusScope.of(context).previousFocus();
              }
            }
          },
          style: TextStyle(fontFamily: Constants.appFontBold, fontWeight: FontWeight.bold, fontSize: 25, color: Constants.colorTheme),
          decoration: InputDecoration(
            hintStyle: TextStyle(
              color: Constants.colorTheme,
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(width: 3, color: editingController.text.isNotEmpty ? Constants.colorTheme : Constants.colorGray),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 3, color: editingController.text.isNotEmpty ? Constants.colorTheme : Constants.colorGray),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 3, color: editingController.text.isNotEmpty ? Constants.colorTheme : Constants.colorGray),
            ),
          ),
        ),
      ),
    );
  }
}
