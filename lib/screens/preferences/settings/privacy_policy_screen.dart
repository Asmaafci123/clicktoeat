import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:mealup/utils/widgets/customs/custom_app_bar.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: Languages.of(context)!.labelPrivacyPolicy,
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/ic_background_image.png'),
                      fit: BoxFit.cover,
                    )),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Html(data: SharedPreferenceUtil.getString(Constants.appSettingPrivacyPolicy)),
                        ],
                      ),
                    ),
                  )),
            );
          },
        ),
      ),
    );
  }
}
