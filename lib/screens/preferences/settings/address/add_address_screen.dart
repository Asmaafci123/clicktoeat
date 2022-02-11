import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mealup/model/common_response.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/preferences/settings/manage_addresses_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/customs/custom_elevated_button.dart';
import 'package:mealup/utils_google_map/address_search.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:uuid/uuid.dart';

class AddAddressScreen extends StatefulWidget {
  final bool isFromAddAddress;
  final double? currentLat, currentLong;
  final BitmapDescriptor marker;

  const AddAddressScreen({
    Key? key,
    required this.isFromAddAddress,
    required this.currentLat,
    required this.currentLong,
    required this.marker,
  }) : super(key: key);

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final apiKey = Platform.isAndroid ? Constants.androidKey : Constants.iosKey;

  bool isAutoLocateLoading = false;

  late LatLng _initialCameraPosition;
  late GoogleMapController _mapsController;
  BitmapDescriptor _markerIcon = BitmapDescriptor.defaultMarker;

  final TextEditingController _textFullAddress = TextEditingController();

  final TextEditingController _textAddressLabel = TextEditingController();

  String strLongitude = '', strLatitude = '', strSearchedAddress = '', strAddressLabel = '';

  Set<Marker> _createMarker() {
    return <Marker>{
      Marker(
        markerId: const MarkerId("marker_1"),
        position: _initialCameraPosition,
        icon: _markerIcon,
      ),
    };
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapsController = controller;
  }

  @override
  void initState() {
    super.initState();
    _markerIcon = widget.marker;
    _initialCameraPosition = LatLng(widget.currentLat!, widget.currentLong!);
  }

