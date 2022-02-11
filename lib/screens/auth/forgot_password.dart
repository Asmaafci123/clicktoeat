import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:mealup/model/send_otp_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/auth/otp_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/app_lable_widget.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:mealup/utils/widgets/customs/custom_app_bar.dart';
import 'package:mealup/utils/widgets/customs/custom_elevated_button.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final _textContactNo = TextEditingController();
  String? strCountryCode = '+92';

  // bool _autoValidate = false;

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
            title: Languages.of(context)!.labelForgotPassword1,
          ),
          backgroundColor: Colors.transparent,
          body: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: LottieBuilder.asset(
                        'animations/forgot_password.json',
                        frameRate: FrameRate(900),
                        width: 300,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Text(
                      'Forgot\npassword?',
                      style: TextStyle(
                        color: const Color(0xFF03041D),
                        fontSize: 44.0,
                        fontFamily: Constants.appFontBold,
                        height: 0.9,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      Languages.of(context)!.labelForgotPasswordDescription,
                      style: const TextStyle(
                        color: Color(0xFF03041D),
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 20),
                    AppLabelWidget(
                      title: Languages.of(context)!.labelEmail,
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(width: 0.5, color: Colors.grey),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 15),
                          Text(strCountryCode!),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              textInputAction: TextInputAction.next,
                              controller: _textContactNo,
                              validator: validateContactNumber,
                              maxLength: 10,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                              keyboardType: TextInputType.number,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context).nextFocus();
                              },
                              decoration: const InputDecoration.collapsed(hintText: '3123456789'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    Row(
                      children: [
                        Expanded(
                          child: CustomElevatedButton(
                            buttonLabel: Languages.of(context)!.labelSubmitThis,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                log(_textContactNo.text);
                                await callSendOTP();
                              }
                            },
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
      ),
    );
  }

  String? validateContactNumber(String? value) {
    if (value!.isEmpty) {
      return Languages.of(context)!.labelContactNumberRequired;
    } /*else if (value.length != 10) {
      return Languages.of(context)!.labelContactNumberNotValid;
    }*/
    else {
      return null;
    }
  }

  Future<BaseModel<SendOTPModel>> callSendOTP() async {
    log('calling send otp');
    SendOTPModel response;
    try {
      Constants.onLoading(context);
      Map<String, String> body = {
        'phone_code': '+92',
        'phone': _textContactNo.text,
        'where': 'forgot_password',
      };
      response = await RestClient(RetroApi().dioData()).sendOtp(body);
      Constants.hideDialog(context);
      log(response.data!.otp.toString());
      if (response.success!) {
        Constants.toastMessage('OTP Sent');
        SharedPreferenceUtil.putString(Constants.loginUserId, response.data!.id.toString());
        Navigator.of(context).push(
          Transitions(
            transitionType: TransitionType.fade,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: OTPScreen(
              isFromRegistration: false,
              phoneNo: _textContactNo.text,
            ),
          ),
        );
      } else {
        Constants.toastMessage(response.msg.toString());
      }
    } catch (error, stacktrace) {
      setState(() {
        Constants.hideDialog(context);
      });
      log("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
