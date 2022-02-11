import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealup/model/common_response.dart';
import 'package:mealup/model/user_details_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/pager/dashboard_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/localization/locale_constant.dart';
import 'package:mealup/utils/widgets/app_lable_widget.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:mealup/utils/widgets/customs/custom_app_bar.dart';
import 'package:mealup/utils/widgets/customs/custom_elevated_button.dart';
import 'package:mealup/utils/widgets/customs/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_shadow/simple_shadow.dart';

class EditProfileInformationScreen extends StatefulWidget {
  const EditProfileInformationScreen({Key? key}) : super(key: key);

  @override
  _EditProfileInformationScreenState createState() => _EditProfileInformationScreenState();
}

class Item {
  const Item(this.name, this.icon);

  final String name;
  final Icon icon;
}

class _EditProfileInformationScreenState extends State<EditProfileInformationScreen> {
  final _textFullName = TextEditingController();
  final _textEmail = TextEditingController();
  final _textContactNo = TextEditingController();
  final _textContactCode = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  //bool _autoValidate = false;

  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _micrCodeController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();

  bool isValid = false;

  File? _image;
  final picker = ImagePicker();
  String? imageBase64, countryCode = '+92', _userPhoto = '';

  Item? selectedUser;
  int tabIndex = 0;

  final List<String> _listLanguages = [];

  int? radioIndex;

  String strLanguage = '';

  void changeIndex(int index) {
    setState(() {
      radioIndex = index;
    });
  }

