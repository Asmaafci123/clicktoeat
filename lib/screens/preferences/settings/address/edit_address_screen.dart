import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mealup/model/update_address_model.dart';
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
import 'package:mealup/utils_google_map/place_service.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class EditAddressScreen extends StatefulWidget {
  final int? addressId, userId;

  final String? strAddress, strAddressType, latitude, longitude;
  BitmapDescriptor? marker = BitmapDescriptor.defaultMarker;
  final double? currentLat, currentLong;

  EditAddressScreen(
      {Key? key,
      required this.addressId,
      required this.currentLat,
      required this.currentLong,
      required this.userId,
      required this.latitude,
      required this.longitude,
      required this.strAddress,
      required this.strAddressType,
      required this.marker})
      : super(key: key);

  @override
  _EditAddressScreenState createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  late LatLng _initialCameraPosition;
  late GoogleMapController _controller;
  BitmapDescriptor? _markerIcon;

  final apiKey = Platform.isAndroid ? Constants.androidKey : Constants.iosKey;

  bool isAutoLocateLoading = false;

  final TextEditingController _textFullAddress = TextEditingController();
  //TextEditingController _textLandmark = new TextEditingController();
  final TextEditingController _textAddressLabel = TextEditingController();

  String? strLongitude = '', strLatitude = '', strSearchedAddress = '', strAddressLabel = '';

  Future<void> _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIcon == null) {
      BitmapDescriptor bitmapDescriptor = await _bitmapDescriptorFromSvgAsset(context, 'assets/ic_marker.svg');
      _updateBitmap(bitmapDescriptor);
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
    ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  void _updateBitmap(BitmapDescriptor bitmap) {
    setState(() {
      _markerIcon = bitmap;
    });
  }

  Set<Marker> _createMarker() {
    return <Marker>{
      Marker(
        markerId: const MarkerId("marker_1"),
        position: _initialCameraPosition,
        icon: widget.marker!,
      ),
    };
  }

  void _onMapCreated(GoogleMapController _controller) {
    this._controller = _controller;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      strLongitude = widget.longitude;
      strLatitude = widget.latitude;
      _initialCameraPosition = LatLng(double.parse(widget.latitude!), double.parse(widget.longitude!));
      strAddressLabel = widget.strAddressType;

      _textAddressLabel.text = strAddressLabel ?? '';
      _textFullAddress.text = widget.strAddress!;
      strSearchedAddress = widget.strAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    _createMarkerImageFromAsset(context);

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
                                  final SuggestionWithLatLong? result = await showSearch(
                                    context: context,
                                    delegate: AddressSearch(sessionToken),
                                  );
                                  if (result != null) {
                                    setState(() {
                                      String address = '';
                                      address = result.description;
                                      strSearchedAddress = address;
                                      print(result.lat.toString());
                                      print(result.long.toString());
                                      strLongitude = result.long.toString();
                                      strLatitude = result.lat.toString();
                                      _controller.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          CameraPosition(target: LatLng(double.parse(strLatitude!), double.parse(strLongitude!)), zoom: 18),
                                        ),
                                      );
                                      _initialCameraPosition = LatLng(double.parse(strLatitude!), double.parse(strLongitude!));
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
                                          print(locations.results.first.geometry.location.lat.toString());
                                          print(locations.results.first.geometry.location.lng.toString());
                                          strLongitude = locations.results.first.geometry.location.lng.toString();
                                          strLatitude = locations.results.first.geometry.location.lat.toString();
                                          _controller.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                              CameraPosition(target: LatLng(double.parse(strLatitude!), double.parse(strLongitude!)), zoom: 18),
                                            ),
                                          );
                                          _initialCameraPosition = LatLng(double.parse(strLatitude!), double.parse(strLongitude!));
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
                            visible: strSearchedAddress?.isNotEmpty ?? false,
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
                                      showLabelBottomSheet();
                                    } else {
                                      Constants.toastMessage('We are missing your complete address, please add one!');
                                    }
                                  },
                                  buttonLabel: Languages.of(context)!.labelEditAddress,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showLabelBottomSheet() {
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
                        strSearchedAddress ?? 'N/A',
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
                        if (strSearchedAddress!.isEmpty || strSearchedAddress == null) {
                          Constants.toastMessage(Languages.of(context)!.labelPleaseSearchAddress);
                        } else if (_textAddressLabel.text.isEmpty) {
                          Constants.toastMessage(Languages.of(context)!.labelPleaseAddLabelForAddress);
                        } else {
                          callUpdateUserAddress(widget.addressId);
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

  Future<BaseModel<UpdateAddressModel>> callUpdateUserAddress(int? addressId) async {
    UpdateAddressModel response;
    try {
      Constants.onLoading(context);
      Map<String, String?> body = {
        'address': strSearchedAddress,
        'lat': strLatitude,
        'lang': strLongitude,
        'type': _textAddressLabel.text,
      };
      response = await RestClient(RetroApi().dioData()).updateAddress(addressId, body);

      Constants.hideDialog(context);
      print(response.success);

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
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
