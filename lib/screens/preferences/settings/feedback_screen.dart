import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:mealup/model/common_response.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:mealup/utils/widgets/customs/custom_app_bar.dart';
import 'package:mealup/utils/widgets/customs/custom_elevated_button.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class Item {
  const Item(this.name, this.icon);

  final String name;
  final Icon icon;
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  /// Emojis ☹️ 😐 🙂 😊 😍
  int radioIndex = -1;

  String strCountryCode = '+92';

  bool isFirst = true, isSecond = false, isThird = false, isAllAdded = false;

  final picker = ImagePicker();

  final _textContactNo = TextEditingController();
  final _textComment = TextEditingController();

  final List<File> _imageList = [];
  final _formKey = GlobalKey<FormState>();
  final List<String> _listBase64String = [];

  @override
  Widget build(BuildContext context) {
    _textContactNo.text = SharedPreferenceUtil.getString(Constants.loginPhone);

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
          appBar: CustomAppBar(title: Languages.of(context)!.labelFeedbackAndSupport),
          body: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0, left: 30.0, right: 30.0, top: 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: LottieBuilder.asset(
                        'animations/feedback.json',
                        frameRate: FrameRate(900),
                        width: 300,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Feedback',
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
                      'We want to know what you thought of your experience at Click To Eat, so we\'d love to hear your feedback.',
                      style: TextStyle(
                        color: Color(0xFF03041D),
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Do you have some feedback?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              radioIndex = 0;
                            });
                          },
                          child: ClipOval(
                            child: radioIndex == 0
                                ? Image.asset(
                                    'assets/ic_sad.png',
                                    fit: BoxFit.fill,
                                    width: 52,
                                    height: 52,
                                  )
                                : ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      Colors.black,
                                      BlendMode.saturation,
                                    ),
                                    child: Image.asset(
                                      'assets/ic_sad.png',
                                      fit: BoxFit.fill,
                                      width: 52,
                                      height: 52,
                                    ),
                                  ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              radioIndex = 1;
                            });
                          },
                          child: ClipOval(
                            child: radioIndex == 1
                                ? Image.asset(
                                    'assets/ic_sorry.png',
                                    fit: BoxFit.fill,
                                    width: 52,
                                    height: 52,
                                  )
                                : ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      Colors.black,
                                      BlendMode.saturation,
                                    ),
                                    child: Image.asset(
                                      'assets/ic_sorry.png',
                                      fit: BoxFit.fill,
                                      width: 52,
                                      height: 52,
                                    ),
                                  ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              radioIndex = 2;
                            });
                          },
                          child: ClipOval(
                            child: radioIndex == 2
                                ? Image.asset(
                                    'assets/ic_happy.png',
                                    fit: BoxFit.fill,
                                    width: 52,
                                    height: 52,
                                  )
                                : ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      Colors.black,
                                      BlendMode.saturation,
                                    ),
                                    child: Image.asset(
                                      'assets/ic_happy.png',
                                      fit: BoxFit.fill,
                                      width: 52,
                                      height: 52,
                                    ),
                                  ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              radioIndex = 3;
                            });
                          },
                          child: ClipOval(
                            child: radioIndex == 3
                                ? Image.asset(
                                    'assets/ic_smile.png',
                                    fit: BoxFit.fill,
                                    width: 52,
                                    height: 52,
                                  )
                                : ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      Colors.black,
                                      BlendMode.saturation,
                                    ),
                                    child: Image.asset(
                                      'assets/ic_smile.png',
                                      fit: BoxFit.fill,
                                      width: 52,
                                      height: 52,
                                    ),
                                  ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              radioIndex = 4;
                            });
                          },
                          child: ClipOval(
                            child: radioIndex == 4
                                ? Image.asset(
                                    'assets/ic_love.png',
                                    fit: BoxFit.fill,
                                    width: 52,
                                    height: 52,
                                  )
                                : ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      Colors.black,
                                      BlendMode.saturation,
                                    ),
                                    child: Image.asset(
                                      'assets/ic_love.png',
                                      fit: BoxFit.fill,
                                      width: 52,
                                      height: 52,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      Languages.of(context)!.labelAddYourExperience,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: TextFormField(
                        controller: _textComment,
                        keyboardType: TextInputType.text,
                        validator: validateFeedbackComment,
                        decoration: InputDecoration(
                          hintText: Languages.of(context)!.labelAddYourExperienceHere,
                          errorStyle: TextStyle(fontFamily: Constants.appFont, color: Colors.red),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: 6,
                        style: TextStyle(
                          fontFamily: Constants.appFont,
                          fontSize: 16,
                          color: Constants.colorBlack,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        if (!isAllAdded) {
                          if (isFirst) {
                            _showPicker(context, 0);
                          } else if (isSecond) {
                            _showPicker(context, 1);
                          } else if (isThird) {
                            _showPicker(context, 2);
                          }
                        } else {
                          Constants.toastMessage(Languages.of(context)!.labelMax3Image);
                        }
                      },
                      child: Container(
                          padding: const EdgeInsets.all(15),
                          constraints: const BoxConstraints(minHeight: 70),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.photo_rounded, color: Constants.colorTheme, size: 33),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Select the attachments',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Constants.colorTheme),
                                  ),
                                  Text(
                                    'Max 3 files (JPG / PNG)',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Constants.colorGray),
                                  ),
                                ],
                              ),
                            ],
                          )),
                    ),
                    if (_imageList.isNotEmpty) ...[
                      const SizedBox(height: 30),
                      Wrap(
                        runSpacing: 15,
                        spacing: 15,
                        direction: Axis.horizontal,
                        children: _imageList
                            .map(
                              (image) => SizedBox(
                                width: 90,
                                height: 90,
                                child: Stack(
                                  alignment: AlignmentDirectional.topEnd,
                                  clipBehavior: Clip.none,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        image,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 90,
                                      ),
                                    ),
                                    Positioned(
                                      top: -10,
                                      right: -10,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (_imageList.length == 3) {
                                              _imageList.remove(image);
                                              isThird = true;
                                            } else if (_imageList.length == 2) {
                                              _imageList.remove(image);
                                              isSecond = true;
                                            } else if (_imageList.length == 1) {
                                              _imageList.remove(image);
                                              isFirst = true;
                                              isAllAdded = false;
                                            }
                                          });
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.cancel_rounded,
                                            size: 24,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 30),
                    CustomElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          log(_listBase64String.toString());
                          log(radioIndex.toString());

                          if (radioIndex != -1) {
                            int rate = radioIndex + 1;
                            callShareAppFeedback(rate);
                          } else {
                            Constants.toastMessage(Languages.of(context)!.labelPleaseSelectEmoji);
                          }
                        } else {
                          setState(() {
                            // validation error
                          });
                        }
                      },
                      buttonLabel: Languages.of(context)!.labelShareFeedback,
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

  String? validatePhoneNumber(String? value) {
    if (value!.isEmpty) {
      return Languages.of(context)!.labelContactNumberRequired;
    } else if (value.length > 10) {
      return Languages.of(context)!.labelContactNumberNotValid;
    } else {
      return null;
    }
  }

  String? validateFeedbackComment(String? value) {
    if (value!.isEmpty) {
      return Languages.of(context)!.labelFeedbackCommentRequired;
    } else {
      return null;
    }
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  _imgFromGallery(int pos) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageList.add(File(pickedFile.path));
        List<int> imageBytes = _imageList[pos].readAsBytesSync();
        _listBase64String.add(base64Encode(imageBytes));

        if (pos == 0) {
          isFirst = false;
          isSecond = true;
        } else if (pos == 1) {
          isSecond = false;
          isThird = true;
        } else if (pos == 2) {
          isThird = false;
          isAllAdded = true;
        }
      } else {
        log('No image selected.');
      }
    });
  }

  Future getImage(int pos) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imageList.add(File(pickedFile.path));
        List<int> imageBytes = _imageList[pos].readAsBytesSync();
        _listBase64String.add(base64Encode(imageBytes));
        if (pos == 0) {
          isFirst = false;
          isSecond = true;
        } else if (pos == 1) {
          isSecond = false;
          isThird = true;
        } else if (pos == 2) {
          isThird = false;
          isAllAdded = true;
        }
      } else {
        log('No image selected.');
      }
    });
  }

  void _showPicker(context, int pos) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(
                    Languages.of(context)!.labelPhotoLibrary,
                    style: TextStyle(fontFamily: Constants.appFont),
                  ),
                  onTap: () {
                    _imgFromGallery(pos);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(
                  Languages.of(context)!.labelCamera,
                  style: TextStyle(fontFamily: Constants.appFont),
                ),
                onTap: () {
                  getImage(pos);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text(
                  Languages.of(context)!.labelCancel,
                  style: TextStyle(fontFamily: Constants.appFont),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<BaseModel<CommonResponse>> callShareAppFeedback(int rate) async {
    CommonResponse response;
    try {
      Map body = {
        'rate': rate.toString(),
        'comment': _textComment.text,
      };
      response = await RestClient(RetroApi().dioData()).addFeedback(body, _listBase64String);
      log(response.success.toString());
      // Constants.hideDialog(context);
      if (response.success!) {
        Constants.toastMessage(response.data!);
        Navigator.pop(context);
      } else {
        Constants.toastMessage('error while giving feedback.');
      }
    } catch (error, stacktrace) {
      log("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
