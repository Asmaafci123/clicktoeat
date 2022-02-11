import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scoped_model/scoped_model.dart';

import 'model/cart_model.dart';
import 'screens/on_boarding/splash_screen.dart';
import 'utils/localization/locale_constant.dart';
import 'utils/localization/localizations_delegate.dart';
import 'utils/widgets/constants.dart';
import 'utils/widgets/custom_shared_preference_util.dart';
import 'utils/widgets/preference_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferenceUtil.getInstance();
  runApp(MyApp(
    model: CartModel(),
  ));
}

class MyApp extends StatefulWidget {
  final CartModel model;

  const MyApp({Key? key, required this.model}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() async {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    PreferenceUtils.init();
    return RefreshConfiguration(
      footerTriggerDistance: 15,
      dragSpeedRatio: 0.91,
      headerBuilder: () => const MaterialClassicHeader(),
      footerBuilder: () => const ClassicFooter(),
      enableLoadingWhenNoData: true,
      enableRefreshVibrate: false,
      enableLoadMoreVibrate: false,
      child: ScopedModel<CartModel>(
        model: widget.model,
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: () => MaterialApp(
            locale: _locale,
            supportedLocales: const [
              Locale('en', ''),
              Locale('es', ''),
              Locale('ar', ''),
            ],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode && supportedLocale.countryCode == locale?.countryCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: Constants.colorBackground,
              accentColor: Constants.colorTheme,
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: const Color(0xFFBC2030).withOpacity(0.4),
                selectionHandleColor: const Color(0xFFBC2030),
                cursorColor: const Color(0xFFBC2030),
              ),
            ),
            home: SplashScreen(
              model: widget.model,
            ),
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }
}
