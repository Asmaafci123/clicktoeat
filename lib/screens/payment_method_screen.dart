import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mealup/model/cart_model.dart';
import 'package:mealup/model/common_response.dart';
import 'package:mealup/model/payment_setting_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/order_history_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:mealup/utils/widgets/customs/custom_app_bar.dart';
import 'package:mealup/utils/widgets/customs/custom_elevated_button.dart';
import 'package:mealup/utils/widgets/database_helper.dart';
import 'package:scoped_model/scoped_model.dart';

// import 'package:stripe_payment/stripe_payment.dart';

class PaymentMethodScreen extends StatefulWidget {
  final int? vendorId, orderAmount, addressId, vendorDiscountAmount, vendorDiscountId;
  final String? orderDate, orderTime, orderStatus, orderCustomization, ordrePromoCode, orderDeliveryType, strTaxAmount, orderDeliveryCharge;
  // final double orderItem;
  final List<Map<String, dynamic>>? orderItem;
  final List<Map<String, dynamic>>? allTax;

  // final List<String> orderItem;

  const PaymentMethodScreen(
      {Key? key,
      this.vendorId,
      this.orderDeliveryType,
      this.orderDate,
      this.orderTime,
      this.orderAmount,
      this.orderItem,
      this.addressId,
      this.orderDeliveryCharge,
      this.orderStatus,
      this.orderCustomization,
      this.ordrePromoCode,
      this.vendorDiscountAmount,
      this.vendorDiscountId,
      this.strTaxAmount,
      this.allTax})
      : super(key: key);

  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int radioIndex = 0;
  String? orderPaymentType = 'COD';

  final dbHelper = DatabaseHelper.instance;

  // Razorpay _razorpay;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  String strPaymentToken = '';

  String? stripePublicKey;
  String? stripeSecretKey;
  String? stripeToken;
  int? paymentTokenKnow;
  int? paymentStatus;
  String? paymentType;
  String cardNumber = '';
  String cardHolderName = '';
  String expiryDate = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool showSpinner = false;
  int? selectedIndex;

