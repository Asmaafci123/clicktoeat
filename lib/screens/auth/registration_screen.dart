import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:mealup/model/register_model.dart';
import 'package:mealup/model/send_otp_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/auth/login_screen.dart';
import 'package:mealup/screens/auth/otp_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/app_lable_widget.dart';
import 'package:mealup/utils/widgets/card_password_textfield.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:mealup/utils/widgets/customs/custom_app_bar.dart';
import 'package:mealup/utils/widgets/customs/custom_elevated_button.dart';
import 'package:mealup/utils/widgets/customs/custom_text_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final bool _passwordVisible = true;
  final bool _confirmPasswordVisible = true;

  final _textFullName = TextEditingController();
  final _textEmail = TextEditingController();
  final _textPassword = TextEditingController();
  final _textConfPassword = TextEditingController();
  final _textContactNo = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? strCountryCode = '+92';

  String strLanguage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic screenWidth = MediaQuery.of(context).size.width;
    dynamic screenHeight = MediaQuery.of(context).size.height;

    ScreenUtil.init(
        BoxConstraints(maxWidth: screenWidth, maxHeight: screenHeight),
        designSize: const Size(360, 690),
        orientation: Orientation.portrait);

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
          appBar:
              CustomAppBar(title: Languages.of(context)!.labelCreateNewAccount),
          backgroundColor: Colors.transparent,
          body: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: LottieBuilder.asset(
                        'animations/registration.json',
                        frameRate: FrameRate(900),
                        width: 300,
                      ),
                    ),
                    Text(
                      'Register\nyourself...',
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
                      'We will send you a confirmation code.',
                      style: TextStyle(
                        color: Color(0xFF03041D),
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 20),
                    AppLabelWidget(
                      title: Languages.of(context)!.labelFullName,
                    ),
                    CustomTextField(
                      onFieldSubmitted: (v) {
                        FocusScope.of(context).nextFocus();
                      },
                      textInputAction: TextInputAction.next,
                      hintText: Languages.of(context)!.labelEnterYourFullName,
                      textInputType: TextInputType.text,
                      textEditingController: _textFullName,
                      validator: validateFullName,
                    ),
                    const SizedBox(height: 10),
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
                      title: Languages.of(context)!.labelContactNumber,
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
                          Visibility(
                            visible: false,
                            child: CountryCodePicker(
                              flagWidth: 26,
                              padding: EdgeInsets.zero,
                              onChanged: (c) {
                                setState(() {
                                  strCountryCode = c.dialCode;
                                  debugPrint(strCountryCode);
                                });
                              },
                              dialogSize:
                                  Size(screenWidth * 0.8, screenHeight * 0.6),
                              initialSelection: 'PK',
                              favorite: const ['+92', 'PK'],
                              hideMainText: true,
                              alignLeft: true,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Text(strCountryCode!),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              textInputAction: TextInputAction.next,
                              controller: _textContactNo,
                              validator: validateContactNumber,
                              maxLength: 11,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                // FilteringTextInputFormatter.deny(
                                // RegExp(r'^0+')),
                              ],
                              buildCounter: (context,
                                      {required currentLength,
                                      required isFocused,
                                      maxLength}) =>
                                  null,
                              keyboardType: TextInputType.number,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context).nextFocus();
                              },
                              decoration: const InputDecoration.collapsed(
                                  hintText: '3123456789'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppLabelWidget(
                      title: Languages.of(context)!.labelPassword,
                    ),
                    CardPasswordTextFieldWidget(
                        textEditingController: _textPassword,
                        validator: validatePassword,
                        hintText: Languages.of(context)!.labelEnterYourPassword,
                        isPasswordVisible: _passwordVisible),
                    const SizedBox(height: 10),
                    AppLabelWidget(
                      title: Languages.of(context)!.labelConfirmPassword,
                    ),
                    CardPasswordTextFieldWidget(
                        textEditingController: _textConfPassword,
                        validator: validateConfirmPassword,
                        hintText: Languages.of(context)!.labelReEnterPassword,
                        isPasswordVisible: _confirmPasswordVisible),
                    const SizedBox(height: 30.0),
                    Row(
                      children: [
                        Expanded(
                          child: CustomElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                strLanguage = 'english';
                                debugPrint('selected Language' + strLanguage);
                                callRegisterAPI(strLanguage);
                              }
                            },
                            buttonLabel:
                                Languages.of(context)!.labelCreateNewAccount,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Languages.of(context)!.labelAlreadyHaveAccount,
                            style: TextStyle(
                              fontFamily: Constants.appFont,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            Languages.of(context)!.labelLogin,
                            style: TextStyle(
                                fontFamily: Constants.appFontBold,
                                fontSize: 16,
                                color: Constants.colorTheme),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(30),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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

  String? validateFullName(String? value) {
    if (value!.isEmpty) {
      return Languages.of(context)!.labelFullNameRequired;
    } else {
      return null;
    }
  }

  String? validateContactNumber(String? value) {
    Pattern pattern = r'^(?:[+0][1-9])?[0-9]{10,11}$';
    RegExp regex = RegExp(pattern as String);
    if (value!.isEmpty) {
      return Languages.of(context)!.labelContactNumberRequired;
    } else if (!regex.hasMatch(value)) {
      return Languages.of(context)!.labelContactNumberNotValid;
    }
    /*else if (value.length != 10) {
      return Languages.of(context)!.labelContactNumberNotValid;
    }*/
    else {
      return null;
    }
  }

  String? validateEmail(String? value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern as String);
    if (value!.isEmpty) {
      return Languages.of(context)!.labelEmailRequired;
    } else if (!regex.hasMatch(value)) {
      return Languages.of(context)!.labelEnterValidEmail;
    } else {
      return null;
    }
  }

  String? validateConfirmPassword(String? value) {
    Pattern pattern = r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    RegExp regex = RegExp(pattern as String);
    if (value!.isEmpty) {
      return Languages.of(context)!.labelPasswordRequired;
    } else if (_textPassword.text != _textConfPassword.text) {
      return Languages.of(context)!.labelPasswordConfPassNotMatch;
    } else if (!regex.hasMatch(value)) {
      return Languages.of(context)!.labelPasswordValidation;
    } else {
      return null;
    }
  }

  Future<BaseModel<RegisterModel>> callRegisterAPI(String strLanguage) async {
    RegisterModel response;
    try {
      Constants.onLoading(context);
      Map<String, String?> body = {
        'name': _textFullName.text,
        'email_id': _textEmail.text,
        'password': _textConfPassword.text,
        'phone': _textContactNo.text,
        'phone_code': strCountryCode,
        'language': strLanguage,
      };

      response = await RestClient(RetroApi().dioData()).register(body);
      debugPrint(response.success.toString());
      Constants.hideDialog(context);
      if (response.success!) {
        Constants.toastMessage(response.msg!);
        if (response.data!.otp != null) {
          SharedPreferenceUtil.putInt(
              Constants.registrationOTP, response.data!.otp);
        } else {
          SharedPreferenceUtil.putInt(Constants.registrationOTP, 0);
        }
        if (response.data!.emailId != null) {
          SharedPreferenceUtil.putString(
              Constants.registrationEmail, response.data!.emailId!);
        } else {
          SharedPreferenceUtil.putString(Constants.registrationEmail, '0');
        }
        if (response.data!.phone != null) {
          SharedPreferenceUtil.putString(
              Constants.registrationPhone, response.data!.phone!);
        } else {
          SharedPreferenceUtil.putString(Constants.registrationPhone, '0');
        }
        if (response.data!.id != null) {
          SharedPreferenceUtil.putString(
              Constants.registrationUserId, response.data!.id.toString());
        } else {
          SharedPreferenceUtil.putString(Constants.registrationUserId, '0');
        }

        if (response.data!.isVerified == 0) {
          callSendOTP();
          /*Navigator.of(context).pushReplacement(
            Transitions(
              transitionType: TransitionType.slideUp,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: OTPScreen(
                isFromRegistration: true,
              ),
            ),
          );*/
        } else {
          Navigator.of(context).pushReplacement(
            Transitions(
              transitionType: TransitionType.fade,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: const LoginScreen(),
            ),
          );
        }
      } else {
        Constants.toastMessage(response.msg!);
      }
    } catch (error, stacktrace) {
      setState(() {
        Constants.hideDialog(context);
      });
      debugPrint("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<SendOTPModel>> callSendOTP() async {
    SendOTPModel response;
    try {
      Constants.onLoading(context);
      Map<String, String> body = {
        // 'email_id': _textEmail.text,
        'phone_code': strCountryCode ?? '+92',
        'phone': _textContactNo.text,
        'where': 'register',
      };
      print('OTP Body: $body');
      response = await RestClient(RetroApi().dioData()).sendOtp(body);
      Constants.hideDialog(context);
      print('[OTP Response]: ${response.success}');
      if (response.success!) {
        //Constants.toastMessage('OTP Sent');
        SharedPreferenceUtil.putString(
            Constants.loginUserId, response.data!.id.toString());
        Navigator.of(context).push(
          Transitions(
            transitionType: TransitionType.fade,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: OTPScreen(
              isFromRegistration: true,
              emailForOTP: _textEmail.text,
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
      debugPrint("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