  Future<void> getLanguageList() async {
    _listLanguages.clear();
    _listLanguages.add('English');
    _listLanguages.add('Spanish');
    _listLanguages.add('Arabic');

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? languageCode = _prefs.getString(prefSelectedLanguageCode);

    setState(() {
      if (languageCode == 'en') {
        radioIndex = 0;
      } else if (languageCode == 'es') {
        radioIndex = 1;
      } else if (languageCode == 'ar') {
        radioIndex = 2;
      } else {
        radioIndex = 1;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _textContactNo.text = SharedPreferenceUtil.getString(Constants.loginPhone);
    _textContactCode.text = SharedPreferenceUtil.getString(Constants.loginPhoneCode);
    _textEmail.text = SharedPreferenceUtil.getString(Constants.loginEmail);
    _textFullName.text = SharedPreferenceUtil.getString(Constants.loginUserName);
    _userPhoto = SharedPreferenceUtil.getString(Constants.loginUserImage);

    _ifscCodeController.text = SharedPreferenceUtil.getString(Constants.bankIFSC);
    _micrCodeController.text = SharedPreferenceUtil.getString(Constants.bankMICR);
    _accountNameController.text = SharedPreferenceUtil.getString(Constants.bankACCName);
    _accountNumberController.text = SharedPreferenceUtil.getString(Constants.bankACCNumber);
    getLanguageList();
  }

  _imgFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        List<int> imageBytes = _image!.readAsBytesSync();
        imageBase64 = base64Encode(imageBytes);
        callUpdateImage();
      } else {
        log('No image selected.');
      }
    });
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        List<int> imageBytes = _image!.readAsBytesSync();
        imageBase64 = base64Encode(imageBytes);
        callUpdateImage();
      } else {
        log('No image selected.');
      }
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select image',
                      style: TextStyle(color: const Color(0xFF03041D), fontFamily: Constants.appFontBold, fontSize: 24),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.cancel_rounded,
                        color: Constants.colorBlack.withOpacity(0.7),
                      ),
                    )
                  ],
                ),
                Wrap(
                  children: <Widget>[
                    ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.add_photo_alternate_rounded,
                          color: Colors.black87,
                        ),
                        title: Text(
                          'Photo Library',
                          style: TextStyle(fontFamily: Constants.appFont),
                        ),
                        onTap: () {
                          _imgFromGallery();
                          Navigator.of(context).pop();
                        }),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.camera_enhance_rounded,
                        color: Colors.black87,
                      ),
                      title: Text(
                        'Camera',
                        style: TextStyle(fontFamily: Constants.appFont),
                      ),
                      onTap: () {
                        getImage();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
      child: Scaffold(
        appBar: CustomAppBar(title: Languages.of(context)!.labelEditProfile),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 1),
                Align(
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    clipBehavior: Clip.none,
                    children: [
                      SimpleShadow(
                        opacity: 0.6,
                        color: Colors.black12,
                        offset: const Offset(0, 0),
                        sigma: 3,
                        child: ClipOval(
                          child: SizedBox(
                            width: 120,
                            height: 120,
                            child: _image != null
                                ? Image.file(
                                    _image!,
                                    fit: BoxFit.cover,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: _userPhoto!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -20,
                        bottom: -5,
                        child: SimpleShadow(
                          opacity: 0.6,
                          color: Colors.black12,
                          offset: const Offset(0, 3),
                          sigma: 5,
                          child: ElevatedButton(
                            onPressed: () {
                              _showPicker(context);
                            },
                            child: Icon(
                              Icons.add_a_photo_rounded,
                              color: Constants.colorTheme,
                              size: 18,
                            ),
                            style: ElevatedButton.styleFrom(shape: const CircleBorder(), primary: Colors.white, padding: EdgeInsets.zero, elevation: 0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
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
                              countryCode = c.dialCode;
                              debugPrint(countryCode);
                            });
                          },
                          initialSelection: 'PK',
                          favorite: const ['+92', 'PK'],
                          hideMainText: true,
                          alignLeft: true,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(countryCode!),
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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            strLanguage = 'english';
                            log('selected Language' + strLanguage);
                            callUpdateUsername(strLanguage);
                          }
                        },
                        buttonLabel: Languages.of(context)!.labelSaveProfile,
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? validateAccountNumber(String? value) {
    if (value!.trim().isEmpty) {
      return Languages.of(context)!.bankAccountNumber2;
    }
    return null;
  }

  String? validateAccountName(String? value) {
    if (value!.trim().isEmpty) {
      return Languages.of(context)!.bankAccountName2;
    }
    return null;
  }

  String? validateIFSC(String? value) {
    if (value!.trim().isEmpty) {
      return Languages.of(context)!.iFSCCode2;
    }
    return null;
  }

  String? validateMICRCode(String? value) {
    if (value!.trim().isEmpty) {
      return Languages.of(context)!.mICRCode2;
    } else {
      return null;
    }
  }

  String? validateFullName(String? value) {
    if (value!.trim().isEmpty) {
      return Languages.of(context)!.labelFullNameRequired;
    } else {
      return null;
    }
  }

  String? validateContactNumber(String? value) {
    if (value!.trim().isEmpty) {
      return Languages.of(context)!.labelContactNumberRequired;
    } else if (value.length > 10) {
      return Languages.of(context)!.labelContactNumberNotValid;
    } else {
      return null;
    }
  }

  String? validateEmail(String? value) {
    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern as String);
    if (value!.trim().isEmpty) {
      return Languages.of(context)!.labelEmailRequired;
    } else if (!regex.hasMatch(value)) {
      return Languages.of(context)!.labelEnterValidEmail;
    } else {
      return null;
    }
  }

  Future<BaseModel<UserDetailsModel>> callGetUserDetails() async {
    UserDetailsModel response;
    try {
      Constants.onLoading(context);
      response = await RestClient(RetroApi().dioData()).user();
      Constants.hideDialog(context);
      log(response.toString());
      setState(() {
        _textFullName.text = response.name!;
        _textEmail.text = response.emailId!;
        _textContactNo.text = response.phone!;
        _userPhoto = response.image;
        debugPrint('Updated Photo: $_userPhoto');
        SharedPreferenceUtil.putString(Constants.loginUserName, response.name!);
        SharedPreferenceUtil.putString(Constants.loginUserImage, response.image!);
        SharedPreferenceUtil.putString(Constants.loginEmail, response.emailId!);
        SharedPreferenceUtil.putString(Constants.loginPhone, response.phone!);
      });

      Navigator.of(context).pushReplacement(
        Transitions(
          transitionType: TransitionType.slideUp,
          curve: Curves.bounceInOut,
          reverseCurve: Curves.fastLinearToSlowEaseIn,
          widget: DashboardScreen(3),
        ),
      );
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      log("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CommonResponse>> callUpdateImage() async {
    CommonResponse response;
    try {
      Constants.onLoading(context);
      Map<String, String?> body = {
        'image': imageBase64,
      };
      response = await RestClient(RetroApi().dioData()).updateImage(body);
      Constants.hideDialog(context);
      log(response.success.toString());
      if (response.success!) {
        Constants.toastMessage(response.data!);
        callGetUserDetails();
      } else {
        Constants.toastMessage('Error while updating image.');
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      log("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CommonResponse>> callUpdateUsername(String strLanguage) async {
    CommonResponse response;
    try {
      Constants.onLoading(context);
      Map<String, String> body = {
        'name': _textFullName.text,
        'language': strLanguage,
      };
      response = await RestClient(RetroApi().dioData()).updateUser(body);
      Constants.hideDialog(context);
      log(response.success.toString());
      if (response.success!) {
        Constants.toastMessage(response.data!);
        callGetUserDetails();
      } else {
        Constants.toastMessage('Error while update image.');
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      log("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CommonResponse>> submitBankDetails() async {
    CommonResponse response;
    try {
      Constants.onLoading(context);
      Map<String, String> body = {
        'ifsc_code': _ifscCodeController.text,
        'micr_code': _micrCodeController.text,
        'account_name': _accountNameController.text,
        'account_number': _accountNumberController.text,
      };
      response = await RestClient(RetroApi().dioData()).bankDetails(body);
      Constants.hideDialog(context);
      log(response.success.toString());
      if (response.success!) {
        Constants.toastMessage(response.data!);

        SharedPreferenceUtil.putString(Constants.bankIFSC, _ifscCodeController.text);
        SharedPreferenceUtil.putString(Constants.bankMICR, _micrCodeController.text);
        SharedPreferenceUtil.putString(Constants.bankACCName, _accountNameController.text);
        SharedPreferenceUtil.putString(Constants.bankACCNumber, _accountNumberController.text);

        setState(() {
          _ifscCodeController.text = SharedPreferenceUtil.getString(Constants.bankIFSC);
          _micrCodeController.text = SharedPreferenceUtil.getString(Constants.bankMICR);
          _accountNameController.text = SharedPreferenceUtil.getString(Constants.bankACCName);
          _accountNumberController.text = SharedPreferenceUtil.getString(Constants.bankACCNumber);
        });
      } else {
        Constants.toastMessage('Error while submit bank details.');
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      log("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('  ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}