  List<int> listPayment = [];
  List<String> listPaymentName = [];
  List<String> listPaymentImage = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Constants.checkNetwork().whenComplete(() => callGetPaymentSettingAPI());
  }

  Future<BaseModel<PaymentSettingModel>> callGetPaymentSettingAPI() async {
    PaymentSettingModel response;
    setState(() {
      isLoading = true;
    });
    try {
      final dio = Dio();
      dio.options.headers["Accept"] = "application/json";
      dio.options.followRedirects = false;
      dio.options.connectTimeout = 5000; //5s
      dio.options.receiveTimeout = 3000;
      response = await RestClient(dio).paymentSetting();
      print(response.success);

      if (response.success!) {
        if (mounted) {
          setState(() {
            SharedPreferenceUtil.putString(Constants.appPaymentCOD, response.data!.cod.toString());
            if (response.data!.wallet != null) {
              SharedPreferenceUtil.putString(Constants.appPaymentWallet, response.data!.wallet.toString());
            } else {
              SharedPreferenceUtil.putString(Constants.appPaymentWallet, '0');
            }
            if (response.data!.stripe != null) {
              SharedPreferenceUtil.putString(Constants.appPaymentStripe, response.data!.stripe.toString());
            } else {
              SharedPreferenceUtil.putString(Constants.appPaymentStripe, '0');
            }
            if (response.data!.razorpay != null) {
              SharedPreferenceUtil.putString(Constants.appPaymentRazorPay, response.data!.razorpay.toString());
            } else {
              SharedPreferenceUtil.putString(Constants.appPaymentRazorPay, '0');
            }

            if (response.data!.paypal != null) {
              SharedPreferenceUtil.putString(Constants.appPaymentPaypal, response.data!.paypal.toString());
            } else {
              SharedPreferenceUtil.putString(Constants.appPaymentPaypal, '0');
            }

            if (response.data!.stripePublishKey != null) {
              SharedPreferenceUtil.putString(Constants.appStripePublishKey, response.data!.stripePublishKey.toString());
            } else {
              SharedPreferenceUtil.putString(Constants.appStripePublishKey, '0');
            }

            if (response.data!.stripeSecretKey != null) {
              SharedPreferenceUtil.putString(Constants.appStripeSecretKey, response.data!.stripeSecretKey.toString());
            } else {
              SharedPreferenceUtil.putString(Constants.appStripeSecretKey, '0');
            }

            if (response.data!.paypalProduction != null) {
              SharedPreferenceUtil.putString(Constants.appPaypalProduction, response.data!.paypalProduction.toString());
            } else {
              SharedPreferenceUtil.putString(Constants.appPaypalProduction, '0');
            }

            if (response.data!.stripeSecretKey != null) {
              SharedPreferenceUtil.putString(Constants.appPaypalSendBox, response.data!.stripeSecretKey.toString());
            } else {
              SharedPreferenceUtil.putString(Constants.appPaypalSendBox, '0');
            }

            if (response.data!.paypalClientId != null) {
              SharedPreferenceUtil.putString(Constants.appPaypalClientId, response.data!.paypalClientId.toString());
            } else {
              SharedPreferenceUtil.putString(Constants.appPaypalClientId, '0');
            }
            if (response.data!.paypalSecretKey != null) {
              SharedPreferenceUtil.putString(Constants.appPaypalSecretKey, response.data!.paypalSecretKey.toString());
            } else {
              SharedPreferenceUtil.putString(Constants.appPaypalSecretKey, '0');
            }

            if (response.data!.razorpayPublishKey != null) {
              SharedPreferenceUtil.putString(Constants.appRazorpayPublishKey, response.data!.razorpayPublishKey.toString());
            } else {
              SharedPreferenceUtil.putString(Constants.appRazorpayPublishKey, '0');
            }
          });
        }
        if (SharedPreferenceUtil.getString(Constants.appPaymentCOD) == '1') {
          listPayment.add(0);
          listPaymentName.add('Cash on Delivery');
          listPaymentImage.add('assets/cod.svg');
        } else {
          listPayment.remove(0);
          listPaymentName.remove('Cash on delivery');
          listPaymentImage.remove('assets/code.svg');
        }

        if (SharedPreferenceUtil.getString(Constants.appPaymentWallet) == '1') {
          listPayment.add(1);
          listPaymentName.add('MealUp Wallet');
          listPaymentImage.add('assets/wallet.svg');
        } else {
          listPayment.remove(1);
          listPaymentName.remove('MealUp Wallet');
          listPaymentImage.remove('assets/wallet.svg');
        }

        if (SharedPreferenceUtil.getString(Constants.appPaymentStripe) == '1') {
          listPayment.add(2);
          listPaymentName.add('Stripe');
          listPaymentImage.add('assets/ic_stripe.svg');
        } else {
          listPayment.remove(2);
          listPaymentName.remove('Stripe');
          listPaymentImage.remove('assets/ic_stripe.svg');
        }

        if (SharedPreferenceUtil.getString(Constants.appPaymentRazorPay) == '1') {
          listPayment.add(3);
          listPaymentName.add('Rozerpay');
          listPaymentImage.add('assets/ic_rozar_pay.svg');
        } else {
          listPayment.remove(3);
          listPaymentName.remove('Rozerpay');
          listPaymentImage.add('assets/ic_rozar_pay.svg');
        }

        if (SharedPreferenceUtil.getString(Constants.appPaymentPaypal) == '1') {
          listPayment.add(4);
          listPaymentName.add('PayPal');
          listPaymentImage.add('assets/ic_paypal.svg');
        } else {
          listPayment.remove(4);
          listPaymentName.remove('PayPal');
          listPaymentImage.remove('assets/ic_paypal.svg');
        }

        print('listPayment' + listPayment.length.toString());

        // StripePayment.setOptions(StripeOptions(
        //     publishableKey:
        //     SharedPreferenceUtil.getString(Constants.appStripePublishKey),
        //     merchantId: "Test",
        //     androidPayMode: 'test'));
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }
      setState(() {
        isLoading = false;
      });
    } catch (error, stacktrace) {
      setState(() {
        isLoading = false;
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void openCheckout() async {
    var options = {
      'key': SharedPreferenceUtil.getString(Constants.appRazorpayPublishKey),
      'amount': widget.orderAmount! * 100,
      'name': SharedPreferenceUtil.getString(Constants.loginUserName),
      'description': 'Payment',
      'prefill': {'contact': SharedPreferenceUtil.getString(Constants.loginPhone), 'email': SharedPreferenceUtil.getString(Constants.loginEmail)},
      'external': {
        'wallets': ['paytm']
      }
    };
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
          key: _scaffoldKey,
          appBar: CustomAppBar(
            title: Languages.of(context)!.labelPaymentMethod,
          ),
          backgroundColor: const Color(0xFFFAFAFA),
          body: isLoading
              ? Center(
                  child: CircularProgressIndicator.adaptive(
                    strokeWidth: 2,
                    backgroundColor: Constants.colorTheme.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(Constants.colorTheme),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 22.h),
                      ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: listPayment.length,
                        itemBuilder: (BuildContext context, int index) => customRadioList(listPaymentName[index], listPayment[index], listPaymentImage[index]),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: CustomElevatedButton(
                              onPressed: () {
                                if (SharedPreferenceUtil.getInt(Constants.appSettingBusinessAvailability) == 1) {
                                  if (orderPaymentType != null) {
                                    if (orderPaymentType == 'COD') {
                                      placeOrder();
                                    }
                                  } else {
                                    Constants.toastMessage(Languages.of(context)!.labelPleaseSelectPaymentMethod);
                                  }
                                } else {
                                  Constants.toastMessage(Constants.appPaymentCOD);
                                }
                              },
                              buttonLabel: Languages.of(context)!.labelPlaceYourOrder,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 22.h),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void changeIndex(int index) {
    setState(() {
      radioIndex = index;
    });
  }

  Widget customRadioList(String title, int index, String icon) {
    return GestureDetector(
      onTap: () {
        changeIndex(index);
        if (index == 0) {
          orderPaymentType = 'COD';
        } else if (index == 1) {
          orderPaymentType = 'WALLET';
        } else if (index == 2) {
          orderPaymentType = 'STRIPE';
        } else if (index == 3) {
          orderPaymentType = 'RAZOR';
        } else if (index == 4) {
          orderPaymentType = 'PAYPAL';
        }
      },
      child: ListTile(
        tileColor: radioIndex == index ? Constants.colorTheme.withOpacity(0.1) : Constants.colorGray.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: radioIndex == index ? Constants.colorTheme : Constants.colorGray),
          borderRadius: BorderRadius.circular(12.r),
        ),
        leading: Radio<bool>(
          value: radioIndex == index,
          groupValue: radioIndex == index,
          onChanged: (_) {},
        ),
        title: Text(
          title,
          style: TextStyle(fontFamily: Constants.appFontBold, fontSize: 14),
        ),
        subtitle: Text(
          'Payment is made on delivery',
          style: TextStyle(fontFamily: Constants.appFont, fontSize: 12),
        ),
      ),
    );
  }

  // Padding(
  // padding: const EdgeInsets.all(10.0),
  // child: ClipRRect(
  // clipBehavior: Clip.hardEdge,
  // borderRadius: const BorderRadius.all(Radius.circular(5)),
  // child: SizedBox(
  // width: 25.0,
  // height: ScreenUtil().setHeight(25),
  // child: SvgPicture.asset(
  // radioIndex == index ? 'assets/ic_completed.svg' : 'assets/ic_gray.svg',
  // width: 15,
  // height: ScreenUtil().setHeight(15),
  // ),
  // ),
  // ),

  Future<BaseModel<CommonResponse>> placeOrder() async {
    CommonResponse response;
    try {
      Constants.onLoading(context);
      print('without ${json.encode(widget.orderItem.toString())}');
      String item1 = json.encode(widget.orderItem).toString();
      print('with ${item1.toString()}');
      // var json = jsonEncode(widget.orderItem, toEncodable: (e) => e.toString());
      Map<String, dynamic> item = {"id": 11, "price": 200, "qty": 1};

      item = {"id": 10, "price": 195, "qty": 3};

      List<Map<String, dynamic>> temp = [];
      temp.add({'id': 10, 'price': 195, 'qty': 3});
      temp.add({'id': 11, 'price': 200, 'qty': 1});

      print('with $item');
      print('temp without ${json.encode(temp.toString())}');
      print('temp with' + json.encode(temp).toString());

      print('item with' + jsonEncode(item));
      // item.addEntries({"id": 2, "price": 200, "qty": 2});
      print('the amount ${widget.orderAmount.toString()}');
      Map<String, String?> body = {
        'vendor_id': widget.vendorId.toString(),
        'date': widget.orderDate,
        'time': widget.orderTime,
        'item': json.encode(widget.orderItem).toString(),
        // 'item': json.encode(widget.orderItem).toString(),
        // 'item': '[{\'id\':\'11\',\'price\':\'200\',\'qty\':\'1\'},{\'id\':\'10\',\'price\':\'195\',\'qty\':\'3\'}]',
        'amount': widget.orderAmount.toString(),
        'delivery_type': widget.orderDeliveryType,
        'address_id': widget.orderDeliveryType == 'SHOP' ? '' : widget.addressId.toString(),
        'delivery_charge': widget.orderDeliveryCharge,
        'payment_type': orderPaymentType,
        'payment_status': orderPaymentType == 'COD' ? '0' : '1',
        'order_status': widget.orderStatus,
        'custimization': json.encode(widget.orderCustomization).toString(),
        'promocode_id': widget.ordrePromoCode,
        'payment_token': strPaymentToken,
        'vendor_discount_price': widget.vendorDiscountAmount != 0 ? widget.vendorDiscountAmount.toString() : '',
        'vendor_discount_id': widget.vendorDiscountId != 0 ? widget.vendorDiscountId.toString() : '',
        // 'tax': widget.strTaxAmount,
        'tax': json.encode(widget.allTax).toString(),
      };
      response = await RestClient(RetroApi().dioData()).bookOrder(body);
      Constants.hideDialog(context);
      print(response);
      print(response.success);
      if (response.success!) {
        Constants.toastMessage(response.data!);
        _deleteTable();
        ScopedModel.of<CartModel>(context, rebuildOnChange: true).clearCart();
        strPaymentToken = '';
        Navigator.of(context).pushAndRemoveUntil(
            Transitions(
              transitionType: TransitionType.fade,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: const OrderHistoryScreen(
                isFromProfile: false,
              ),
            ),
            (Route<dynamic> route) => true);
      } else {
        if (response.data != null) {
          Constants.toastMessage(response.data!);
        } else {
          Constants.toastMessage('Error while place order.');
        }
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  void _deleteTable() async {
    final table = await dbHelper.deleteTable();
    print('table deleted $table');
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

  Future<BaseModel<CommonResponse>> getWalletBalance() async {
    CommonResponse response;
    try {
      Constants.onLoading(context);
      response = await RestClient(RetroApi().dioData()).getWalletBalance();
      Constants.hideDialog(context);
      if (widget.orderAmount! > int.parse(response.data!)) {
        Constants.toastMessage('Not Enough money in wallet please add first');
      } else {
        placeOrder();
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
