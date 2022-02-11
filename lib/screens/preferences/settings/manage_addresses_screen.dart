import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:mealup/model/common_response.dart';
import 'package:mealup/model/user_address_list_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/customs/custom_app_bar_with_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'address/add_address_screen.dart';
import 'address/edit_address_screen.dart';

class ManageAddressesScreen extends StatefulWidget {
  const ManageAddressesScreen({Key? key}) : super(key: key);

  @override
  _ManageAddressesScreenState createState() => _ManageAddressesScreenState();
}

class _ManageAddressesScreenState extends State<ManageAddressesScreen> {
  final List<UserAddressListData> _userAddressList = [];
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool _isSyncing = false;
  late Position currentLocation;
  double _currentLatitude = 0.0;

  double _currentLongitude = 0.0;
  BitmapDescriptor? _markerIcon;

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    Constants.checkNetwork().whenComplete(() => callGetUserAddresses());
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    _createMarkerImageFromAsset(context);
    Constants.checkNetwork().whenComplete(() => callGetUserAddresses());
    getUserLocation();
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
    /// Read SVG file as String
    String svgString = await DefaultAssetBundle.of(context).loadString(assetName);

    /// Create DrawableRoot from SVG String
    DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, '');

    /// toPicture() and toImage() don't seem to be pixel ratio aware, so we calculate the actual sizes here
    MediaQueryData queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;
    double width = 32 * devicePixelRatio; // where 32 is your SVGs original width
    double height = 32 * devicePixelRatio; // same thing

    /// Convert to ui.Picture
    ui.Picture picture = svgDrawableRoot.toPicture(size: Size(width, height));

    /// Convert to ui.Image. toImage() takes width and height as parameters
    /// you need to find the best size to suit your needs and take into account the
    /// screen DPI
    ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    ByteData? bytes = await (image.toByteData(format: ui.ImageByteFormat.png));
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  getUserLocation() async {
    currentLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _currentLatitude = currentLocation.latitude;
    _currentLongitude = currentLocation.longitude;
    log('selectedLat $_currentLatitude');
    log('selectedLng $_currentLongitude');
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
          appBar: CustomAppBarWithButton(
            title: Languages.of(context)!.labelManageYourLocation,
            buttonText: '+ ${Languages.of(context)!.labelAddAddress}',
            buttonColor: Constants.colorTheme,
            onPressed: () {
              if (_currentLongitude != 0.0) {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  Transitions(
                    transitionType: TransitionType.fade,
                    curve: Curves.bounceInOut,
                    reverseCurve: Curves.fastLinearToSlowEaseIn,
                    // widget: HereMapDemo())
                    widget: AddAddressScreen(
                      isFromAddAddress: true,
                      currentLat: _currentLatitude,
                      currentLong: _currentLongitude,
                      marker: _markerIcon!,
                    ),
                  ),
                );
              }
            },
          ),
          body: SmartRefresher(
            enablePullDown: true,
            header: MaterialClassicHeader(
              backgroundColor: Constants.colorTheme,
              color: Constants.colorWhite,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: ModalProgressHUD(
              inAsyncCall: _isSyncing,
              progressIndicator: CircularProgressIndicator.adaptive(
                strokeWidth: 2,
                backgroundColor: Constants.colorTheme.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(Constants.colorTheme),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 10.h, left: 15.w, right: 15.w),
                child: _userAddressList.isEmpty
                    ? !_isSyncing
                        ? SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Spacer(flex: 1),
                                LottieBuilder.asset(
                                  'animations/no_address.json',
                                  width: 250.w,
                                  height: 250.w,
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: 'Your Address List is ',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontFamily: Constants.appFont,
                                      color: Colors.black54,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(text: 'Empty', style: TextStyle(color: Constants.colorTheme, fontFamily: Constants.appFontBold)),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  'You haven\'t added any address.\nPlease add a new address.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: Constants.appFont,
                                    color: Colors.black45,
                                  ),
                                ),
                                SizedBox(height: 20.sp),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      Transitions(
                                        transitionType: TransitionType.fade,
                                        curve: Curves.bounceInOut,
                                        reverseCurve: Curves.fastLinearToSlowEaseIn,
                                        // widget: HereMapDemo())
                                        widget: AddAddressScreen(
                                          isFromAddAddress: true,
                                          currentLat: _currentLatitude,
                                          currentLong: _currentLongitude,
                                          marker: _markerIcon!,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.add_location_alt_rounded, size: 20.w),
                                  label: Text(
                                    'Add location',
                                    style: TextStyle(fontFamily: Constants.appFont, fontWeight: FontWeight.w900, color: Constants.colorWhite, fontSize: 16.sp),
                                  ),
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<OutlinedBorder>(const StadiumBorder()),
                                    minimumSize: MaterialStateProperty.all<Size>(Size(100.w, 40.h)),
                                    backgroundColor: MaterialStateProperty.all<Color>(Constants.colorTheme),
                                  ),
                                ),
                                const Spacer(flex: 2),
                              ],
                            ),
                          )
                        : const SizedBox.shrink()
                    : ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: _userAddressList.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) => Container(
                          margin: EdgeInsets.symmetric(vertical: 10.h),
                          padding: EdgeInsets.only(top: 12.w, left: 12.w, right: 12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(7.w),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                    ),
                                    child: Icon(
                                      Icons.public_rounded,
                                      color: Constants.colorTheme,
                                      size: 20.w,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      _userAddressList[index].type ?? 'N/A',
                                      style: TextStyle(fontFamily: Constants.appFontBold, fontSize: 16.sp, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.w),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _userAddressList[index].address?.replaceAll('\n', ', ') ?? 'N/A',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 12.sp, fontFamily: Constants.appFont, color: Constants.colorBlack),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  ClipOval(
                                    child: Image.asset(
                                      'assets/ic_map_placeholder.png',
                                      width: 50.w,
                                      height: 50.w,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 10.w),
                              Align(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).push(
                                          Transitions(
                                            transitionType: TransitionType.fade,
                                            curve: Curves.bounceInOut,
                                            reverseCurve: Curves.fastLinearToSlowEaseIn,
                                            // widget: HereMapDemo())
                                            widget: EditAddressScreen(
                                              addressId: _userAddressList[index].id,
                                              latitude: _userAddressList[index].lat,
                                              longitude: _userAddressList[index].lang,
                                              strAddress: _userAddressList[index].address,
                                              strAddressType: _userAddressList[index].type,
                                              userId: _userAddressList[index].userId,
                                              marker: _markerIcon,
                                              currentLat: _currentLatitude,
                                              currentLong: _currentLongitude,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        Languages.of(context)!.labelEditAddress,
                                        style: TextStyle(
                                          color: Constants.colorBlack,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 20.w),
                                    TextButton(
                                      onPressed: () {
                                        showRemoveAddressDialog(_userAddressList[index].id, _userAddressList[index].address, _userAddressList[index].type);
                                      },
                                      child: Text(
                                        Languages.of(context)!.labelRemoveThisAddress,
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  showRemoveAddressDialog(int? id, String? address, String? type) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(22.r),
          topLeft: Radius.circular(22.r),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(22.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Languages.of(context)!.labelRemoveAddress,
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
              SizedBox(height: 22.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(7.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Icon(
                      Icons.public_rounded,
                      color: Constants.colorTheme,
                      size: 20.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      type ?? 'N/A',
                      style: TextStyle(fontFamily: Constants.appFontBold, fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      address?.replaceAll('\n', ', ') ?? 'N/A',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.sp, fontFamily: Constants.appFont, color: Constants.colorBlack),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ClipOval(
                    child: Image.asset(
                      'assets/ic_map_placeholder.png',
                      width: 50.w,
                      height: 50.w,
                      fit: BoxFit.cover,
                    ),
                  )
                ],
              ),
              SizedBox(height: 22.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      Languages.of(context)!.labelNoGoBack,
                      style: TextStyle(
                        color: Constants.colorBlack,
                      ),
                    ),
                  ),
                  SizedBox(width: 22.w),
                  TextButton(
                    onPressed: () {
                      callRemoveAddress(id);
                    },
                    child: Text(
                      Languages.of(context)!.labelYesRemoveIt,
                      style: const TextStyle(
                        color: Colors.redAccent,
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
  }

  Future<BaseModel<UserAddressListModel>> callGetUserAddresses() async {
    UserAddressListModel response;
    try {
      _userAddressList.clear();
      setState(() {
        _isSyncing = true;
      });

      response = await RestClient(RetroApi().dioData()).userAddress();
      log(response.success.toString());
      setState(() {
        _isSyncing = false;
      });

      if (response.success!) {
        setState(() {
          _userAddressList.addAll(response.data!);
        });
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }
    } catch (error, stacktrace) {
      setState(() {
        _isSyncing = false;
      });
      log("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CommonResponse>> callRemoveAddress(int? id) async {
    CommonResponse response;
    try {
      Constants.onLoading(context);
      response = await RestClient(RetroApi().dioData()).removeAddress(id);
      log(response.success.toString());
      Constants.hideDialog(context);
      if (response.success!) {
        Navigator.pop(context);
        callGetUserAddresses();
      } else {
        Constants.toastMessage('Error while remove address');
      }
    } catch (error, stacktrace) {
      setState(() {
        _isSyncing = false;
      });
      Constants.hideDialog(context);
      log("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