  @override
  Future<void> didUpdateWidget(covariant AddAddressScreen oldWidget) async {
    super.didUpdateWidget(oldWidget);
    // _createMarkerImageFromAsset(context);
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
          resizeToAvoidBottomInset: true,
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(target: _initialCameraPosition, zoom: 13),
                    mapType: MapType.normal,
                    onMapCreated: _onMapCreated,
                    myLocationEnabled: true,
                    markers: _createMarker(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Card(
                        shape: const CircleBorder(),
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Icon(
                            Icons.arrow_back,
                            color: Constants.colorTheme,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.4,
                minChildSize: 0.4,
                maxChildSize: 0.65,
                builder: (context, controller) => Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22.r)),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    controller: controller,
                    child: Padding(
                      padding: EdgeInsets.only(left: 22.w, right: 22.w, bottom: 22.w, top: 10.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 5,
                              width: 50,
                              decoration: ShapeDecoration(
                                shape: const StadiumBorder(),
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                          ),
                          SimpleShadow(
                            opacity: 0.6,
                            color: Colors.black12,
                            offset: const Offset(0, 3),
                            sigma: 5,
                            child: Container(
                              margin: EdgeInsets.only(top: 22.h),
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  final sessionToken = const Uuid().v4();
                                  var result = await showSearch(
                                    context: context,
                                    delegate: AddressSearch(sessionToken),
                                  );
                                  if (result != null) {
                                    setState(() {
                                      String address = '';
                                      address = result.description;
                                      strSearchedAddress = address;
                                      log(result.lat.toString());
                                      log(result.long.toString());
                                      strLongitude = result.long.toString();
                                      strLatitude = result.lat.toString();
                                      _mapsController.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          CameraPosition(target: LatLng(double.parse(strLatitude), double.parse(strLongitude)), zoom: 18),
                                        ),
                                      );
                                      _initialCameraPosition = LatLng(double.parse(strLatitude), double.parse(strLongitude));
                                      _createMarker();
                                    });
                                  }
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 12.w),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8.r),
                                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.search_rounded, color: Constants.colorBlack, size: 18.w),
                                            SizedBox(width: 10.w),
                                            Text(
                                              Languages.of(context)!.labelSearchLocation,
                                              style: TextStyle(color: Constants.colorBlack, fontFamily: Constants.appFont, fontSize: 14.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                      'OR',
                                      style: TextStyle(color: Constants.colorBlack, fontFamily: Constants.appFont, fontSize: 14.sp),
                                    ),
                                    SizedBox(width: 12.w),
                                    InkWell(
                                      onTap: () async {
                                        setState(() {
                                          isAutoLocateLoading = true;
                                        });
                                        var locations = await Geocoder2.getAddressFromCoordinates(
                                          latitude: widget.currentLat ?? 0.0,
                                          longitude: widget.currentLong ?? 0.0,
                                          googleMapApiKey: apiKey,
                                        );
                                        setState(() {
                                          strSearchedAddress = locations.results.first.formattedAddress;
                                          log(locations.results.first.geometry.location.lat.toString());
                                          log(locations.results.first.geometry.location.lng.toString());
                                          strLongitude = locations.results.first.geometry.location.lng.toString();
                                          strLatitude = locations.results.first.geometry.location.lat.toString();
                                          _mapsController.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                              CameraPosition(target: LatLng(double.parse(strLatitude), double.parse(strLongitude)), zoom: 18),
                                            ),
                                          );
                                          _initialCameraPosition = LatLng(double.parse(strLatitude), double.parse(strLongitude));
                                          _createMarker();
                                          isAutoLocateLoading = false;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10.w),
                                        decoration: BoxDecoration(
                                          color: Constants.colorTheme,
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        width: 40.w,
                                        height: 40.w,
                                        child: isAutoLocateLoading
                                            ? CircularProgressIndicator(
                                                strokeWidth: 2,
                                                backgroundColor: Constants.colorTheme,
                                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                                              )
                                            : Icon(
                                                Icons.near_me_rounded,
                                                color: Colors.white,
                                                size: 18.w,
                                              ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: strSearchedAddress.isNotEmpty,
                            child: SimpleShadow(
                              opacity: 0.6,
                              color: Colors.black12,
                              offset: const Offset(0, 3),
                              sigma: 5,
                              child: Container(
                                margin: EdgeInsets.only(top: 22.h),
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                ),
                                child: Text(
                                  'Selected Address: $strSearchedAddress',
                                  style: TextStyle(color: Colors.grey, fontFamily: Constants.appFont),
                                ),
                              ),
                            ),
                          ),
                          SimpleShadow(
                            opacity: 0.6,
                            color: Colors.black12,
                            offset: const Offset(0, 3),
                            sigma: 5,
                            child: Container(
                              margin: EdgeInsets.only(top: 22.h),
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
                                    child: Text(
                                      Languages.of(context)!.labelHouseNo,
                                      style: TextStyle(fontFamily: Constants.appFontBold, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(height: 22.h),
                                  TextField(
                                    controller: _textFullAddress,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration.collapsed(
                                      hintText: Languages.of(context)!.labelTypeFullAddressHere,
                                      border: InputBorder.none,
                                    ),
                                    maxLines: 3,
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
                          SimpleShadow(
                            opacity: 0.6,
                            color: Colors.black12,
                            offset: const Offset(0, 3),
                            sigma: 5,
                            child: Container(
                              margin: EdgeInsets.only(top: 22.h),
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
                                    child: Text(
                                      Languages.of(context)!.labelLandmark,
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontFamily: Constants.appFontBold,
                                        color: Constants.colorBlack,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 22.h),
                                  TextField(
                                    decoration: InputDecoration.collapsed(
                                      hintText: Languages.of(context)!.labelAnyLandmarkNearYourLocation,
                                      border: InputBorder.none,
                                    ),
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
                          SizedBox(height: 22.h),
                          Row(
                            children: [
                              Expanded(
                                child: CustomElevatedButton(
                                  onPressed: () {
                                    if (_textFullAddress.text.isNotEmpty) {
                                      dialogShowDialog();
                                    } else {
                                      Constants.toastMessage('We are missing your complete address, please add one!');
                                    }
                                  },
                                  buttonLabel: widget.isFromAddAddress ? Languages.of(context)!.labelAddAddress : 'Set This & Proceed to Payment',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  dialogShowDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22.r),
          topRight: Radius.circular(22.r),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: EdgeInsets.all(22.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Languages.of(context)!.labelAttachLabel,
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
                Container(
                  margin: EdgeInsets.only(top: 22.h),
                  padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.new_label_rounded, color: Constants.colorTheme, size: 18.w),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.text,
                          controller: _textAddressLabel,
                          decoration: InputDecoration.collapsed(
                            hintText: Languages.of(context)!.labelAddLabelForThisLocation,
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontFamily: Constants.appFont,
                            fontSize: 14.sp,
                            color: Constants.colorBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 22.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                        strSearchedAddress,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14.sp, fontFamily: Constants.appFont, color: Constants.colorBlack),
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
                        Languages.of(context)!.labelCancel,
                        style: TextStyle(color: Constants.colorBlack),
                      ),
                    ),
                    SizedBox(width: 22.w),
                    TextButton(
                      onPressed: () {
                        if (strSearchedAddress.isEmpty) {
                          Constants.toastMessage(Languages.of(context)!.labelPleaseSearchAddress);
                        } else if (_textAddressLabel.text.isEmpty) {
                          Constants.toastMessage(Languages.of(context)!.labelPleaseAddLabelForAddress);
                        } else {
                          String strAddressLabel = _textAddressLabel.text;
                          if (strAddressLabel.trim().isNotEmpty) {
                            callAddUserAddress(strAddressLabel);
                          } else {
                            Constants.toastMessage('Please Add Label For Your Location');
                          }
                        }
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(color: Constants.colorTheme),
                      ),
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

  Future<BaseModel<CommonResponse>> callAddUserAddress(strAddressLabel) async {
    CommonResponse response;
    try {
      Constants.onLoading(context);
      Map<String, String> body = {
        'address': _textFullAddress.text.toString(),
        'lat': strLatitude,
        'lang': strLongitude,
        'type': strAddressLabel,
      };

      response = await RestClient(RetroApi().dioData()).addAddress(body);
      Constants.hideDialog(context);
      log(response.success.toString());
      if (response.success!) {
        Navigator.pop(context);
        Navigator.of(context).pushReplacement(
          Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: const ManageAddressesScreen(),
          ),
        );
      } else {
        Constants.toastMessage(Languages.of(context)!.labelErrorWhileAddAddress);
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      log("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
