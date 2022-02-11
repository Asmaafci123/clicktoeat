import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mealup/model/apply_promocode_model.dart';
import 'package:mealup/model/cart_model.dart';
import 'package:mealup/model/cart_tax_modal.dart';
import 'package:mealup/model/common_response.dart';
import 'package:mealup/model/customization_item_model.dart';
import 'package:mealup/model/promo_code_model.dart';
import 'package:mealup/model/single_restaurants_details_model.dart';
import 'package:mealup/model/user_address_list_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/auth/login_screen.dart';
import 'package:mealup/screens/payment_method_screen.dart';
import 'package:mealup/screens/preferences/settings/address/add_address_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:mealup/utils/widgets/database_helper.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:simple_shadow/simple_shadow.dart';

import 'dashboard_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final dbHelper = DatabaseHelper.instance;
  final List<Product> _products = [];
  List<SubMenuListData> cartMenuItem = [];
  List<Map<String, dynamic>> sendAllTax = [];
  String? restName = '', restImage = '';
  double totalPrice = 0, subTotal = 0, tempTotalWithoutDeliveryCharge = 0;
  int? restId;

  final List<PromoCodeListData> _listPromoCode = [];
  final List<UserAddressListData> _userAddressList = [];
  final List<RestaurantsDetailsMenuListData> _listRestaurantsMenu = [];

  final List<DeliveryTimeslot> _listDeliveryTimeSlot = [];
  final List<PickUpTimeslot> _listPickupTimeSlot = [];
  final List<CartTaxModalData> _listOtherTax = [];

  int radioIndex = -1, deliveryTypeIndex = -1;

  int? selectedAddressId;
  String? strSelectedAddress = '';

  int? vendorDiscount, vendorDiscountID;
  String? vendorDiscountMinItemAmount = '', vendorDiscountMaxDiscAmount = '', vendorDiscountType = '', vendorDiscountStartDtEndDt = '', vendorDiscountAvailable = '';

  double otherTaxValue = 0.0;
  double tempOtherTaxTotal = 0.0;
  double tempVar = 0.0;
  double addToFinalTax = 0.0;
  String vandorLat = '';
  String vandorLong = '';

  // double globalTaxDecTotal = 0.0;
  // double globalTaxIncTotal = 0.0;
  double addGlobalTax = 0.0;

  bool calculateTaxFirstTime = true;
  bool inBuildMethodCalculateTaxFirstTime = true;
  bool taxCalDecrementTotal = false;
  bool taxCalIncrementTotal = false;
  bool decTaxInKm = false;
  bool incTaxInKm = false;
  bool isTakeAway = false;
  bool isDelivery = false;
  bool isSetStateAvailable = true;

  String strDeliveryCharges = '';
  String? strOrderSettingDeliveryChargeType = '', strFinalDeliveryCharge = '0.0', strTaxAmount = '', strOtherTaxAmount = '', strTaxPercentage = '';
  bool isPromocodeApplied = false, isTaxApplied = false, isVendorDiscount = false, _isSyncing = false;

  late Position currentLocation;
  double? _currentLatitude;
  double? _currentLongitude;
  BitmapDescriptor? _markerIcon;

  double discountAmount = 0;
  String? appliedCouponName, appliedCouponPercentage, strAppliedPromocodeId = '';
  double vendorDiscountAmount = 0;

  int itemLength = 0;

  @override
  void initState() {
    super.initState();
    _createMarkerImageFromAsset(context);
    _queryNew();
    getUserLocation();

    print('heeee : ${SharedPreferenceUtil.getString('selectedLat1').toString()}');
    print('heeee : ${SharedPreferenceUtil.getString('selectedLng1').toString()}');
  }

  Future<void> _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIcon == null) {
      BitmapDescriptor bitmapDescriptor = await _bitmapDescriptorFromSvgAsset(context, 'assets/ic_marker.svg');
      //  _updateBitmap(bitmapDescriptor);
      setState(() {
        _markerIcon = bitmapDescriptor;
      });
    }
  }

  Future<BitmapDescriptor> _bitmapDescriptorFromSvgAsset(BuildContext context, String assetName) async {
    // Read SVG file as String
    String svgString = await DefaultAssetBundle.of(context).loadString(assetName);
    // Create DrawableRoot from SVG String
    DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, '');

    // toPicture() and toImage() don't seem to be pixel ratio aware, so we calculate the actual sizes here
    MediaQueryData queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;
    double width = 32 * devicePixelRatio; // where 32 is your SVG's original width
    double height = 32 * devicePixelRatio; // same thing

    // Convert to ui.Picture
    ui.Picture picture = svgDrawableRoot.toPicture(size: Size(width, height));

    // Convert to ui.Image. toImage() takes width and height as parameters
    // you need to find the best size to suit your needs and take into account the
    // screen DPI
    ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    ByteData? bytes = await (image.toByteData(format: ui.ImageByteFormat.png));
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  getUserLocation() async {
    currentLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _currentLatitude = currentLocation.latitude;
    _currentLongitude = currentLocation.longitude;
    print('selectedLat $_currentLatitude');
    print('selectedLng $_currentLongitude');
  }

  void _queryNew() async {
    double tempTotal1 = 0, tempTotal2 = 0;
    cartMenuItem.clear();
    _products.clear();
    totalPrice = 0;

    final allRows = await dbHelper.queryAllRows();
    itemLength = allRows.length;
    print('query all rows:');
    for (int j = 0; j < allRows.length; j++) {
      var row = allRows[j];
      print(row);
    }
    setState(() {
      if (allRows.isNotEmpty) {
        for (int i = 0; i < allRows.length; i++) {
          _products.add(Product(
            id: allRows[i]['pro_id'],
            restaurantsName: allRows[i]['restName'],
            title: allRows[i]['pro_name'],
            imgUrl: allRows[i]['pro_image'],
            price: double.parse(allRows[i]['pro_price']),
            qty: allRows[i]['pro_qty'],
            restaurantsId: allRows[i]['restId'],
            restaurantImage: allRows[i]['restImage'],
            foodCustomization: allRows[i]['pro_customization'],
            isCustomization: allRows[i]['isCustomization'],
            isRepeatCustomization: allRows[i]['isRepeatCustomization'],
            itemQty: allRows[i]['itemQty'],
            tempPrice: double.parse(allRows[i]['itemTempPrice'].toString()),
          ));

          restName = allRows[i]['restName'];
          restImage = allRows[i]['restImage'];
          restId = allRows[i]['restId'];
          totalPrice += double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
          print(totalPrice);
          print(restId);
          print(allRows[i]['pro_id']);

          // int isRepeatCustomization = allRows[i]['isRepeatCustomization'];
          /*bool isRepeat;
          if (isRepeatCustomization == 0) {
            isRepeat = false;
          } else {
            isRepeat = true;
          }*/

/*          if (allRows[i]['pro_customization'] == '') {
            cartMenuItem.add(SubMenuListData(
                price: allRows[i]['pro_price'],
                id: allRows[i]['pro_id'],
                name: allRows[i]['pro_name'],
                image: allRows[i]['pro_image'],
                count: allRows[i]['pro_qty'],
                custimization: [],
                isRepeatCustomization: isRepeat,
                isAdded: true));
          } else {
            cartMenuItem.add(SubMenuListData(
                price: allRows[i]['itemTempPrice'].toString(),
                id: allRows[i]['pro_id'],
                name: allRows[i]['pro_name'],
                image: allRows[i]['pro_image'],
                count: allRows[i]['pro_qty'],
                custimization: allRows[i]['pro_customization'],
                isRepeatCustomization: isRepeat,
                isAdded: true));
          }*/

          if (allRows[i]['pro_customization'] == '') {
            totalPrice += double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
            tempTotal1 += double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
          } else {
            totalPrice += double.parse(allRows[i]['pro_price']) + totalPrice;
            tempTotal2 += double.parse(allRows[i]['pro_price']);
          }

          print(totalPrice);
        }

        Constants.checkNetwork().whenComplete(() => callGetRestaurantsDetails(restId, _products));

        Constants.checkNetwork().whenComplete(() => callGetPromocodeListData(restId));
      } else {
        totalPrice = 0;
      }

      print('TempTotal1 $tempTotal1');
      print('TempTotal2 $tempTotal2');
      totalPrice = tempTotal1 + tempTotal2;
      subTotal = totalPrice;
      calculateTax(subTotal);
      if (totalPrice > 0) {
        calculateDeliveryCharge(totalPrice);
      }
    });
  }

  _query() async {
    double tempTotal1 = 0, tempTotal2 = 0;
    cartMenuItem.clear();
    _products.clear();
    totalPrice = 0;

    final allRows = await dbHelper.queryAllRows();
    itemLength = allRows.length;
    print('query all rows:');
    for (var row in allRows) {
      print(row);
    }
    setState(() {
      if (allRows.isNotEmpty) {
        for (int i = 0; i < allRows.length; i++) {
          _products.add(Product(
            id: allRows[i]['pro_id'],
            restaurantsName: allRows[i]['restName'],
            title: allRows[i]['pro_name'],
            imgUrl: allRows[i]['pro_image'],
            price: double.parse(allRows[i]['pro_price']),
            qty: allRows[i]['pro_qty'],
            restaurantsId: allRows[i]['restId'],
            restaurantImage: allRows[i]['restImage'],
            foodCustomization: allRows[i]['pro_customization'],
            isCustomization: allRows[i]['isCustomization'],
            isRepeatCustomization: allRows[i]['isRepeatCustomization'],
            itemQty: allRows[i]['itemQty'],
            tempPrice: double.parse(allRows[i]['itemTempPrice'].toString()),
          ));

          restName = allRows[i]['restName'];
          restImage = allRows[i]['restImage'];
          restId = allRows[i]['restId'];
          totalPrice += double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
          print(totalPrice);
          print(restId);
          print(allRows[i]['pro_id']);

          // int isRepeatCustomization = allRows[i]['isRepeatCustomization'];
          /*  bool isRepeat;
          if (isRepeatCustomization == 0) {
            isRepeat = false;
          } else {
            isRepeat = true;
          }*/

/*          if (allRows[i]['pro_customization'] == '') {
            cartMenuItem.add(SubMenuListData(
                price: allRows[i]['pro_price'],
                id: allRows[i]['pro_id'],
                name: allRows[i]['pro_name'],
                image: allRows[i]['pro_image'],
                count: allRows[i]['pro_qty'],
                custimization: [],
                isRepeatCustomization: isRepeat,
                isAdded: true));
          } else {
            cartMenuItem.add(SubMenuListData(
                price: allRows[i]['itemTempPrice'].toString(),
                id: allRows[i]['pro_id'],
                name: allRows[i]['pro_name'],
                image: allRows[i]['pro_image'],
                count: allRows[i]['pro_qty'],
                custimization: allRows[i]['pro_customization'],
                isRepeatCustomization: isRepeat,
                isAdded: true));
          }*/

          if (allRows[i]['pro_customization'] == '') {
            totalPrice += double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
            tempTotal1 += double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
          } else {
            totalPrice += double.parse(allRows[i]['pro_price']) + totalPrice;
            tempTotal2 += double.parse(allRows[i]['pro_price']);
          }

          print(totalPrice);
        }

        if (_products.isNotEmpty) {
          for (int i = 0; i < _products.length; i++) {
            if (_listRestaurantsMenu.isNotEmpty) {
              for (int j = 0; j < _listRestaurantsMenu.length; j++) {
                for (int k = 0; k < _listRestaurantsMenu[j].submenu!.length; k++) {
                  if (_listRestaurantsMenu[j].submenu![k].id == _products[i].id) {
                    if (_products[i].foodCustomization == '') {
                      cartMenuItem.add(SubMenuListData(
                          price: _products[i].price.toString(),
                          id: _products[i].id,
                          name: _products[i].title,
                          image: _products[i].imgUrl,
                          count: _products[i].qty!,
                          custimization: [],
                          isRepeatCustomization: _products[i].isRepeatCustomization == 0 ? false : true,
                          isAdded: true));
                    } else {
                      cartMenuItem.add(SubMenuListData(
                          price: _products[i].tempPrice.toString(),
                          id: _products[i].id,
                          name: _products[i].title,
                          image: _products[i].imgUrl,
                          count: _products[i].qty!,
                          custimization: _listRestaurantsMenu[j].submenu![k].custimization,
                          isRepeatCustomization: _products[i].isRepeatCustomization == 0 ? false : true,
                          isAdded: true));
                    }
                  }
                }
              }
            }
          }
        }
      } else {
        setState(() {
          totalPrice = 0;
        });
      }

      print('TempTotal1 $tempTotal1');
      print('TempTotal2 $tempTotal2');
      totalPrice = tempTotal1 + tempTotal2;
      tempTotalWithoutDeliveryCharge = totalPrice;

      if (deliveryTypeIndex == 0) {
        if (totalPrice > 0) {
          calculateDeliveryCharge(totalPrice);
        }
      } else {
        setState(() {
          strFinalDeliveryCharge = '0.0';
          subTotal = totalPrice;
          print('calling calculationTax in query function');
          calculateTax(totalPrice);
          if (vendorDiscountAvailable != null) {
            calculateVendorDiscount();
          }
        });
      }
    });
  }

  Future<BaseModel<SingleRestaurantsDetailsModel>> callGetRestaurantsDetails(int? restaurantId, List<Product> _listCart) async {
    SingleRestaurantsDetailsModel response;
    try {
      setState(() {
        _isSyncing = true;
      });

      response = await RestClient(RetroApi().dioData()).singleVendor(restaurantId);
      print(response.success);
      setState(() {
        _isSyncing = false;
      });
      if (response.success!) {
        setState(() {
          _listDeliveryTimeSlot.addAll(response.data!.deliveryTimeslot!);
          _listPickupTimeSlot.addAll(response.data!.pickUpTimeslot!);

          _listRestaurantsMenu.addAll(response.data!.menu!);

          strTaxPercentage = response.data!.vendor!.tax;
          // print('main tax fun calling 2');
          // print('srtTaxPercentage amount $strTaxPercentage');
          double addToMap = 0.0;
          addToMap = subTotal * double.parse(strTaxPercentage!) / 100;
          // print('this is the addition to send all tax $addToMap');
          sendAllTax.add({'tax': addToMap, 'name': 'other tax'});
          getTax();

          if (_listDeliveryTimeSlot.isNotEmpty) {
            selectedAddressId = SharedPreferenceUtil.getInt(Constants.selectedAddressId);
            strSelectedAddress = SharedPreferenceUtil.getString(Constants.selectedAddress);

            if (selectedAddressId == 0) {
              selectedAddressId = null;
            }
            if (strSelectedAddress == '') {
              strSelectedAddress = Languages.of(context)!.labelSelectAddress;
            }

            deliveryTypeIndex = 0;

            var date = DateTime.now();
            print(date.toString()); // prints something like 2019-12-10 10:02:22.287949
            print(DateFormat('EEEE').format(date));
            String day = DateFormat('EEEE').format(date);

            for (int i = 0; i < _listDeliveryTimeSlot.length; i++) {
              if (_listDeliveryTimeSlot[i].status == 1) {
                if (_listDeliveryTimeSlot[i].dayIndex == day) {
                  for (int j = 0; j < _listDeliveryTimeSlot[i].periodList!.length; j++) {
                    String fStartTime = _listDeliveryTimeSlot[i].periodList![j].newStartTime!;
                    String fEndTime = _listDeliveryTimeSlot[i].periodList![j].newEndTime!;
                    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
                    // DateFormat dateFormat = DateFormat("HH:mm: a");

                    DateTime dateTimeStartTime = dateFormat.parse(fStartTime);
                    DateTime dateTimeEndTime = dateFormat.parse(fEndTime);

                    if (isCurrentDateInRange1(dateTimeStartTime, dateTimeEndTime)) {
                      _query();
                    } else {
                      if (j == _listDeliveryTimeSlot[i].periodList!.length - 1) {
                        Constants.toastMessage(Languages.of(context)!.labelDeliveryUnavailable);
                        setState(() {
                          deliveryTypeIndex = -1;
                        });
                      } else {
                        continue;
                      }
                    }
                  }
                }
              }
            }
          }

          print('total price before function calling ${totalPrice.runtimeType}');

          if (response.data!.vendorDiscount != null) {
            vendorDiscountStartDtEndDt = response.data!.vendorDiscount!.startEndDate;
            vendorDiscount = response.data!.vendorDiscount!.discount;
            vendorDiscountID = response.data!.vendorDiscount!.id;
            vendorDiscountMaxDiscAmount = response.data!.vendorDiscount!.maxDiscountAmount;
            vendorDiscountMinItemAmount = response.data!.vendorDiscount!.minItemAmount;
            vendorDiscountType = response.data!.vendorDiscount!.type;

            calculateVendorDiscount();
          } else {
            vendorDiscountAvailable = null;
          }

          if (response.data!.vendor != null) {
            if (response.data!.vendor!.lat != null) {
              vandorLat = response.data!.vendor!.lat!;
              vandorLong = response.data!.vendor!.lang!;
            } else {
              vandorLat = '0.0';
              vandorLong = '0.0';
            }
          } else {
            vandorLat = '0.0';
            vandorLong = '0.0';
          }

          if (_listCart.isNotEmpty) {
            for (int i = 0; i < _listCart.length; i++) {
              if (_listRestaurantsMenu.isNotEmpty) {
                for (int j = 0; j < _listRestaurantsMenu.length; j++) {
                  for (int k = 0; k < _listRestaurantsMenu[j].submenu!.length; k++) {
                    if (_listRestaurantsMenu[j].submenu![k].id == _listCart[i].id) {
                      if (_listCart[i].foodCustomization == '') {
                        cartMenuItem.add(SubMenuListData(
                            price: _listCart[i].price.toString(),
                            id: _listCart[i].id,
                            name: _listCart[i].title,
                            image: _listCart[i].imgUrl,
                            count: _listCart[i].qty!,
                            custimization: [],
                            isRepeatCustomization: _listCart[i].isRepeatCustomization == 0 ? false : true,
                            isAdded: true));
                      } else {
                        cartMenuItem.add(SubMenuListData(
                            price: _listCart[i].tempPrice.toString(),
                            id: _listCart[i].id,
                            name: _listCart[i].title,
                            image: _listCart[i].imgUrl,
                            count: _listCart[i].qty!,
                            custimization: _listRestaurantsMenu[j].submenu![k].custimization,
                            isRepeatCustomization: _listCart[i].isRepeatCustomization == 0 ? false : true,
                            isAdded: true));
                      }
                    }
                  }
                }
              }
            }
          }
        });
      } else {
        Constants.toastMessage('Error while getting details');
      }
    } catch (error, stacktrace) {
      setState(() {
        _isSyncing = false;
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CartTaxModal>> getTax() async {
    CartTaxModal response;
    try {
      setState(() {
        _isSyncing = true;
      });
      response = await RestClient(RetroApi().dioData()).getTax();
      setState(() {
        _isSyncing = false;
      });
      if (response.success!) {
        _listOtherTax.addAll(response.data!);
        otherTax();
      } else {
        Constants.toastMessage('Error while getting details');
      }
    } catch (error, stacktrace) {
      setState(() {
        _isSyncing = false;
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<void> otherTax() async {
    print("how many times i'm calling");
    // print('this is the other tax part ${tempOtherTaxList[0].name}');
    // print('this is the other tax part ${tempOtherTaxList[1].name}');
    final allRows = await dbHelper.queryAllRows();
    itemLength = allRows.length;
    print('query all rows:');
    for (var row in allRows) {
      print(row);
    }
    double getItemPriceFromDb = 0.0;
    double tempTotal1 = 0.0;
    double tempTotal2 = 0.0;
    double valueFromDb = 0.0;
    for (int i = 0; i < allRows.length; i++) {
      tempTotal1 = 0.0;
      tempTotal2 = 0.0;
      if (allRows[i]['pro_customization'] == '') {
        tempTotal1 = double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
      } else {
        tempTotal2 = double.parse(allRows[i]['pro_price']);
      }

      valueFromDb += tempTotal1 + tempTotal2;
    }
    getItemPriceFromDb = valueFromDb;
    for (int i = 0; i < _listOtherTax.length; i++) {
      if (_listOtherTax[i].type == 'percentage') {
        tempVar = getItemPriceFromDb * double.parse(_listOtherTax[i].tax.toString()) / 100;
        sendAllTax.add({
          'tax': tempVar,
          'name': _listOtherTax[i].name,
        });
        print("percentage tax$tempVar");
      } else if (_listOtherTax[i].type == 'amount') {
        tempVar = double.parse(_listOtherTax[i].tax.toString());
        sendAllTax.add({
          'tax': tempVar,
          'name': _listOtherTax[i].name,
        });
        print("amount tax$tempVar");
      }
      tempOtherTaxTotal += tempVar;
      tempVar = 0.0;
      print('total tax $tempOtherTaxTotal');
    }
    print('srtTaxPercentage amount $strTaxPercentage');
    double addToMap = 0.0;
    addToMap = getItemPriceFromDb * double.parse(strTaxPercentage!) / 100;
    print("other tax $tempOtherTaxTotal");
    tempOtherTaxTotal += addToMap;
    double additionToTotal = 0.0;
    if (strTaxAmount != null && strTaxAmount != '') {
      additionToTotal = double.parse(strTaxAmount!) + tempOtherTaxTotal;
      print("new additionToTotal==== $additionToTotal");
    } else {
      additionToTotal = tempOtherTaxTotal;
      print("new additionToTotal $additionToTotal");
    }
    setState(() {
      strTaxAmount = additionToTotal.toString();
      print("new strTaxAmount $strTaxAmount");
      // totalPrice = totalPrice + additionToTotal;
      print("new totalPrice $totalPrice");
    });
  }

  Future<void> decrementTax() async {
    sendAllTax.clear();
    addGlobalTax = 0.0;
    // print('this is the other tax part ${tempOtherTaxList[0].name}');
    // print('this is the other tax part ${tempOtherTaxList[1].name}');
    final allRows = await dbHelper.queryAllRows();
    itemLength = allRows.length;
    print('query all rows:');
    for (var row in allRows) {
      print(row);
    }
    // List<map<String, dynamic>> getItemsFromDb = [];
    double getItemPriceFromDb = 0.0;
    double tempTotal1 = 0.0;
    double tempTotal2 = 0.0;
    double valueFromDb = 0.0;
    for (int i = 0; i < allRows.length; i++) {
      tempTotal1 = 0.0;
      tempTotal2 = 0.0;
      if (allRows[i]['pro_customization'] == '') {
        tempTotal1 = double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
      } else {
        tempTotal2 = double.parse(allRows[i]['pro_price']);
      }
      valueFromDb += tempTotal1 + tempTotal2;
    }
    getItemPriceFromDb = valueFromDb;
    tempOtherTaxTotal = 0.0;
    for (int i = 0; i < _listOtherTax.length; i++) {
      if (_listOtherTax[i].type == 'percentage') {
        tempVar = getItemPriceFromDb * double.parse(_listOtherTax[i].tax.toString()) / 100;
        sendAllTax.add({
          'tax': tempVar,
          'name': _listOtherTax[i].name,
        });
        print("percentage tax$tempVar");
      } else if (_listOtherTax[i].type == 'amount') {
        tempVar = double.parse(_listOtherTax[i].tax.toString());
        sendAllTax.add({
          'tax': tempVar,
          'name': _listOtherTax[i].name,
        });
        print("amount tax$tempVar");
      }
      tempOtherTaxTotal += tempVar;
      tempVar = 0.0;
      print('total tax $tempOtherTaxTotal');
    }
    double addToMap = 0.0;
    addToMap = getItemPriceFromDb * double.parse(strTaxPercentage!) / 100;
    print('this is the addition to send all tax $addToMap');
    sendAllTax.add({'tax': addToMap, 'name': 'other tax'});
    print('srtTaxPercentage amount $strTaxPercentage');
    print("other tax $tempOtherTaxTotal");
    double additionToTotal = 0.0;
    // if (strTaxAmount != null && strTaxAmount != '') {
    // additionToTotal = double.parse(strTaxAmount) + tempOtherTaxTotal;
    // } else {
    additionToTotal = tempOtherTaxTotal + addToMap;
    // additionToTotal = tempOtherTaxTotal + addToMap;
    // globalTaxDecTotal = additionToTotal;
    addGlobalTax = additionToTotal;
    // }
    setState(() {
      taxCalDecrementTotal = true;
      decTaxInKm = true;
      strTaxAmount = additionToTotal.toString();
      totalPrice = totalPrice + additionToTotal;
    });
  }

  Future<void> incrementTax() async {
    sendAllTax.clear();
    addGlobalTax = 0.0;
    // print('this is the other tax part ${tempOtherTaxList[0].name}');
    // print('this is the other tax part ${tempOtherTaxList[1].name}');
    final allRows = await dbHelper.queryAllRows();
    itemLength = allRows.length;
    print('query all rows:');
    for (var row in allRows) {
      print(row);
    }
    // List<map<String, dynamic>> getItemsFromDb = [];
    double getItemPriceFromDb = 0.0;
    double tempTotal1 = 0.0;
    double tempTotal2 = 0.0;
    double valueFromDb = 0.0;
    for (int i = 0; i < allRows.length; i++) {
      tempTotal1 = 0.0;
      tempTotal2 = 0.0;
      if (allRows[i]['pro_customization'] == '') {
        tempTotal1 = double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
      } else {
        tempTotal2 = double.parse(allRows[i]['pro_price']);
      }

      valueFromDb += tempTotal1 + tempTotal2;
    }
    getItemPriceFromDb = valueFromDb;
    tempOtherTaxTotal = 0.0;
    for (int i = 0; i < _listOtherTax.length; i++) {
      if (_listOtherTax[i].type == 'percentage') {
        tempVar = getItemPriceFromDb * double.parse(_listOtherTax[i].tax.toString()) / 100;
        sendAllTax.add({
          'tax': tempVar,
          'name': _listOtherTax[i].name,
        });
        print("percentage tax$tempVar");
      } else if (_listOtherTax[i].type == 'amount') {
        tempVar = double.parse(_listOtherTax[i].tax.toString());
        sendAllTax.add({
          'tax': tempVar,
          'name': _listOtherTax[i].name,
        });
        print("amount tax$tempVar");
      }
      tempOtherTaxTotal += tempVar;
      tempVar = 0.0;
      print('total tax $tempOtherTaxTotal');
    }
    double addToMap = 0.0;
    addToMap = getItemPriceFromDb * double.parse(strTaxPercentage!) / 100;
    print('this is the addition to send all tax $addToMap');
    sendAllTax.add({'tax': addToMap, 'name': 'other tax'});
    print('srtTaxPercentage amount $strTaxPercentage');
    print("other tax $tempOtherTaxTotal");
    double additionToTotal = 0.0;
    // if (strTaxAmount != null && strTaxAmount != '') {
    // additionToTotal = double.parse(strTaxAmount) + tempOtherTaxTotal;
    // } else {
    // additionToTotal = (tempOtherTaxTotal + addToMap);
    additionToTotal = tempOtherTaxTotal + addToMap;
    // additionToTotal = (tempOtherTaxTotal + addToMap);
    // globalTaxIncTotal = additionToTotal;
    addGlobalTax = additionToTotal;
    // }
    setState(() {
      taxCalIncrementTotal = true;
      incTaxInKm = true;
      strTaxAmount = additionToTotal.toString();
      totalPrice = totalPrice + additionToTotal;
    });
  }

  _update(int? proId, int? proQty, String proPrice, String? proImage, String? proName, int? restId, String? restName, String fromWhere) async {
    // row to update
    setState(() {
      _isSyncing = true;
    });
    Map<String, dynamic> row = {
      DatabaseHelper.columnProId: proId,
      DatabaseHelper.columnProImageUrl: proImage,
      DatabaseHelper.columnProName: proName,
      DatabaseHelper.columnProPrice: proPrice,
      DatabaseHelper.columnProQty: proQty,
      DatabaseHelper.columnRestId: restId,
      DatabaseHelper.columnRestName: restName,
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');
    if (fromWhere == "increment") {
      incrementTax();
    } else if (fromWhere == "decrement") {
      print("i'm here outside");
      if (rowsAffected == null) {
        print("i'm here");
        setState(() {
          subTotal = 0;
        });
      }
      decrementTax();
    }
    await _query();
    setState(() {
      _isSyncing = false;
    });
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
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Color(0xFF03041D)),
            elevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: false,
            leading: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: EdgeInsets.only(right: 15.w),
                child: Icon(Icons.arrow_back_ios_rounded, color: Constants.colorBlack, size: 18.w),
              ),
            ),
            title: Column(
              children: [
                Text(
                  Languages.of(context)!.labelYourCart,
                  style: TextStyle(color: const Color(0xFF03041D), fontFamily: Constants.appFont),
                ),
                Text(
                  restName ?? 'N/A',
                  style: TextStyle(color: const Color(0xFF03041D), fontFamily: Constants.appFont, fontSize: 10.sp),
                ),
              ],
            ),
          ),
          bottomNavigationBar: subTotal <= 0 || itemLength <= 0
              ? null
              : GestureDetector(
                  onTap: () {
                    if (SharedPreferenceUtil.getBool(Constants.isLoggedIn)) {
                      if (deliveryTypeIndex == 0) {
                        Constants.checkNetwork().whenComplete(() => callGetUserAddresses());
                      }
                    } else {
                      Navigator.of(context).push(
                        Transitions(
                          transitionType: TransitionType.fade,
                          curve: Curves.bounceInOut,
                          reverseCurve: Curves.fastLinearToSlowEaseIn,
                          widget: const LoginScreen(),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 64.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
                    color: Colors.transparent,
                    child: Container(
                      height: 50.h,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: Constants.colorTheme,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.near_me_rounded, color: Colors.white, size: 18.w),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    () {
                                      if (deliveryTypeIndex == 0) {
                                        return selectedAddressId == null ? Languages.of(context)!.labelSelectAddress : strSelectedAddress;
                                      } else {
                                        return Languages.of(context)!.labelBookOrder;
                                      }
                                    }()!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white, fontFamily: Constants.appFont, fontSize: 10.sp),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.w),
                          InkWell(
                            onTap: () {
                              if (SharedPreferenceUtil.getBool(Constants.isLoggedIn)) {
                                if (SharedPreferenceUtil.getInt(Constants.appSettingIsPickup) == 1) {
                                  if (deliveryTypeIndex == -1) {
                                    Constants.toastMessage('Please select order delivery type.');
                                  } else if (deliveryTypeIndex == 0) {
                                    if (selectedAddressId == null) {
                                      Constants.toastMessage('Please select address for deliver order.');
                                    } else {
                                      getAllData();
                                    }
                                  } else if (deliveryTypeIndex == 1) {
                                    getAllData();
                                  }
                                } else {
                                  if (deliveryTypeIndex == 0) {
                                    if (selectedAddressId == null) {
                                      Constants.toastMessage('Please select address for deliver order.');
                                    } else {
                                      getAllData();
                                    }
                                  } else if (deliveryTypeIndex == -1) {
                                    Constants.toastMessage('Please select order delivery type.');
                                  }
                                }
                              } else {
                                Navigator.of(context).push(
                                  Transitions(
                                    transitionType: TransitionType.fade,
                                    curve: Curves.bounceInOut,
                                    reverseCurve: Curves.fastLinearToSlowEaseIn,
                                    widget: const LoginScreen(),
                                  ),
                                );
                              }
                              isSetStateAvailable = true;
                            },
                            child: Text(
                              'Place Order',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: Constants.appFont,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          body: ModalProgressHUD(
            inAsyncCall: _isSyncing,
            progressIndicator: CircularProgressIndicator.adaptive(
              strokeWidth: 2,
              backgroundColor: Constants.colorTheme.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(Constants.colorTheme),
            ),
            child: (subTotal <= 0 && itemLength <= 0)
                ? Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        LottieBuilder.asset(
                          'animations/empty_restaurant.json',
                          width: 200.w,
                          height: 200.w,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20.h),
                          child: Text(
                            Languages.of(context)!.labelNoData,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: Constants.appFont,
                              color: Constants.colorGray,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22.w),
                          child: Text(
                            'My Cart',
                            style: TextStyle(
                              color: const Color(0xFF03041D),
                              fontSize: 36.sp,
                              fontFamily: Constants.appFontBold,
                              height: 0.9,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        SizedBox(
                          height: cartMenuItem.length > 3 ? 370.h : null,
                          child: ListView.builder(
                            itemCount: cartMenuItem.length,
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 22.w),
                            itemBuilder: (context, position) {
                              return ScopedModelDescendant<CartModel>(
                                builder: (context, child, model) {
                                  return Column(
                                    children: [
                                      if (position == 0) SizedBox(height: 10.h),
                                      SimpleShadow(
                                        opacity: 0.6,
                                        color: Colors.black12,
                                        offset: const Offset(0, 3),
                                        sigma: 10,
                                        child: Container(
                                          height: 130.h,
                                          width: double.infinity,
                                          margin: EdgeInsets.symmetric(vertical: 10.h),
                                          padding: EdgeInsets.all(5.w),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12.r),
                                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8.r),
                                                child: CachedNetworkImage(
                                                  width: 100.w,
                                                  height: 130.w,
                                                  imageUrl: cartMenuItem[position].image!,
                                                  fit: BoxFit.cover,
                                                  progressIndicatorBuilder: (_, __, progress) => Center(
                                                    child: SizedBox(
                                                      width: 38.w,
                                                      height: 38.w,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        backgroundColor: Constants.colorTheme.withOpacity(0.2),
                                                        valueColor: AlwaysStoppedAnimation(Constants.colorTheme),
                                                        value: progress.downloaded.toDouble(),
                                                      ),
                                                    ),
                                                  ),
                                                  errorWidget: (context, url, error) => Center(
                                                    child: ColorFiltered(
                                                      colorFilter: const ColorFilter.mode(
                                                        Colors.white,
                                                        BlendMode.color,
                                                      ),
                                                      child: Image.asset(
                                                        'assets/ic_no_image.png',
                                                        fit: BoxFit.fitHeight,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      cartMenuItem[position].name!,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(fontSize: 18.sp, fontFamily: Constants.appFontBold),
                                                    ),
                                                    if (cartMenuItem[position].custimization!.isNotEmpty) const Spacer(),
                                                    Text(
                                                      'This is the default description of the food item',
                                                      style: TextStyle(fontSize: 12.sp, fontFamily: Constants.appFont, color: Constants.colorGray),
                                                      maxLines: 3,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    if (cartMenuItem[position].custimization!.isNotEmpty) ...[
                                                      const Spacer(),
                                                      GestureDetector(
                                                        onTap: () {
                                                          var ab;
                                                          String? finalFoodCustomization, currentPriceWithoutCustomization;
                                                          // String title;
                                                          double? price, tempPrice;
                                                          // int qty;
                                                          for (int q = 0; q < _listRestaurantsMenu.length; q++) {
                                                            for (int w = 0; w < _listRestaurantsMenu[q].submenu!.length; w++) {
                                                              if (cartMenuItem[position].id == _listRestaurantsMenu[q].submenu![w].id) {
                                                                currentPriceWithoutCustomization = _listRestaurantsMenu[q].submenu![w].price;
                                                              }
                                                            }
                                                          }
                                                          print(currentPriceWithoutCustomization);
                                                          for (int z = 0; z < model.cart.length; z++) {
                                                            if (cartMenuItem[position].id == model.cart[z].id) {
                                                              ab = json.decode(model.cart[z].foodCustomization!);
                                                              finalFoodCustomization = model.cart[z].foodCustomization;
                                                              price = model.cart[z].price;
                                                              //  title = model.cart[z].title;
                                                              //  qty = model.cart[z].qty;
                                                              tempPrice = model.cart[z].tempPrice;
                                                            }
                                                          }
                                                          List<String?> nameOfCustomization = [];
                                                          for (int i = 0; i < ab.length; i++) {
                                                            nameOfCustomization.add(ab[i]['data']['name']);
                                                          }
                                                          print('before starting $price');
                                                          print('before starting tempPrice $tempPrice');
                                                          cartMenuItem[position].isRepeatCustomization = true;
                                                          openFoodCustomizationBottomSheet(model, cartMenuItem[position], double.parse(cartMenuItem[position].price.toString()),
                                                              double.parse(currentPriceWithoutCustomization!), totalPrice, cartMenuItem[position].custimization!, finalFoodCustomization!);
                                                        },
                                                        child: Text(
                                                          'Customizable',
                                                          style: TextStyle(fontSize: 12.sp, fontFamily: Constants.appFont, color: Constants.colorTheme, fontStyle: FontStyle.italic),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      SizedBox(height: 5.h),
                                                    ],
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Rs. ${cartMenuItem[position].price ?? 0}',
                                                          style: TextStyle(fontSize: 16.sp, fontFamily: Constants.appFontBold),
                                                        ),
                                                        Row(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                setState(() async {
                                                                  _isSyncing = true;
                                                                  if (cartMenuItem[position].count > 1) {
                                                                    cartMenuItem[position].count--;
                                                                    model.updateProduct(cartMenuItem[position].id, cartMenuItem[position].count);
                                                                    String? customization, currentPriceWithoutCustomization;
                                                                    for (int z = 0; z < model.cart.length; z++) {
                                                                      if (cartMenuItem[position].id == model.cart[z].id) {
                                                                        customization = model.cart[z].foodCustomization;
                                                                      }
                                                                    }
                                                                    for (int q = 0; q < _listRestaurantsMenu.length; q++) {
                                                                      for (int w = 0; w < _listRestaurantsMenu[q].submenu!.length; w++) {
                                                                        if (cartMenuItem[position].id == _listRestaurantsMenu[q].submenu![w].id) {
                                                                          currentPriceWithoutCustomization = _listRestaurantsMenu[q].submenu![w].price;
                                                                        }
                                                                      }
                                                                    }
                                                                    print(currentPriceWithoutCustomization);

                                                                    if (cartMenuItem[position].custimization!.isNotEmpty) {
                                                                      int isRepeatCustomization = cartMenuItem[position].isRepeatCustomization! ? 1 : 0;
                                                                      _updateForCustomizedFood(
                                                                          cartMenuItem[position].id,
                                                                          cartMenuItem[position].count,
                                                                          double.parse(cartMenuItem[position].price.toString()),
                                                                          currentPriceWithoutCustomization,
                                                                          cartMenuItem[position].image,
                                                                          cartMenuItem[position].name,
                                                                          restId,
                                                                          restName,
                                                                          customization,
                                                                          isRepeatCustomization,
                                                                          1,
                                                                          "decrement");
                                                                    } else {
                                                                      await _update(cartMenuItem[position].id, cartMenuItem[position].count, cartMenuItem[position].price.toString(),
                                                                          cartMenuItem[position].image, cartMenuItem[position].name, restId, restName, "decrement");
                                                                    }
                                                                  } else {
                                                                    cartMenuItem[position].isAdded = false;
                                                                    cartMenuItem[position].count = 0;
                                                                    model.updateProduct(cartMenuItem[position].id, cartMenuItem[position].count);

                                                                    String? customization, currentPriceWithoutCustomization;
                                                                    for (int z = 0; z < model.cart.length; z++) {
                                                                      if (cartMenuItem[position].id == model.cart[z].id) {
                                                                        customization = model.cart[z].foodCustomization;
                                                                      }
                                                                    }
                                                                    for (int q = 0; q < _listRestaurantsMenu.length; q++) {
                                                                      for (int w = 0; w < _listRestaurantsMenu[q].submenu!.length; w++) {
                                                                        if (cartMenuItem[position].id == _listRestaurantsMenu[q].submenu![w].id) {
                                                                          currentPriceWithoutCustomization = _listRestaurantsMenu[q].submenu![w].price;
                                                                        }
                                                                      }
                                                                    }
                                                                    print(currentPriceWithoutCustomization);
                                                                    if (cartMenuItem[position].custimization!.isNotEmpty) {
                                                                      int isRepeatCustomization = cartMenuItem[position].isRepeatCustomization! ? 1 : 0;
                                                                      _updateForCustomizedFood(
                                                                          cartMenuItem[position].id,
                                                                          cartMenuItem[position].count,
                                                                          double.parse(cartMenuItem[position].price.toString()),
                                                                          currentPriceWithoutCustomization,
                                                                          cartMenuItem[position].image,
                                                                          cartMenuItem[position].name,
                                                                          restId,
                                                                          restName,
                                                                          customization,
                                                                          isRepeatCustomization,
                                                                          1,
                                                                          "decrement");
                                                                    } else {
                                                                      await _update(cartMenuItem[position].id, cartMenuItem[position].count, cartMenuItem[position].price.toString(),
                                                                          cartMenuItem[position].image, cartMenuItem[position].name, restId, restName, "decrement");
                                                                    }
                                                                  }
                                                                  _isSyncing = false;
                                                                  // decrementTax();
                                                                });
                                                                print("Total: ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                                                    ScopedModel.of<CartModel>(context, rebuildOnChange: true).totalCartValue.toString() +
                                                                    "");
                                                                print("Cart List" + ScopedModel.of<CartModel>(context, rebuildOnChange: true).cart.toString() + "");
                                                              },
                                                              child: Icon(
                                                                Icons.remove_circle_rounded,
                                                                color: Constants.colorGray,
                                                              ),
                                                            ),
                                                            SizedBox(width: 10.w),
                                                            Text(
                                                              '${cartMenuItem[position].count}',
                                                              style: TextStyle(fontSize: 14.sp, fontFamily: Constants.appFontBold),
                                                            ),
                                                            SizedBox(width: 10.w),
                                                            GestureDetector(
                                                              onTap: () async {
                                                                setState(() async {
                                                                  cartMenuItem[position].count++;
                                                                });
                                                                model.updateProduct(cartMenuItem[position].id, cartMenuItem[position].count);
                                                                print("Total: ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                                                    ScopedModel.of<CartModel>(context, rebuildOnChange: true).totalCartValue.toString() +
                                                                    "");
                                                                print("Cart List" + ScopedModel.of<CartModel>(context, rebuildOnChange: true).cart.toString() + "");
                                                                if (cartMenuItem[position].custimization!.isNotEmpty) {
                                                                  int isRepeatCustomization = cartMenuItem[position].isRepeatCustomization! ? 1 : 0;
                                                                  String? customization, currentPriceWithoutCustomization;
                                                                  for (int z = 0; z < model.cart.length; z++) {
                                                                    if (cartMenuItem[position].id == model.cart[z].id) {
                                                                      customization = model.cart[z].foodCustomization;
                                                                    }
                                                                  }
                                                                  for (int q = 0; q < _listRestaurantsMenu.length; q++) {
                                                                    for (int w = 0; w < _listRestaurantsMenu[q].submenu!.length; w++) {
                                                                      if (cartMenuItem[position].id == _listRestaurantsMenu[q].submenu![w].id) {
                                                                        currentPriceWithoutCustomization = _listRestaurantsMenu[q].submenu![w].price;
                                                                      }
                                                                    }
                                                                  }
                                                                  print(currentPriceWithoutCustomization);
                                                                  _updateForCustomizedFood(
                                                                      cartMenuItem[position].id,
                                                                      cartMenuItem[position].count,
                                                                      double.parse(cartMenuItem[position].price.toString()),
                                                                      currentPriceWithoutCustomization,
                                                                      cartMenuItem[position].image,
                                                                      cartMenuItem[position].name,
                                                                      restId,
                                                                      restName,
                                                                      customization,
                                                                      isRepeatCustomization,
                                                                      1,
                                                                      "increment");
                                                                } else {
                                                                  await _update(cartMenuItem[position].id, cartMenuItem[position].count, cartMenuItem[position].price.toString(),
                                                                      cartMenuItem[position].image, cartMenuItem[position].name, restId, restName, "increment");
                                                                }
                                                                incrementTax();
                                                              },
                                                              child: Icon(
                                                                Icons.add_circle_rounded,
                                                                color: Constants.colorYellow,
                                                              ),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (position == cartMenuItem.length - 1) SizedBox(height: 10.h),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: DashboardScreen(0),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_circle_rounded, size: 20),
                            label: Text(
                              'Add more',
                              style: TextStyle(fontFamily: Constants.appFont, color: Constants.colorWhite, fontSize: 16.sp),
                            ),
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<OutlinedBorder>(const StadiumBorder()),
                              minimumSize: MaterialStateProperty.all<Size>(Size(100.w, 40.h)),
                              backgroundColor: MaterialStateProperty.all<Color>(Constants.colorTheme),
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22.w),
                          child: SimpleShadow(
                            opacity: 0.6,
                            color: Colors.black12,
                            offset: const Offset(0, 3),
                            sigma: 10,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Delivery Options',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 18.sp, fontFamily: Constants.appFontBold),
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  RadioListTile<int>(
                                    value: 0,
                                    groupValue: deliveryTypeIndex,
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    title: Text(
                                      'Delivery',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: Constants.appFont,
                                      ),
                                    ),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedAddressId = SharedPreferenceUtil.getInt(Constants.selectedAddressId);
                                        strSelectedAddress = SharedPreferenceUtil.getString(Constants.selectedAddress);

                                        if (selectedAddressId == 0) {
                                          selectedAddressId = null;
                                        }
                                        if (strSelectedAddress == '') {
                                          strSelectedAddress = Languages.of(context)!.labelSelectAddress;
                                        }

                                        deliveryTypeIndex = 0;

                                        isDelivery = true;

                                        var date = DateTime.now();
                                        print(date.toString()); // prints something like 2019-12-10 10:02:22.287949
                                        print(DateFormat('EEEE').format(date));
                                        String day = DateFormat('EEEE').format(date);

                                        // day = 'Monday';
                                        for (int i = 0; i < _listDeliveryTimeSlot.length; i++) {
                                          if (_listDeliveryTimeSlot[i].status == 1) {
                                            if (_listDeliveryTimeSlot[i].dayIndex == day) {
                                              for (int j = 0; j < _listDeliveryTimeSlot[i].periodList!.length; j++) {
                                                String fstartTime = _listDeliveryTimeSlot[i].periodList![j].newStartTime!;
                                                String fendTime = _listDeliveryTimeSlot[i].periodList![j].newEndTime!;
                                                DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
                                                // DateFormat dateFormat = DateFormat("HH:mm: a");

                                                DateTime dateTimeStartTime = dateFormat.parse(fstartTime);
                                                DateTime dateTimeEndTime = dateFormat.parse(fendTime);

                                                if (isCurrentDateInRange1(dateTimeStartTime, dateTimeEndTime)) {
                                                  _query();
                                                } else {
                                                  if (j == _listDeliveryTimeSlot[i].periodList!.length - 1) {
                                                    Constants.toastMessage(Languages.of(context)!.labelDeliveryUnavailable);
                                                    setState(() {
                                                      deliveryTypeIndex = -1;
                                                    });
                                                  } else {
                                                    continue;
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                        if (isDelivery == true || isTakeAway == true) {
                                          if (tempOtherTaxTotal > 0.0) {
                                            totalPrice += tempOtherTaxTotal;
                                          }
                                          isDelivery = false;
                                          isTakeAway = false;
                                        }
                                      });
                                    },
                                  ),
                                  if (SharedPreferenceUtil.getInt(Constants.appSettingIsPickup) == 1)
                                    RadioListTile<int>(
                                      value: 1,
                                      groupValue: deliveryTypeIndex,
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      title: Text(
                                        'Takeaway',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontFamily: Constants.appFont,
                                        ),
                                      ),
                                      onChanged: (newValue) {
                                        setState(() {
                                          deliveryTypeIndex = 1;
                                          isTakeAway = true;

                                          selectedAddressId = null;
                                          strSelectedAddress = '';

                                          var date = DateTime.now();
                                          print(date.toString()); // prints something like 2019-12-10 10:02:22.287949
                                          print(DateFormat('EEEE').format(date));
                                          String day = DateFormat('EEEE').format(date);

                                          // day = 'Monday';
                                          for (int i = 0; i < _listPickupTimeSlot.length; i++) {
                                            if (_listPickupTimeSlot[i].status == 1) {
                                              if (_listPickupTimeSlot[i].dayIndex == day) {
                                                for (int j = 0; j < _listPickupTimeSlot[i].periodList!.length; j++) {
                                                  String fstartTime = _listPickupTimeSlot[i].periodList![j].newStartTime!;
                                                  String fendTime = _listPickupTimeSlot[i].periodList![j].newEndTime!;
                                                  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
                                                  // DateFormat dateFormat = DateFormat("HH:mm: a");

                                                  DateTime dateTimeStartTime = dateFormat.parse(fstartTime);
                                                  DateTime dateTimeEndTime = dateFormat.parse(fendTime);

                                                  if (isCurrentDateInRange1(dateTimeStartTime, dateTimeEndTime)) {
                                                    // Constants.toastMessage('you can order');
                                                    _query();
                                                  } else {
                                                    if (j == _listPickupTimeSlot[i].periodList!.length - 1) {
                                                      Constants.toastMessage(Languages.of(context)!.labelTakeawayUnavailable);
                                                      setState(() {
                                                        deliveryTypeIndex = -1;
                                                      });
                                                    } else {
                                                      continue;
                                                    }
                                                  }
                                                }
                                              }
                                            } else {
                                              Constants.toastMessage(Languages.of(context)!.labelTakeawayUnavailable);
                                              setState(() {
                                                deliveryTypeIndex = -1;
                                              });
                                            }
                                          }
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22.w),
                          child: SimpleShadow(
                            opacity: 0.6,
                            color: Colors.black12,
                            offset: const Offset(0, 3),
                            sigma: 10,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                              ),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Additional Information',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontFamily: Constants.appFontBold,
                                          color: Constants.colorBlack,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: ' (Optional)',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontFamily: Constants.appFont,
                                              color: Constants.colorGray,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  TextField(
                                    autofocus: false,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      hintText: Languages.of(context)!.labelAddRequestToRest,
                                      hintStyle: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: Constants.appFont,
                                        color: Constants.colorGray,
                                      ),
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFFFFFFF),
                                    ),
                                    maxLines: 4,
                                    style: TextStyle(
                                      fontFamily: Constants.appFont,
                                      fontSize: 14.sp,
                                      color: Constants.colorBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40.h),
                        if (!isPromocodeApplied)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 22.w),
                            child: SimpleShadow(
                              opacity: 0.6,
                              color: Colors.black12,
                              offset: const Offset(0, 3),
                              sigma: 10,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.only(left: 12.w, right: 5.w, top: 5.w, bottom: 5.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      Languages.of(context)!.labelYouHaveCoupon,
                                      style: TextStyle(fontFamily: Constants.appFont, fontSize: 16),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                                            builder: (context) {
                                              return StatefulBuilder(
                                                builder: (context, setState) {
                                                  return SizedBox(
                                                    height: MediaQuery.of(context).size.height * 0.7,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(15.r),
                                                        gradient: const LinearGradient(
                                                          begin: Alignment.topCenter,
                                                          end: Alignment.bottomCenter,
                                                          colors: [
                                                            Color(0xFFFFFFFF),
                                                            Color(0xFFF2F2F4),
                                                            Color(0xFFF2F2F4),
                                                          ],
                                                        ),
                                                      ),
                                                      child: Scaffold(
                                                        backgroundColor: Colors.transparent,
                                                        appBar: AppBar(
                                                          iconTheme: const IconThemeData(color: Color(0xFF03041D)),
                                                          elevation: 0,
                                                          backgroundColor: Colors.transparent,
                                                          automaticallyImplyLeading: false,
                                                          title: Text(
                                                            Languages.of(context)!.labelFoodOfferCoupons,
                                                            style: TextStyle(color: const Color(0xFF03041D), fontFamily: Constants.appFont),
                                                          ),
                                                          actions: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                Navigator.of(context).pop();
                                                              },
                                                              child: Padding(
                                                                padding: EdgeInsets.only(right: 22.w),
                                                                child: Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 28.w),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        body: Column(
                                                          children: [
                                                            Expanded(
                                                              flex: 10,
                                                              child: _listPromoCode.isNotEmpty
                                                                  ? GridView.count(
                                                                      crossAxisCount: 2,
                                                                      crossAxisSpacing: 10,
                                                                      mainAxisSpacing: 10,
                                                                      childAspectRatio: 0.90,
                                                                      padding: const EdgeInsets.all(10),
                                                                      children: List.generate(_listPromoCode.length, (index) {
                                                                        return InkWell(
                                                                          onTap: () {
                                                                            final DateTime now = DateTime.now();
                                                                            final DateFormat formatter = DateFormat('y-MM-dd');
                                                                            final String orderDate = formatter.format(now);
                                                                            isSetStateAvailable = true;
                                                                            if (SharedPreferenceUtil.getBool(Constants.isLoggedIn)) {
                                                                              callApplyPromoCall(context, _listPromoCode[index].name, orderDate, totalPrice, _listPromoCode[index].id);
                                                                            } else {
                                                                              Navigator.of(context).push(
                                                                                Transitions(
                                                                                  transitionType: TransitionType.fade,
                                                                                  curve: Curves.bounceInOut,
                                                                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                                                                  widget: const LoginScreen(),
                                                                                ),
                                                                              );
                                                                            }
                                                                          },
                                                                          child: Card(
                                                                            elevation: 2,
                                                                            shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(20.0),
                                                                            ),
                                                                            child: Column(
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 10),
                                                                                  child: ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(15.0),
                                                                                    child: CachedNetworkImage(
                                                                                      height: ScreenUtil().setHeight(70),
                                                                                      width: ScreenUtil().setWidth(70),
                                                                                      imageUrl: _listPromoCode[index].image!,
                                                                                      fit: BoxFit.cover,
                                                                                      placeholder: (context, url) => SpinKitFadingCircle(color: Constants.colorTheme),
                                                                                      errorWidget: (context, url, error) => Center(child: Image.asset('assets/noimage.png')),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: EdgeInsets.only(top: ScreenUtil().setHeight(12)),
                                                                                  child: Text(
                                                                                    _listPromoCode[index].name!,
                                                                                    style: TextStyle(fontFamily: Constants.appFont, fontSize: ScreenUtil().setSp(14)),
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: EdgeInsets.only(top: ScreenUtil().setHeight(12)),
                                                                                  child: Text(
                                                                                    _listPromoCode[index].promoCode!,
                                                                                    style: TextStyle(
                                                                                      fontFamily: Constants.appFont,
                                                                                      fontSize: ScreenUtil().setSp(18),
                                                                                      letterSpacing: 4,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Text(
                                                                                  _listPromoCode[index].displayText!,
                                                                                  style: TextStyle(fontFamily: Constants.appFont, fontSize: ScreenUtil().setSp(12), color: Constants.colorTheme),
                                                                                ),
                                                                                Padding(
                                                                                  padding: EdgeInsets.only(top: ScreenUtil().setHeight(12)),
                                                                                  child: Text(
                                                                                    '${Languages.of(context)!.labelValidUpTo} ${_listPromoCode[index].startEndDate!.substring(_listPromoCode[index].startEndDate!.indexOf(" - ") + 1)}',
                                                                                    style: TextStyle(color: Constants.colorGray, fontFamily: Constants.appFont, fontSize: ScreenUtil().setSp(12)),
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }),
                                                                    )
                                                                  : Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        LottieBuilder.asset(
                                                                          'animations/empty_restaurant.json',
                                                                          width: 150.w,
                                                                          height: 150.w,
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsets.only(top: 20.h),
                                                                          child: Text(
                                                                            Languages.of(context)!.labelNoOffer,
                                                                            textAlign: TextAlign.center,
                                                                            style: TextStyle(
                                                                              fontSize: 14.sp,
                                                                              fontFamily: Constants.appFont,
                                                                              color: Constants.colorGray,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            });
                                      },
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 85.w, minHeight: 40.h),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.r),
                                          color: Constants.colorTheme,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          Languages.of(context)!.labelApplyIt,
                                          style: TextStyle(fontFamily: Constants.appFont, color: Constants.colorWhite, fontSize: 16.sp),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 40.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22.w),
                          child: SimpleShadow(
                            opacity: 0.6,
                            color: Colors.black12,
                            offset: const Offset(0, 3),
                            sigma: 10,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 22.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        Languages.of(context)!.labelSubtotal,
                                        style: TextStyle(fontFamily: Constants.appFontBold, fontSize: 16.sp),
                                      ),
                                      Text(
                                        "Rs. " + subTotal.toStringAsFixed(2),
                                        style: TextStyle(fontFamily: Constants.appFont, fontSize: 12.sp),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
                                    child: DottedLine(
                                      direction: Axis.horizontal,
                                      dashColor: Constants.colorGray.withOpacity(0.4),
                                    ),
                                  ),
                                  if (isPromocodeApplied) ...[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  Languages.of(context)!.labelAppliedCoupon,
                                                  style: TextStyle(fontFamily: Constants.appFontBold, fontSize: 16.sp),
                                                ),
                                                SizedBox(width: 10.w),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      appliedCouponName = '';
                                                      appliedCouponPercentage = '';
                                                      totalPrice = totalPrice + discountAmount;
                                                      discountAmount = 0;
                                                      isPromocodeApplied = false;
                                                      strAppliedPromocodeId = '';
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.only(right: 22.w),
                                                    child: Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 18.w),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 2.w),
                                            Text(
                                              '$appliedCouponName ($appliedCouponPercentage)',
                                              style: TextStyle(fontFamily: Constants.appFontBold, color: Constants.colorTheme, fontSize: ScreenUtil().setSp(12)),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "- Rs. " + discountAmount.toString(),
                                          style: TextStyle(fontFamily: Constants.appFont, fontSize: 12.sp),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
                                      child: DottedLine(
                                        direction: Axis.horizontal,
                                        dashColor: Constants.colorGray.withOpacity(0.4),
                                      ),
                                    ),
                                  ],
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        Languages.of(context)!.labelDeliveryCharge,
                                        style: TextStyle(fontFamily: Constants.appFontBold, fontSize: 16.sp),
                                      ),
                                      Text(
                                        () {
                                          if (0 < double.parse(strFinalDeliveryCharge!)) {
                                            return "+ Rs. " + double.parse(strFinalDeliveryCharge!).roundToDouble().toString();
                                          } else {
                                            return "+ Rs. 0";
                                          }
                                        }(),
                                        style: TextStyle(fontFamily: Constants.appFont, fontSize: 12.sp),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
                                    child: DottedLine(
                                      direction: Axis.horizontal,
                                      dashColor: Constants.colorGray.withOpacity(0.4),
                                    ),
                                  ),
                                  if (isTaxApplied)
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              Languages.of(context)!.labelTax,
                                              style: TextStyle(fontFamily: Constants.appFontBold, fontSize: 16.sp),
                                            ),
                                            Text(
                                              () {
                                                if (strTaxAmount == "") {
                                                  return "+ Rs. " "0";
                                                } else {
                                                  return "+ Rs. " + double.parse(strTaxAmount!).roundToDouble().toString();
                                                }
                                              }(),
                                              style: TextStyle(fontFamily: Constants.appFont, fontSize: 12.sp),
                                            )
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
                                          child: DottedLine(
                                            direction: Axis.horizontal,
                                            dashColor: Constants.colorGray.withOpacity(0.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (isVendorDiscount)
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              Languages.of(context)!.labelVendorDiscount,
                                              style: TextStyle(fontFamily: Constants.appFontBold, fontSize: 16.sp),
                                            ),
                                            Text(
                                              "- Rs. " + vendorDiscountAmount.toString(),
                                              style: TextStyle(fontFamily: Constants.appFont, fontSize: 12.sp),
                                            )
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
                                          child: DottedLine(
                                            direction: Axis.horizontal,
                                            dashColor: Constants.colorGray.withOpacity(0.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        Languages.of(context)!.labelGrandTotal,
                                        style: TextStyle(fontFamily: Constants.appFontBold, fontSize: 16.sp, color: Constants.colorTheme),
                                      ),
                                      Text(
                                        () {
                                          if (isSetStateAvailable == true) {
                                            if (addGlobalTax == 0.0 && strTaxAmount != '') {
                                              totalPrice += double.parse(strTaxAmount!);
                                              print("new new total is $totalPrice & strtaxamount  $strTaxAmount");
                                            } else {
                                              totalPrice += addGlobalTax;
                                              print("new new total is $totalPrice & addglobaltax  $addGlobalTax");
                                            }
                                          }
                                          if (totalPrice == 0) {
                                            return "Rs. " "0.0";
                                          } else {
                                            return "Rs. " + totalPrice.roundToDouble().toString();
                                          }
                                        }(),
                                        style: TextStyle(fontFamily: Constants.appFont, fontSize: 14.sp, color: Constants.colorTheme),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 44.h),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  showSelectAddressBottomSheet() {
    isSetStateAvailable = false;
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
      ),
      backgroundColor: Colors.white,
      elevation: 5,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, addressSetState) {
            return Padding(
              padding: EdgeInsets.all(22.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      if (_currentLongitude != null) {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          Transitions(
                            transitionType: TransitionType.fade,
                            curve: Curves.bounceInOut,
                            reverseCurve: Curves.fastLinearToSlowEaseIn,
                            widget: AddAddressScreen(
                              isFromAddAddress: false,
                              currentLat: _currentLatitude,
                              currentLong: _currentLongitude,
                              marker: _markerIcon!,
                            ),
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Languages.of(context)!.labelSelectAddress,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: Constants.appFontBold,
                          ),
                        ),
                        GestureDetector(
                          child: const Icon(Icons.cancel_rounded, color: Colors.redAccent),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 22.h),
                      Text(
                        Languages.of(context)!.labelSavedAddress,
                        style: TextStyle(fontFamily: Constants.appFont, fontSize: ScreenUtil().setSp(16)),
                      ),
                      SizedBox(height: 10.h),
                      SizedBox(
                        height: 200.h,
                        child: _userAddressList.isEmpty
                            ? Align(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    LottieBuilder.asset(
                                      'animations/empty_restaurant.json',
                                      width: 200.w,
                                      height: 200.w,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 20.h),
                                      child: Text(
                                        Languages.of(context)!.labelNoData,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontFamily: Constants.appFont,
                                          color: Constants.colorGray,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: _userAddressList.length,
                                itemBuilder: (BuildContext context, int index) => InkWell(
                                  onTap: () {
                                    addressSetState(() {
                                      radioIndex = index;
                                      selectedAddressId = _userAddressList[index].id;
                                      strSelectedAddress = _userAddressList[index].address;

                                      SharedPreferenceUtil.putString('selectedLat1', _userAddressList[index].lat!);
                                      SharedPreferenceUtil.putString('selectedLng1', _userAddressList[index].lang!);
                                      SharedPreferenceUtil.putString(Constants.selectedAddress, _userAddressList[index].address!);

                                      SharedPreferenceUtil.putInt(Constants.selectedAddressId, _userAddressList[index].id);

                                      Navigator.pop(context);
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DashboardScreen(2),
                                          ));

                                      setState(() {});
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 10.h),
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      border: Border.all(color: radioIndex == index ? Constants.colorTheme : Colors.grey.withOpacity(0.3)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          _userAddressList[index].type ?? 'N/A',
                                          style: TextStyle(fontFamily: Constants.appFontBold, fontSize: 16.sp),
                                        ),
                                        SizedBox(height: 10.h),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.public_rounded,
                                              color: Constants.colorTheme,
                                              size: 20.w,
                                            ),
                                            SizedBox(width: 5.w),
                                            Expanded(
                                              child: Text(
                                                _userAddressList[index].address!,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 12.sp, fontFamily: Constants.appFont, color: Constants.colorBlack),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_currentLongitude != null) {
                              Navigator.pop(context);
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  // widget: HereMapDemo())
                                  widget: AddAddressScreen(
                                    isFromAddAddress: false,
                                    currentLat: _currentLatitude,
                                    currentLong: _currentLongitude,
                                    marker: _markerIcon!,
                                  )));
                            }
                          },
                          icon: Icon(Icons.add_location_alt_rounded, size: 20.w),
                          label: Text(
                            Languages.of(context)!.labelAddNewAddress,
                            style: TextStyle(fontFamily: Constants.appFont, fontWeight: FontWeight.w900, color: Constants.colorWhite, fontSize: 16.sp),
                          ),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<OutlinedBorder>(const StadiumBorder()),
                            minimumSize: MaterialStateProperty.all<Size>(Size(100.w, 40.h)),
                            backgroundColor: MaterialStateProperty.all<Color>(Constants.colorTheme),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void openFoodCustomizationBottomSheet(CartModel cartModel, SubMenuListData item, double currentFoodItemPrice, double currentPriceWithoutCustomization, double totalCartAmount,
      List<Custimization> custimization, String previousFoodCustomization) {
    print(currentFoodItemPrice);
    print(item.price);

    double tempPrice = 0;

    List<String> _listForAPI = [];

    var previous = jsonDecode(previousFoodCustomization);
    List<PreviousCustomizationItemModel> _listPreviousCustomization = [];

    _listPreviousCustomization = (previous as List).map((i) => PreviousCustomizationItemModel.fromJson(i)).toList();

    int previousPrice = 0;
    List<String?> previousItemName = [];
    for (int i = 0; i < _listPreviousCustomization.length; i++) {
      previousPrice += int.parse(_listPreviousCustomization[i].datamodel!.price!);
      previousItemName.add(_listPreviousCustomization[i].datamodel!.name);
    }
    print(previousPrice);

    double singleFinal = currentFoodItemPrice - previousPrice;

    List<CustomizationItemModel> _listCustomizationItem = [];
    List<int> _radioButtonFlagList = [];
    List<CustomModel> _listFinalCustomization = [];
    for (int i = 0; i < custimization.length; i++) {
      String? myJSON = custimization[i].customizationItem;
      if (custimization[i].customizationItem != null) {
        var json = jsonDecode(myJSON!);

        _listCustomizationItem = (json as List).map((i) => CustomizationItemModel.fromJson(i)).toList();

        for (int j = 0; j < _listCustomizationItem.length; j++) {
          print(_listCustomizationItem[j].name);
        }
        _listFinalCustomization.add(CustomModel(custimization[i].name, _listCustomizationItem));

        for (int k = 0; k < _listFinalCustomization[i].list.length; k++) {
          for (int z = 0; z < previousItemName.length; z++) {
            if (_listFinalCustomization[i].list[k].name == previousItemName[z]) {
              _listFinalCustomization[i].list[k].isSelected = true;
              _radioButtonFlagList.add(k);
              /*       currentFoodItemPrice +=
                double.parse(_listFinalCustomization[i].list[k].price);*/

              tempPrice += double.parse(_listFinalCustomization[i].list[k].price!);
              _listForAPI.add('{"main_menu":"${_listFinalCustomization[i].title}","data":{"name":"${_listFinalCustomization[i].list[k].name}","price":"${_listFinalCustomization[i].list[k].price}"}}');
            } else {
              _listFinalCustomization[i].list[k].isSelected = false;
            }
          }
        }
        print(_listFinalCustomization.length);
        print('temp ' + tempPrice.toString());
      } else {
        _listFinalCustomization.add(CustomModel(custimization[i].name, _listCustomizationItem));
        continue;
      }

      // _listCustomizationItem.add(CustomizationItemModel(json[i]['name'], json[i]['price'], json[i]['isDefault'], json[i]['status']));
    }

    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SafeArea(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Scaffold(
                    bottomNavigationBar: SizedBox(
                      height: ScreenUtil().setHeight(50),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                color: Constants.colorBlack,
                                child: Center(
                                  child: Text(
                                    '${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} ${singleFinal + tempPrice}',
                                    style: TextStyle(fontFamily: Constants.appFont, color: Colors.white, fontSize: ScreenUtil().setSp(16)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            // ic_green_arrow.svg
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                print('===================Continue with List Data=================');
                                print(_listForAPI.toString());

                                double price = singleFinal + tempPrice;
                                /*CartModel cartModel,
                                    SubMenuListData item,
                                double currentFoodItemPrice,
                                double totalCartAmount,
                                List<Custimization> custimization,
                                String previousFoodCustomization*/
                                int isRepeatCustomization = item.isRepeatCustomization! ? 1 : 0;
                                _updateForCustomizedFood(item.id, item.count, price, currentPriceWithoutCustomization.toString(), item.image, item.name, restId, restName, _listForAPI.toString(),
                                    isRepeatCustomization, 1, "bottomSheet");
                              },
                              child: Container(
                                color: Constants.colorBlack,
                                child: Center(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: Languages.of(context)!.labelContinue,
                                          style: TextStyle(fontFamily: Constants.appFont, color: Colors.white, fontSize: ScreenUtil().setSp(16)),
                                        ),
                                        WidgetSpan(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: SvgPicture.asset(
                                              'assets/ic_green_arrow.svg',
                                              width: 15,
                                              height: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    body: ListView.builder(
                      itemBuilder: (context, outerIndex) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: ScreenUtil().setHeight(20), left: ScreenUtil().setWidth(10)),
                              child: Text(
                                _listFinalCustomization[outerIndex].title!,
                                style: TextStyle(fontSize: 20, fontFamily: Constants.appFontBold),
                              ),
                            ),
                            _listFinalCustomization[outerIndex].list.isNotEmpty
                                ? ListView.builder(
                                    itemBuilder: (context, innerIndex) {
                                      return Padding(
                                          padding: EdgeInsets.only(top: ScreenUtil().setHeight(10), left: ScreenUtil().setWidth(20)),
                                          child: InkWell(
                                            onTap: () {
                                              // changeIndex(index);
                                              print({'On Tap tempPrice : ' + tempPrice.toString()});

                                              if (!_listFinalCustomization[outerIndex].list[innerIndex].isSelected!) {
                                                tempPrice = 0;
                                                _listForAPI.clear();
                                                setState(() {
                                                  _radioButtonFlagList[outerIndex] = innerIndex;
                                                  for (var element in _listFinalCustomization[outerIndex].list) {
                                                    element.isSelected = false;
                                                  }
                                                  _listFinalCustomization[outerIndex].list[innerIndex].isSelected = true;

                                                  for (int i = 0; i < _listFinalCustomization.length; i++) {
                                                    for (int j = 0; j < _listFinalCustomization[i].list.length; j++) {
                                                      if (_listFinalCustomization[i].list[j].isSelected!) {
                                                        tempPrice += double.parse(_listFinalCustomization[i].list[j].price!);

                                                        print(_listFinalCustomization[i].title);
                                                        print(_listFinalCustomization[i].list[j].name);
                                                        print(_listFinalCustomization[i].list[j].isDefault);
                                                        print(_listFinalCustomization[i].list[j].isSelected);
                                                        print(_listFinalCustomization[i].list[j].price);

                                                        _listForAPI.add(
                                                            '{"main_menu":"${_listFinalCustomization[i].title}","data":{"name":"${_listFinalCustomization[i].list[j].name}","price":"${_listFinalCustomization[i].list[j].price}"}}');
                                                        print(_listForAPI.toString());
                                                      }
                                                    }
                                                  }
                                                });
                                              }
                                            },
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _listFinalCustomization[outerIndex].list[innerIndex].name,
                                                      style: TextStyle(fontFamily: Constants.appFont, fontSize: ScreenUtil().setSp(14)),
                                                    ),
                                                    Text(
                                                      SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol) + ' ' + _listFinalCustomization[outerIndex].list[innerIndex].price!,
                                                      style: TextStyle(fontFamily: Constants.appFont, fontSize: ScreenUtil().setSp(14)),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
                                                  child: _radioButtonFlagList[outerIndex] == innerIndex ? getChecked() : getunChecked(),
                                                ),
                                              ],
                                            ),
                                          ));
                                    },
                                    itemCount: _listFinalCustomization[outerIndex].list.length,
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                  )
                                : SizedBox(
                                    height: ScreenUtil().setHeight(100),
                                    child: Center(
                                      child: Text(
                                        'No Customization Data Avaialble.',
                                        style: TextStyle(fontFamily: Constants.appFontBold, fontSize: ScreenUtil().setSp(18)),
                                      ),
                                    ),
                                  )
                          ],
                        );
                      },
                      itemCount: _listFinalCustomization.length,
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  Widget getChecked() {
    return Container(
      width: 25,
      height: 25,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SvgPicture.asset(
          'assets/ic_check.svg',
          width: 15,
          height: 15,
        ),
      ),
      decoration: myBoxDecorationChecked(false, Constants.colorTheme),
    );
  }

  Widget getunChecked() {
    return Container(
      width: 25,
      height: 25,
      decoration: myBoxDecorationChecked(true, Colors.white),
    );
  }

  BoxDecoration myBoxDecorationChecked(bool isBorder, Color color) {
    return BoxDecoration(
      color: color,
      border: isBorder ? Border.all(width: 1.0) : null,
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
    );
  }

  void _updateForCustomizedFood(
    int? proId,
    int proQty,
    double proPrice,
    String? currentPriceWithoutCustomization,
    String? proImage,
    String? proName,
    int? restId,
    String? restName,
    String? customization,
    int isRepeatCustomization,
    int isCustomization,
    String fromWhere,
  ) async {
    double price = proPrice * proQty;
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnProId: proId,
      DatabaseHelper.columnProImageUrl: proImage,
      DatabaseHelper.columnProName: proName,
      DatabaseHelper.columnProPrice: price.toString(),
      DatabaseHelper.columnProQty: proQty,
      DatabaseHelper.columnRestId: restId,
      DatabaseHelper.columnRestName: restName,
      DatabaseHelper.columnProCustomization: customization,
      DatabaseHelper.columnIsRepeatCustomization: isRepeatCustomization,
      DatabaseHelper.columnIsCustomization: isCustomization,
      DatabaseHelper.columnItemTempPrice: proPrice,
      DatabaseHelper.columnCurrentPriceWithoutCustomization: currentPriceWithoutCustomization,
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');

    if (fromWhere == "increment") {
      incrementTax();
    } else if (fromWhere == "decrement") {
      print("hellooooooooo outside");
      if (rowsAffected == null) {
        print("hellooooooooo");
        setState(() {
          subTotal = 0;
        });
      }
      decrementTax();
    }
    _query();
  }

  void getAllData() async {
    String deliveryType = '';
    if (deliveryTypeIndex == 0) {
      deliveryType = 'HOME';
    } else {
      deliveryType = 'SHOP';
    }
    final allRows = await dbHelper.queryAllRows();
    itemLength = allRows.length;
    print('query all rows:');
    for (var row in allRows) {
      print(row);
    }
    if (allRows.isNotEmpty) {
      List<Map<String, dynamic>> item = [];
      String? customization;
      for (int i = 0; i < allRows.length; i++) {
        if (allRows[i]['pro_customization'] == '') {
          print('procustom calling');
          double addToItem;
          addToItem = double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
          item.add({
            'id': allRows[i]['pro_id'],
            'price': addToItem,
            'qty': allRows[i]['pro_qty'],
          });
        } else {
          print('customise calling');
          String addToItem;
          dynamic calculation;
          calculation = allRows[i]['itemTempPrice'] * allRows[i]['pro_qty'];
          addToItem = calculation.toString();
          print('final addToItem is $addToItem');
          item.add({'id': allRows[i]['pro_id'], 'price': addToItem, 'qty': allRows[i]['pro_qty'], 'custimization': jsonEncode(allRows[i]['pro_customization'])});
          customization = allRows[i]['pro_customization'];
        }
      }

      final DateTime now = DateTime.now();
      final DateFormat formatter = DateFormat('y-MM-dd');
      final String orderDate = formatter.format(now);

      String formattedDate = DateFormat('hh:mm a').format(now);
      print('Time' + formattedDate);

      print('new===' + formattedDate.substring(6, 8));

      String aMPM = '';
      if (formattedDate.substring(6, 8) == 'AM') {
        aMPM = 'am';
      } else {
        aMPM = 'pm';
      }
      String formattedDate1 = DateFormat('hh:mm').format(now);

      print('Address $strSelectedAddress');

      print('===================================');
      print('RestId $restId');
      print('Date' + orderDate);
      print('Time' + formattedDate1 + ' $aMPM');
      print('Total amount ' + totalPrice.toString());
      print({'all Food item $item'});
      print('Address id $selectedAddressId');
      if (isVendorDiscount) {
        print('vendorDiscountAmount $vendorDiscountAmount');
        print('vendorDiscountId $vendorDiscountID');
      } else {
        vendorDiscountID = 0;
        vendorDiscountAmount = 0;
      }

      print(tempTotalWithoutDeliveryCharge);

      Navigator.of(context).push(
        Transitions(
          transitionType: TransitionType.fade,
          curve: Curves.bounceInOut,
          reverseCurve: Curves.fastLinearToSlowEaseIn,
          widget: PaymentMethodScreen(
              addressId: selectedAddressId,
              orderAmount: totalPrice.round(),
              orderCustomization: customization,
              orderDate: orderDate,
              orderDeliveryCharge: strFinalDeliveryCharge == '0.0' ? '' : strFinalDeliveryCharge,
              orderItem: item,
              orderDeliveryType: deliveryType,
              orderStatus: 'PENDING',
              orderTime: formattedDate1 + ' $aMPM',
              ordrePromoCode: strAppliedPromocodeId,
              vendorId: restId,
              vendorDiscountAmount: vendorDiscountAmount.toInt(),
              vendorDiscountId: vendorDiscountID,
              strTaxAmount: strTaxAmount,
              allTax: sendAllTax),
        ),
      );
    }
  }

  Future<BaseModel<UserAddressListModel>> callGetUserAddresses() async {
    UserAddressListModel response;
    try {
      _userAddressList.clear();
      Constants.onLoading(context);
      response = await RestClient(RetroApi().dioData()).userAddress();
      print(response.success);
      Constants.hideDialog(context);
      if (response.success!) {
        setState(() {
          _userAddressList.addAll(response.data!);
          if (_userAddressList.isEmpty) {
            setState(() {
              radioIndex = -1;
              selectedAddressId = null;
              strSelectedAddress = '';
            });
          } else {
            setState(() {
              if (selectedAddressId != null) {
                for (int i = 0; i < _userAddressList.length; i++) {
                  if (selectedAddressId == _userAddressList[i].id) {
                    radioIndex = i;
                    SharedPreferenceUtil.putString('selectedLat1', _userAddressList[i].lat!);
                    SharedPreferenceUtil.putString('selectedLng1', _userAddressList[i].lang!);
                  }
                }
              } else {
                radioIndex = -1;
                selectedAddressId = null;
                strSelectedAddress = '';
              }
            });
          }
          showSelectAddressBottomSheet();
        });
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CommonResponse>> callRemoveAddress(int? id) async {
    CommonResponse response;
    try {
      Constants.onLoading(context);
      response = await RestClient(RetroApi().dioData()).removeAddress(id);
      Constants.hideDialog(context);
      print(response.success);
      Constants.hideDialog(context);
      if (response.success!) {
        Navigator.pop(context);
        callGetUserAddresses();
      } else {
        Constants.toastMessage('Error while remove address');
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      setState(() {});
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  void calculateTax(double tempTotalWithoutDeliveryCharge) {
    if (strTaxPercentage!.isNotEmpty && strTaxPercentage != null) {
      isTaxApplied = true;
      if (tempTotalWithoutDeliveryCharge != 0) {
        tempTotalWithoutDeliveryCharge = tempTotalWithoutDeliveryCharge * int.parse(strTaxPercentage!) / 100;
        // tempTotalWithoutDeliveryCharge.roundToDouble();
        setState(() {
          if (calculateTaxFirstTime == true) {
            if (strTaxAmount != null && strTaxAmount != '') {
              double convertToDouble = 0.0;
              convertToDouble = double.parse(strTaxAmount!);
              tempTotalWithoutDeliveryCharge += convertToDouble;
              addToFinalTax = tempTotalWithoutDeliveryCharge;
              strTaxAmount = tempTotalWithoutDeliveryCharge.toString();
            } else {
              strTaxAmount = tempTotalWithoutDeliveryCharge.toString();
              totalPrice = totalPrice + tempTotalWithoutDeliveryCharge;
              setState(() {
                inBuildMethodCalculateTaxFirstTime = true;
              });
            }
          }
          calculateTaxFirstTime = false;
        });
      }
    } else {
      isTaxApplied = true;
    }
  }

  void calculateVendorDiscount() {
    String apiData = vendorDiscountStartDtEndDt!;

    var parts = apiData.split(' - ');
    print('startttttinnngggggggg ${parts[0]}');
    print('startttttinnngggggggg ${parts[1]}');

    DateTime startDate = DateTime.parse(parts[0]);
    DateTime endDate = DateTime.parse(parts[1]);

    DateTime now = DateTime.now();

    print('now: $now');
    print('startDate: $startDate');
    print('endDate: $endDate');
    print(startDate.isBefore(now));
    print(endDate.isAfter(now));

    if (startDate.isBefore(now) && endDate.isAfter(now)) {
      if (tempTotalWithoutDeliveryCharge > double.parse(vendorDiscountMinItemAmount!)) {
        isVendorDiscount = true;

        if (vendorDiscountType == 'percentage') {
          vendorDiscountAmount = tempTotalWithoutDeliveryCharge * vendorDiscount! / 100;
          print(vendorDiscountAmount);
          if (vendorDiscountAmount < double.parse(vendorDiscountMaxDiscAmount!)) {
            vendorDiscountAmount = vendorDiscountAmount;
          } else {
            vendorDiscountAmount = double.parse(vendorDiscountMaxDiscAmount!);
          }
        } else {
          vendorDiscountAmount = vendorDiscount!.toDouble();
          if (vendorDiscountAmount < double.parse(vendorDiscountMaxDiscAmount!)) {
            vendorDiscountAmount = vendorDiscountAmount;
          } else {
            vendorDiscountAmount = double.parse(vendorDiscountMaxDiscAmount!);
          }
        }
        totalPrice = totalPrice - vendorDiscountAmount;
        setState(() {});
      } else {
        isVendorDiscount = false;
      }
    } else {
      isVendorDiscount = false;
    }
  }

  Future<BaseModel<dynamic>> calculateDeliveryCharge(double subtotal) async {
    dynamic response;
    try {
      response = await RestClient(RetroApi().dioData()).orderSetting();
      print(response.success);
      if (response.success!) {
        strOrderSettingDeliveryChargeType = response.data!.deliveryChargeType;

        if (strOrderSettingDeliveryChargeType == 'order_amount') {
          strDeliveryCharges = response.data!.charges;
          List<DeliveryChargesModel> listDeliveryCharge = [];
          var deliveryCharge = jsonDecode(strDeliveryCharges);
          listDeliveryCharge = (deliveryCharge as List).map((i) => DeliveryChargesModel.fromJson(i)).toList();

          for (int i = 0; i < listDeliveryCharge.length; i++) {
            if (double.parse(listDeliveryCharge[i].maxValue!) < subtotal) {
              setState(() {
                strFinalDeliveryCharge = listDeliveryCharge[i].charges;
              });
            }
          }

          setState(() {
            if (decTaxInKm == true) {
              subTotal = subtotal;
              totalPrice = subtotal + double.parse(strFinalDeliveryCharge!);
              tempTotalWithoutDeliveryCharge = subtotal;
              // calculateTax(subtotal);
              setState(() {});
              if (vendorDiscountAvailable != null) {
                calculateVendorDiscount();
              }
              decTaxInKm = false;
            } else if (incTaxInKm == true) {
              subTotal = subtotal;
              totalPrice = subtotal + double.parse(strFinalDeliveryCharge!);
              tempTotalWithoutDeliveryCharge = subtotal;
              // calculateTax(subtotal);
              setState(() {});
              if (vendorDiscountAvailable != null) {
                calculateVendorDiscount();
              }
              incTaxInKm = false;
            } else {
              subTotal = subtotal;
              totalPrice = subtotal + double.parse(strFinalDeliveryCharge!);
              tempTotalWithoutDeliveryCharge = subtotal;
              // calculateTax(subtotal);
              setState(() {});
              if (vendorDiscountAvailable != null) {
                calculateVendorDiscount();
              }
            }
          });
        } else if (strOrderSettingDeliveryChargeType == 'delivery_distance') {
          print('[Selected Lat]: ${SharedPreferenceUtil.getString('selectedLat1')}');
          print('[Selected Lan]: ${SharedPreferenceUtil.getString('selectedLng1')}');
          double userLat = double.parse(SharedPreferenceUtil.getString('selectedLat1') == '' ? '0.0' : SharedPreferenceUtil.getString('selectedLat1')),
              userLong = double.parse(SharedPreferenceUtil.getString('selectedLng1') == '' ? '0.0' : SharedPreferenceUtil.getString('selectedLng1')),
              vendorLat = double.parse(vandorLat),
              vendorLong = double.parse(vandorLong);

          var p = 0.017453292519943295;
          var c = cos;
          var a = 0.5 - c((vendorLat - userLat) * p) / 2 + c(userLat * p) * c(vendorLat * p) * (1 - c((vendorLong - userLong) * p)) / 2;
          var distanceKm1 = 12742 * asin(sqrt(a));
          var distanceKm = distanceKm1.round();

          strDeliveryCharges = response.data!.charges;
          List<DeliveryChargesModel> listDeliveryCharge = [];
          var deliveryCharge = jsonDecode(strDeliveryCharges);
          listDeliveryCharge = (deliveryCharge as List).map((i) => DeliveryChargesModel.fromJson(i)).toList();
          String strFinalDeliveryCharge1 = '';
          for (int i = 0; i < listDeliveryCharge.length; i++) {
            if (distanceKm >= double.parse(listDeliveryCharge[i].minValue!) && distanceKm <= double.parse(listDeliveryCharge[i].maxValue!)) {
              strFinalDeliveryCharge1 = listDeliveryCharge[i].charges!;
            }

            /* if (double.parse(listDeliveryCharge[i].maxValue!) < subtotal) {
              setState(() {
                strFinalDeliveryCharge = listDeliveryCharge[i].charges;
              });
            }*/
          }
          if (strFinalDeliveryCharge1 == '') {
            var max = listDeliveryCharge.reduce((current, next) => int.parse(current.charges!) > int.parse(next.charges!) ? current : next);
            strFinalDeliveryCharge = max.charges!;
          } else if (distanceKm < 1) {
            strFinalDeliveryCharge = '0.0';
          } else {
            strFinalDeliveryCharge = strFinalDeliveryCharge1;
          }

          setState(() {
            if (decTaxInKm == true) {
              subTotal = subtotal;
              totalPrice = subtotal + double.parse(strFinalDeliveryCharge!);
              tempTotalWithoutDeliveryCharge = subtotal;
              // calculateTax(subtotal);
              setState(() {});
              if (vendorDiscountAvailable != null && vendorDiscountAvailable != '') {
                calculateVendorDiscount();
              }
              decTaxInKm = false;
            } else if (incTaxInKm == true) {
              subTotal = subtotal;
              totalPrice = subtotal + double.parse(strFinalDeliveryCharge!);
              tempTotalWithoutDeliveryCharge = subtotal;
              // calculateTax(subtotal);
              setState(() {});
              if (vendorDiscountAvailable != null && vendorDiscountAvailable != '') {
                calculateVendorDiscount();
              }
              incTaxInKm = false;
            } else {
              subTotal = subtotal;
              totalPrice = subtotal + double.parse(strFinalDeliveryCharge!);
              print("new new total is in delivery function $totalPrice new new subtotal is $subtotal");
              tempTotalWithoutDeliveryCharge = subtotal;
              // calculateTax(subtotal);
              setState(() {});
              if (vendorDiscountAvailable != null && vendorDiscountAvailable != '') {
                calculateVendorDiscount();
              }
            }
          });
        }
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }
    } catch (error, stacktrace) {
      setState(() {
        _isSyncing = false;
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<PromoCodeModel>> callGetPromocodeListData(int? restaurantId) async {
    PromoCodeModel response;
    try {
      Constants.onLoading(context);
      _listPromoCode.clear();
      response = await RestClient(RetroApi().dioData()).promoCode(restaurantId);
      print(response.success);
      Constants.hideDialog(context);
      if (response.success!) {
        setState(() {
          _listPromoCode.addAll(response.data!);
        });
        setState(() {});
      } else {
        Constants.toastMessage('Error while remove address');
      }
    } catch (error, stacktrace) {
      setState(() {
        _isSyncing = false;
        Constants.hideDialog(context);
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<String>> callApplyPromoCall(BuildContext context, String? promocodeName, String orderDate, double orderAmount, int? id) async {
    isSetStateAvailable = false;
    String response;
    try {
      Constants.onLoading(context);
      Map<String, String> body = {
        'date': orderDate,
        'amount': orderAmount.toString(),
        'delivery_type': 'delivery',
        'promocode_id': id.toString(),
      };
      response = (await RestClient(RetroApi().dioData()).applyPromoCode(body))!;
      Constants.hideDialog(context);
      print(response);
      final body1 = json.decode(response);
      bool success = body1['success'];
      if (success) {
        Map loginMap = jsonDecode(response.toString());
        var commenRes = ApplyPromoCodeModel.fromJson(loginMap as Map<String, dynamic>);
        calculateDiscount(promocodeName, commenRes.data!.discountType, commenRes.data!.discount, commenRes.data!.flatDiscount, commenRes.data!.isFlat, orderAmount);
        Navigator.pop(context);
        strAppliedPromocodeId = id.toString();
      } else {
        Map loginMap = jsonDecode(response.toString());
        var commenRes = CommonResponse.fromJson(loginMap as Map<String, dynamic>);
        Constants.toastMessage(commenRes.data!);
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  void calculateDiscount(String? promoName, String? discountType, int? discount, int? flatDiscount, int? isFlat, double orderAmount) {
    double tempDisc = 0;
    if (discountType == 'percentage') {
      tempDisc = orderAmount * discount! / 100;
      print('Temp Discount $tempDisc');
      if (isFlat == 1) {
        tempDisc = tempDisc + flatDiscount!;
        print('after flat disc add $tempDisc');
      }

      discountAmount = tempDisc;
      print('Grand Total = ${orderAmount - tempDisc}');
      appliedCouponPercentage = discount.toString() + '%';
      appliedCouponName = promoName;
    } else {
      tempDisc = tempDisc + discount!;

      if (isFlat == 1) {
        tempDisc = tempDisc + flatDiscount!;
      }
      discountAmount = tempDisc;
      print(discountAmount);
      print('Grand Total = ${orderAmount - tempDisc}');
      appliedCouponPercentage = discount.toString();
    }

    appliedCouponName = promoName;
    isPromocodeApplied = true;
    totalPrice = totalPrice - discountAmount;
    setState(() {});
  }

  bool validation() {
    if (selectedAddressId == null) {
      Constants.toastMessage('Please select address for deliver order.');
      return false;
    } else if (deliveryTypeIndex == -1) {
      Constants.toastMessage('Please select address for deliver order.');
      return false;
    } else {
      return true;
    }
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  bool isCurrentDateInRange1(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();
    if (currentDate.isAfter(startDate) && currentDate.isBefore(endDate)) {
      return true;
    }
    return false;
  }

  bool isDeliveryAvaible() {
    selectedAddressId = SharedPreferenceUtil.getInt(Constants.selectedAddressId);
    strSelectedAddress = SharedPreferenceUtil.getString(Constants.selectedAddress);

    if (selectedAddressId == 0) {
      selectedAddressId = null;
    }
    if (strSelectedAddress == '') {
      strSelectedAddress = Languages.of(context)!.labelSelectAddress;
    }

    deliveryTypeIndex = 0;

    var date = DateTime.now();
    print(date.toString());
    print(DateFormat('EEEE').format(date));
    String day = DateFormat('EEEE').format(date);

    for (int i = 0; i < _listDeliveryTimeSlot.length; i++) {
      if (_listDeliveryTimeSlot[i].status == 1) {
        if (_listDeliveryTimeSlot[i].dayIndex == day) {
          for (int j = 0; j < _listDeliveryTimeSlot[i].periodList!.length; j++) {
            String fstartTime = _listDeliveryTimeSlot[i].periodList![j].newStartTime!;
            String fendTime = _listDeliveryTimeSlot[i].periodList![j].newEndTime!;
            DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
            DateTime dateTimeStartTime = dateFormat.parse(fstartTime);
            DateTime dateTimeEndTime = dateFormat.parse(fendTime);
            print('Start Time $dateTimeStartTime');
            print('End Time $dateTimeEndTime');
            if (isCurrentDateInRange1(dateTimeStartTime, dateTimeEndTime)) {
              _query();
            } else {
              if (j == _listDeliveryTimeSlot[i].periodList!.length - 1) {
                Constants.toastMessage(Languages.of(context)!.labelDeliveryUnavailable);
                setState(() {
                  deliveryTypeIndex = -1;
                });
              } else {
                continue;
              }
            }
          }
        }
      }
    }
    return false;
  }

  bool isPickupAvaible() {
    deliveryTypeIndex = 1;

    selectedAddressId = null;
    strSelectedAddress = '';

    var date = DateTime.now();
    print(date.toString()); // prints something like 2019-12-10 10:02:22.287949
    print(DateFormat('EEEE').format(date));
    String day = DateFormat('EEEE').format(date);

    for (int i = 0; i < _listPickupTimeSlot.length; i++) {
      if (_listPickupTimeSlot[i].status == 1) {
        if (_listPickupTimeSlot[i].dayIndex == day) {
          for (int j = 0; j < _listPickupTimeSlot[i].periodList!.length; j++) {
            String fstartTime = _listPickupTimeSlot[i].periodList![j].newStartTime!;
            String fendTime = _listPickupTimeSlot[i].periodList![j].newEndTime!;
            DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
            DateTime dateTimeStartTime = dateFormat.parse(fstartTime);
            DateTime dateTimeEndTime = dateFormat.parse(fendTime);
            if (isCurrentDateInRange1(dateTimeStartTime, dateTimeEndTime)) {
              _query();
              return true;
            } else {
              if (j == _listPickupTimeSlot[i].periodList!.length - 1) {
                Constants.toastMessage(Languages.of(context)!.labelTakeawayUnavailable);
                setState(() {
                  deliveryTypeIndex = -1;
                });
                return false;
              } else {
                continue;
              }
            }
          }
        }
      } else {
        Constants.toastMessage(Languages.of(context)!.labelTakeawayUnavailable);
        setState(() {
          deliveryTypeIndex = -1;
        });
        return false;
      }
    }
    return false;
  }
}

bool isRestaurantOpen(DateTime currentTime, DateTime open, DateTime close) {
  if (open.isBefore(currentTime) && close.isAfter(currentTime)) {
    return true;
  }
  return false;
}

class DeliveryChargesModel {
  String? minValue;
  String? maxValue;
  String? charges;

  DeliveryChargesModel({this.minValue, this.maxValue, this.charges});

  factory DeliveryChargesModel.fromJson(Map<String, dynamic> parsedJson) {
    return DeliveryChargesModel(minValue: parsedJson['min_value'], maxValue: parsedJson['max_value'], charges: parsedJson['charges']);
  }
}

class PreviousCustomizationItemModel {
  String? name;
  DataModel? datamodel;

  PreviousCustomizationItemModel(
    this.name,
    this.datamodel,
  );

  PreviousCustomizationItemModel.fromJson(Map<String, dynamic> json) {
    name = json['main_menu'];
    datamodel = DataModel.fromJson(json['data']);
  }

  // ignore: missing_return
  Map<String, dynamic>? toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['main_menu'] = name;
    data['data'] = datamodel;
  }
}

class DataModel {
  String? name;
  String? price;

  DataModel({this.name, this.price});

  DataModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        price = json['price'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    return data;
  }
}

class TimingSlot {
  String? startTime;
  String? endTime;

  TimingSlot({this.startTime, this.endTime});

  TimingSlot.fromJson(Map<String, dynamic> json)
      : startTime = json['start_time'],
        endTime = json['end_time'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    return data;
  }
}

class CustomModel {
  List<CustomizationItemModel> list = [];
  final String? title;

  CustomModel(this.title, this.list);
}

Widget get rectBorderWidget {
  return DottedBorder(
    dashPattern: const [8, 4],
    strokeWidth: 2,
    color: Constants.colorTheme,
    child: Container(
      height: ScreenUtil().setHeight(200),
      width: ScreenUtil().setWidth(120),
      color: const Color(0xffd4e1db),
    ),
  );
}

Widget get roundedRectBorderWidget {
  return DottedBorder(
    borderType: BorderType.RRect,
    radius: const Radius.circular(12),
    padding: const EdgeInsets.all(6),
    child: ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Container(
        height: ScreenUtil().setHeight(200),
        width: ScreenUtil().setWidth(120),
        color: Colors.amber,
      ),
    ),
  );
}
