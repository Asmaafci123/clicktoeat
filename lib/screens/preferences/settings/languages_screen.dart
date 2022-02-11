import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/localization/locale_constant.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/customs/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({Key? key}) : super(key: key);

  @override
  _LanguagesScreenState createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  final List<String> _listLanguages = [];

  int? radioIndex;

  void changeIndex(int index) {
    setState(() {
      radioIndex = index;
    });
  }

  Widget getChecked() {
    return Icon(Icons.check_circle_rounded, size: 20, color: Constants.colorWhite);
  }

  Widget getUnChecked() {
    return Icon(Icons.radio_button_unchecked_rounded, size: 20, color: Constants.colorWhite);
  }

  @override
  void initState() {
    super.initState();
    getLanguageList();
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
          backgroundColor: Colors.transparent,
          appBar: CustomAppBar(
            title: Languages.of(context)!.labelLanguage,
          ),
          body: Padding(
            padding: const EdgeInsets.all(30.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: LottieBuilder.asset(
                      'animations/language.json',
                      frameRate: FrameRate(900),
                      width: 300,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Language',
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
                    'Choose your preferred language!',
                    style: TextStyle(
                      color: Color(0xFF03041D),
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 30),
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: _listLanguages.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 30,
                      mainAxisExtent: 100,
                    ),
                    itemBuilder: (_, index) {
                      return GestureDetector(
                        onTap: () {
                          changeIndex(index);
                          String languageCode = '';
                          if (index == 0) {
                            languageCode = 'en';
                          } else if (index == 1) {
                            languageCode = 'ar';
                          } else {
                            languageCode = 'es';
                          }
                          changeLanguage(context, languageCode);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              radioIndex != index
                                  ? ColorFiltered(
                                      colorFilter: const ColorFilter.mode(
                                        Colors.black,
                                        BlendMode.saturation,
                                      ),
                                      child: Image.asset(
                                        index == 0 ? 'assets/ic_flag_uk.png' : 'assets/ic_flag_pak.png',
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      index == 0 ? 'assets/ic_flag_uk.png' : 'assets/ic_flag_pak.png',
                                      fit: BoxFit.cover,
                                    ),
                              Container(
                                height: 100,
                                width: 200,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0x66000000),
                                      Color(0x66000000),
                                      Color(0x00000000),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 3, left: 3),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: radioIndex == index ? getChecked() : getUnChecked(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Flexible(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Text(
                                          _listLanguages[index],
                                          style: TextStyle(
                                            fontFamily: Constants.appFontBold,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getLanguageList() async {
    _listLanguages.clear();
    _listLanguages.add('English');
    // _listLanguages.add('Spanish');
    _listLanguages.add('Urdu');

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? languageCode = _prefs.getString(prefSelectedLanguageCode);

    setState(() {
      if (languageCode == 'en') {
        radioIndex = 0;
      } else if (languageCode == 'ar') {
        radioIndex = 1;
      } else if (languageCode == 'es') {
        radioIndex = 2;
      } else {
        radioIndex = 1;
      }
    });
  }
}

// ListView.builder(
// physics: const ClampingScrollPhysics(),
// shrinkWrap: true,
// scrollDirection: Axis.vertical,
// itemCount: _listLanguages.length,
// itemBuilder: (BuildContext context, int index) => InkWell(
// onTap: () {
// changeIndex(index);
// Navigator.pop(context);
// String languageCode = '';
// if (index == 0) {
// languageCode = 'en';
// } else if (index == 1) {
// languageCode = 'es';
// } else {
// languageCode = 'ar';
// }
// changeLanguage(context, languageCode);
// },
// child: Row(
// children: [
// radioIndex == index ? getChecked() : getUnChecked(),
// Padding(
// padding: const EdgeInsets.only(left: 10),
// child: Text(
// _listLanguages[index],
// style: TextStyle(fontFamily: Constants.appFont, fontWeight: FontWeight.w900, fontSize: ScreenUtil().setSp(14)),
// ),
// ),
// ],
// ),
// ),
// ),
