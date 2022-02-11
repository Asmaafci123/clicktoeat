import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:stripe_payment/stripe_payment.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/screens/wallet/wallet_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:mealup/utils/widgets/customs/custom_elevated_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class WalletPaymentStripe extends StatefulWidget {
  final orderAmount;

  const WalletPaymentStripe({
    Key? key,
    this.orderAmount,
  }) : super(key: key);
  @override
  _WalletPaymentStripeState createState() => _WalletPaymentStripeState();
}

class _WalletPaymentStripeState extends State<WalletPaymentStripe> {
  String? expDate;
  String? cvv;
  //String paymentType;
  // Token? _paymentToken;
  //PaymentMethod _paymentMethod;
  // String _error;
  // String _currentSecret; //set this yourself, e.g using curl
  // PaymentIntentResult _paymentIntent;
//  Source _source;
  String? stripePublicKey;
  String? stripeSecretKey;
  String? stripeToken;
  int? paymentTokenKnow;
  int? paymentStatus;
  String? paymentType;
  ScrollController _controller = ScrollController();
  String cardNumber = '';
  String cardHolderName = '';
  String expiryDate = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool showSpinner = false;
  int? selectedIndex;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  initState() {
    super.initState();
    // getStripePublishKey();
    stripeSecretKey = SharedPreferenceUtil.getString(Constants.appStripeSecretKey);
    stripePublicKey = SharedPreferenceUtil.getString(Constants.appStripePublishKey);
    // StripePayment.setOptions(StripeOptions(
    //     publishableKey: "$stripePublicKey",
    //     merchantId: "Test",
    //     androidPayMode: 'test'));
  }

  Future<void> getStripePublishKey() async {
    stripeSecretKey = SharedPreferenceUtil.getString(Constants.appStripeSecretKey);
    stripePublicKey = SharedPreferenceUtil.getString(Constants.appStripePublishKey);
    // StripePayment.setOptions(StripeOptions(
    //     publishableKey: "$stripePublicKey",
    //     merchantId: "Test",
    //     androidPayMode: 'test'));
  }

  setError(dynamic error) {
    showSpinner = false;
    Constants.toastMessage(error.toString());
    setState(() {
      //_error = error.toString();
    });
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(
          'Stripe Payment',
        ),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Container(
          color: Constants.colorWhite,
          child: ListView(
            scrollDirection: Axis.vertical,
            controller: _controller,
            children: <Widget>[
              CreditCardWidget(
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                showBackView: isCvvFocused,
                onCreditCardWidgetChange: (creditCardBrand) {},
              ),
              SingleChildScrollView(
                child: CreditCardForm(
                  cvvCode: cvvCode,
                  cardHolderName: cardHolderName,
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  themeColor: Colors.grey,
                  formKey: new GlobalKey<FormState>(),
                  onCreditCardModelChange: onCreditCardModelChange,
                ),
              ),
              SizedBox(height: 20.0),
              //click to next
              Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 20),
                  child: CustomElevatedButton(
                      buttonLabel: 'Continue',
                      onPressed: () {
                        showSpinner = true;
                        var expMonth = expiryDate.split('/')[0];
                        var expYear = expiryDate.split('/')[1];
                        int finalExpMonth = int.parse(expMonth.toString());
                        int finalExpYear = int.parse(expYear.toString());
                        // StripePayment.createTokenWithCard(
                        //   CreditCard(
                        //     number: '$cardNumber',
                        //     expMonth: finalExpMonth,
                        //     expYear: finalExpYear,
                        //     cvc: '$cvvCode',
                        //     name: '$cardHolderName',
                        //   ),
                        // ).then((token) {
                        //   Constants.toastMessage('Payment Completed');/*
                        //   _scaffoldKey.currentState.showSnackBar(
                        //       // SnackBar(content: Text('Received ${token.tokenId}')));
                        //       SnackBar(content: Text('Payment Completed')));*/
                        //   setState(() {
                        //     showSpinner = false;
                        //     _paymentToken = token;
                        //     print(_paymentToken);
                        //     stripeToken = token.tokenId;
                        //     SharedPreferenceUtil.putString(Constants.stripePaymentToken, stripeToken!);
                        //     addUserBalance();
                        //   });
                        // }).catchError(setError);
                      })),
            ],
          ),
        ),
      ),
    );
  }

  void addUserBalance() {
    Constants.onLoading(context);
    Map<String, String?> body = {
      'amount': widget.orderAmount,
      'payment_type': 'STRIPE',
      'payment_token': stripeToken,
    };
    RestClient(RetroApi().dioData()).addBalance(body).then((response) {
      setState(() {
        Constants.hideDialog(context);
        Constants.toastMessage(response.data!);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => WalletScreen(),
        ));
      });
    }).catchError((Object obj) {
      Constants.hideDialog(context);
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response!;
          var msg = res.statusMessage;
          var responseCode = res.statusCode;
          if (responseCode == 401) {
            Constants.toastMessage('$responseCode');
            print(responseCode);
            print(res.statusMessage);
          } else if (responseCode == 422) {
            print("code:$responseCode");
            print("msg:$msg");
            Constants.toastMessage('$responseCode');
          } else if (responseCode == 500) {
            print("code:$responseCode");
            print("msg:$msg");
            Constants.toastMessage(Languages.of(context)!.labelInternalServerError);
          }
          break;
        default:
      }
    });
  }
}
