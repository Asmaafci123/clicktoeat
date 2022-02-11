import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mealup/model/common_response.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/app_lable_widget.dart';
import 'package:mealup/utils/widgets/card_password_textfield.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:mealup/utils/widgets/customs/custom_app_bar.dart';
import 'package:mealup/utils/widgets/customs/custom_elevated_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final bool _oldPasswordVisible = true;
  final bool _passwordVisible = true;
  final bool _confirmPasswordVisible = true;

  final _oldTextPassword = TextEditingController();
  final _textPassword = TextEditingController();
  final _textConfPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
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
          appBar: CustomAppBar(title: Languages.of(context)!.labelChangePassword),
          backgroundColor: Colors.transparent,
          body: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: LottieBuilder.asset(
                        'animations/change_password.json',
                        frameRate: FrameRate(900),
                        width: 300,
                      ),
                    ),
                    Text(
                      'Change\npassword?',
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
                      'Make sure you remember your new password!',
                      style: TextStyle(
                        color: Color(0xFF03041D),
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 20),
                    AppLabelWidget(
                      title: Languages.of(context)!.labelOldPassword,
                    ),
                    CardPasswordTextFieldWidget(
                        textEditingController: _oldTextPassword, validator: oValidatePassword, hintText: Languages.of(context)!.labelEnterOldPassword, isPasswordVisible: _oldPasswordVisible),
                    const SizedBox(height: 10),
                    AppLabelWidget(
                      title: Languages.of(context)!.labelNewPassword,
                    ),
                    CardPasswordTextFieldWidget(
                        textEditingController: _textPassword, validator: kValidatePassword, hintText: Languages.of(context)!.labelEnterNewPassword, isPasswordVisible: _passwordVisible),
                    const SizedBox(height: 10),
                    AppLabelWidget(
                      title: Languages.of(context)!.labelConfirmPassword,
                    ),
                    CardPasswordTextFieldWidget(
                        textEditingController: _textConfPassword,
                        validator: validateConfPassword,
                        hintText: Languages.of(context)!.labelReEnterNewPassword,
                        isPasswordVisible: _confirmPasswordVisible),
                    const SizedBox(height: 30.0),
                    Row(
                      children: [
                        Expanded(
                          child: CustomElevatedButton(
                            buttonLabel: Languages.of(context)!.labelChangePassword,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Constants.checkNetwork().whenComplete(() => callChangePassword());
                              } else {
                                setState(() {
                                  // validation error
                                  // _autoValidate = true;
                                });
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

  String? oValidatePassword(String? value) {
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

  String? kValidatePassword(String? value) {
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

  String? validateConfPassword(String? value) {
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

  Future<BaseModel<CommonResponse>> callChangePassword() async {
    CommonResponse response;
    try {
      Constants.onLoading(context);
      Map<String, String> body = {
        'user_id': SharedPreferenceUtil.getString(Constants.loginUserId),
        'old_password': _oldTextPassword.text,
        'password': _textPassword.text,
        'password_confirmation': _textConfPassword.text,
      };
      response = await RestClient(RetroApi().dioData()).changePassword(body);
      Constants.hideDialog(context);
      log(response.success.toString());
      if (response.success!) {
        Constants.toastMessage(response.data!);
        Navigator.pop(context);
        /*   Navigator.of(context).pushAndRemoveUntil(
            Transitions(
              transitionType: TransitionType.fade,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: LoginScreen(),
            ),
            (Route<dynamic> route) => false);*/
      } else {
        Constants.toastMessage(response.data!);
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
