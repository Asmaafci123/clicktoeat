import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:mealup/model/all_cuisines_model.dart';
import 'package:mealup/model/banner_response.dart';
import 'package:mealup/model/common_response.dart';
import 'package:mealup/model/explore_restaurants_list_model.dart';
import 'package:mealup/model/near_by_restaurants_model.dart';
import 'package:mealup/model/non_veg_restaurants_model.dart';
import 'package:mealup/model/top_restaurants_model.dart';
import 'package:mealup/model/veg_restaurants_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/auth/login_screen.dart';
import 'package:mealup/screens/singles/all_cuisine_screen.dart';
import 'package:mealup/screens/singles/all_restaurants_screen.dart';
import 'package:mealup/screens/singles/near_you_restaurants_screen.dart';
import 'package:mealup/screens/singles/popular_restaurants_screen.dart';
import 'package:mealup/screens/singles/single_cuisine_details_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:mealup/utils/widgets/customs/custom_home_app_bar.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:simple_shadow/simple_shadow.dart';

import '../../offer_screen.dart';
import '../../restaurant_details/restaurants_details_screen.dart';
import '../../search_screen.dart';
import '../../set_location_screen.dart';

class FoodHomeScreen extends StatefulWidget {
  const FoodHomeScreen({Key? key}) : super(key: key);

  @override
  _FoodHomeScreenState createState() => _FoodHomeScreenState();
}

class _FoodHomeScreenState extends State<FoodHomeScreen> {
  final List<AllCuisineData> _allCuisineListData = [];
  final List<NearByRestaurantListData> _nearbyListData = [];
  final List<VegRestaurantListData> _vegListData = [];
  final List<TopRestaurantsListData> _topListData = [];
  final List<NonVegRestaurantListData> _nonvegListData = [];
  final List<ExploreRestaurantsListData> _allRestaurantsListData = [];
  List<Data> bannerList = [];
  List<String?> restaurantsFood = [];
  List<String?> vegRestaurantsFood = [];
  List<String?> nonVegRestaurantsFood = [];
  List<String?> topRestaurantsFood = [];
  List<String?> exploreRestaurantsFood = [];

  late ScrollController _scrollController;

  bool _visibility = true;

  late LatLng _center;
  bool _isSyncing = false;
  late Position currentLocation;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  bool isBusinessAvailable = true;

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()

    getUserLocation();

    Constants.checkNetwork().whenComplete(() => callAllCuisine());
    Constants.checkNetwork().whenComplete(() => callVegRestaurants());
    Constants.checkNetwork().whenComplete(() => callTopRestaurants());
    Constants.checkNetwork().whenComplete(() => callNonVegRestaurants());
    Constants.checkNetwork().whenComplete(() => callExploreRestaurants());

    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  var aspectRatio = 0.0;
  int _current = 0;

  Future<Position> locateUser() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    if (permission.index == 2 || permission.index == 3) {
      return Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } else {
      throw 'Location not allowed';
    }
  }

  getOneSingleToken(String appId) async {
    String? userId = '';
    /*var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };*/
    OneSignal.shared.consentGranted(true);
    await OneSignal.shared.setAppId(appId);
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    await OneSignal.shared
        .promptUserForPushNotificationPermission(fallbackToSettings: true);
    await OneSignal.shared.promptLocationPermission();
    // OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
    var status =
        await (OneSignal.shared.getDeviceState() as FutureOr<OSDeviceState>);
    // var pushToken = await status.subscriptionStatus.pushToken;
    userId = status.userId;
    print("pushToken1:$userId");
    SharedPreferenceUtil.putString(Constants.appPushOneSingleToken, userId!);
    /* if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken).isEmpty) {
      getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
    }*/
  }

  getUserLocation() async {
    setState(() {
      _isSyncing = true;
    });
    currentLocation = await locateUser();
    if (mounted) {
      setState(() {
        _center = LatLng(currentLocation.latitude, currentLocation.longitude);
      });
    }
    SharedPreferenceUtil.putString('selectedLat', _center.latitude.toString());
    SharedPreferenceUtil.putString('selectedLng', _center.longitude.toString());
    Constants.checkNetwork()
        .whenComplete(() async => await callNearByRestaurants());
    print('center $_center');
    print('selectedLat ${_center.latitude}');
    print('selectedLng ${_center.longitude}');
    setState(() {
      _isSyncing = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _visibility = _isSliverAppBarExpanded ? false : true;
        });
      });

    SharedPreferenceUtil.getInt(Constants.appSettingBusinessAvailability) == 1
        ? isBusinessAvailable = false
        : isBusinessAvailable = true;
    if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken)
        .isEmpty) {
      getOneSingleToken(
          SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
    }
    getUserLocation();

    Constants.checkNetwork().whenComplete(() => callAllCuisine());

    Constants.checkNetwork().whenComplete(() => callVegRestaurants());
    Constants.checkNetwork().whenComplete(() => callTopRestaurants());
    Constants.checkNetwork().whenComplete(() => callNonVegRestaurants());
    Constants.checkNetwork().whenComplete(() => callExploreRestaurants());
    Constants.checkNetwork().whenComplete(() => getBanners());
  }

  bool get _isSliverAppBarExpanded {
    return _scrollController.hasClients &&
        _scrollController.offset > (194.h - kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/backgrounds/ic_home_background.jpg'),
            alignment: Alignment.topCenter),
      ),
      child: SafeArea(
        child: Scaffold(
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
              color: Colors.grey.withOpacity(0.1),
              progressIndicator: CircularProgressIndicator.adaptive(
                strokeWidth: 2,
                backgroundColor: Constants.colorTheme.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(Constants.colorTheme),
              ),
              child: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 250.h,
                      pinned: true,
                      snap: false,
                      floating: false,
                      forceElevated: true,
                      backgroundColor: const Color(0xFF252627),
                      centerTitle: false,
                      automaticallyImplyLeading: false,
                      title: CustomHomeAppBar(
                        isFilter: false,
                        onOfferTap: () {
                          Navigator.of(context).push(
                            Transitions(
                              transitionType: TransitionType.fade,
                              curve: Curves.bounceInOut,
                              reverseCurve: Curves.fastLinearToSlowEaseIn,
                              widget: const OfferScreen(),
                            ),
                          );
                        },
                        onSearchTap: () {
                          Navigator.of(context).push(
                            Transitions(
                              transitionType: TransitionType.fade,
                              curve: Curves.bounceInOut,
                              reverseCurve: Curves.fastLinearToSlowEaseIn,
                              widget: SearchScreen(),
                            ),
                          );
                        },
                        onLocationTap: () {
                          if (SharedPreferenceUtil.getBool(
                                  Constants.isLoggedIn) ==
                              true) {
                            Navigator.of(context).push(
                              Transitions(
                                transitionType: TransitionType.none,
                                curve: Curves.bounceInOut,
                                reverseCurve: Curves.fastLinearToSlowEaseIn,
                                widget: SetLocationScreen(),
                              ),
                            );
                          } else {
                            if (!SharedPreferenceUtil.getBool(
                                Constants.isLoggedIn)) {
                              Future.delayed(
                                const Duration(seconds: 0),
                                () => Navigator.of(context).pushAndRemoveUntil(
                                    Transitions(
                                      transitionType: TransitionType.fade,
                                      curve: Curves.bounceInOut,
                                      reverseCurve:
                                          Curves.fastLinearToSlowEaseIn,
                                      widget: const LoginScreen(),
                                    ),
                                    (Route<dynamic> route) => false),
                              );
                            }
                          }
                        },
                        selectedAddress: SharedPreferenceUtil.getString(
                                    Constants.selectedAddress)
                                .isEmpty
                            ? ''
                            : SharedPreferenceUtil.getString(
                                Constants.selectedAddress),
                      ),
                      bottom: _visibility
                          ? BottomCarousel(
                              visibility: _visibility, bannerList: bannerList)
                          : null,
                      stretchTriggerOffset: 100.h,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Image.asset(
                          'assets/backgrounds/ic_home_background.jpg',
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ];
                },
                body: ListView(
                  children: [
                    Visibility(
                      visible: isBusinessAvailable,
                      child: Container(
                        margin:
                            EdgeInsets.only(bottom: ScreenUtil().setHeight(15)),
                        decoration:
                            BoxDecoration(color: Constants.colorLikeLight),
                        child: ListTile(
                          leading: SvgPicture.asset(
                            'assets/ic_information.svg',
                            width: ScreenUtil().setWidth(25),
                            height: ScreenUtil().setHeight(25),
                            color: Constants.colorLike,
                          ),
                          title: Text(
                            SharedPreferenceUtil.getString(
                                Constants.appSettingBusinessMessage),
                            style: TextStyle(
                                color: Constants.colorLike,
                                fontSize: ScreenUtil().setSp(14),
                                fontFamily: Constants.appFontBold),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 22.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 22.h),
                          Text(
                            'Food',
                            style: TextStyle(
                              color: const Color(0xFF03041D),
                              fontSize: 36.sp,
                              fontFamily: Constants.appFontBold,
                              height: 0.9,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            'Food for your mood.',
                            style: TextStyle(
                              color: const Color(0xFF03041D),
                              fontSize: 14.sp,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 22.h),
                          ..._buildAllRestaurants(),
                        ],
                      ),
                    ),
                    SizedBox(height: 22.h),
                    ..._buildPopularRestaurants(),
                    SizedBox(height: 10.h),
                    ..._buildBrowsByMeal(),
                    SizedBox(height: 22.h),
                    ..._buildNearMe(),
                    SizedBox(height: 22.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNearMe() {
    return [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Languages.of(context)!.labelNearYou,
              style: TextStyle(
                fontSize: 18.sp,
                fontFamily: Constants.appFontBold,
                color: Constants.colorTheme,
              ),
            ),
            if (_nearbyListData.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    Transitions(
                      transitionType: TransitionType.fade,
                      curve: Curves.bounceInOut,
                      reverseCurve: Curves.fastLinearToSlowEaseIn,
                      widget: const NearYouRestaurantsScreen(),
                    ),
                  );
                },
                child: Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: Constants.appFontBold,
                    color: const Color(0xFF03041D),
                  ),
                ),
              ),
          ],
        ),
      ),
      _nearbyListData.isEmpty
          ? !_isSyncing
              ? Column(
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
                        Languages.of(context)!.labelNoRestNear,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: Constants.appFont,
                          color: Constants.colorGray,
                        ),
                      ),
                    )
                  ],
                )
              : const SizedBox.shrink()
          : Container(
              height: 255.h,
              alignment: Alignment.center,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 22.w),
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount:
                    _nearbyListData.length > 10 ? 10 : _nearbyListData.length,
                itemBuilder: (BuildContext context, int index) {
                  return Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          Transitions(
                            transitionType: TransitionType.fade,
                            curve: Curves.bounceInOut,
                            reverseCurve: Curves.fastLinearToSlowEaseIn,
                            widget: RestaurantsDetailsScreen(
                              restaurantId: _nearbyListData[index].id,
                              isFav: _nearbyListData[index].like,
                              strRestaurantsAvgTime: _nearbyListData[index]
                                  .avgDeliveryTime
                                  .toString(),
                            ),
                          ),
                        );
                      },
                      child: SimpleShadow(
                        opacity: 0.6,
                        color: Colors.black12,
                        offset: const Offset(0, 0),
                        sigma: 10,
                        child: Container(
                          height: 210.h,
                          width: 230.h,
                          margin: EdgeInsets.only(right: 22.w),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: CachedNetworkImage(
                                      height: 130.h,
                                      width: double.infinity,
                                      imageUrl: _nearbyListData[index].image!,
                                      fit: BoxFit.cover,
                                      progressIndicatorBuilder:
                                          (_, __, progress) => Center(
                                        child: SizedBox(
                                          width: 38.w,
                                          height: 38.w,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            backgroundColor: Constants
                                                .colorTheme
                                                .withOpacity(0.2),
                                            valueColor: AlwaysStoppedAnimation(
                                                Constants.colorTheme),
                                            value:
                                                progress.downloaded.toDouble(),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Center(
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
                                  Container(
                                    height: 130.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.r),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          Colors.black54,
                                          Colors.black12,
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (SharedPreferenceUtil.getBool(
                                          Constants.isLoggedIn)) {
                                        Constants.checkNetwork().whenComplete(
                                            () => callAddRemoveFavorite(
                                                _nearbyListData[index].id));
                                      } else {
                                        Constants.toastMessage(
                                            Languages.of(context)!
                                                .labelPleaseLoginToAddFavorite);
                                      }
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          right: 10.w, top: 10.w),
                                      child: _nearbyListData[index].like!
                                          ? SvgPicture.asset(
                                              'assets/ic_favourite_filled.svg',
                                              color: Colors.white,
                                              width: 20.w,
                                              height: 20.w,
                                            )
                                          : SvgPicture.asset(
                                              'assets/ic_favourite_outline.svg',
                                              color: Colors.white,
                                              width: 20.w,
                                              height: 20.w,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _nearbyListData[index].name!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontFamily: Constants.appFontBold,
                                          fontSize: 18.sp),
                                    ),
                                  ),
                                  RatingBar.builder(
                                    initialRating:
                                        _nearbyListData[index].rate.toDouble(),
                                    ignoreGestures: true,
                                    minRating: 1,
                                    itemCount: 1,
                                    direction: Axis.horizontal,
                                    itemSize: 18.w,
                                    allowHalfRating: true,
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star_rate_rounded,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (double rating) {
                                      print(rating);
                                    },
                                  ),
                                  Text(
                                    ' (${_nearbyListData[index].review})',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontFamily: Constants.appFont,
                                      color: const Color(0xFF132229),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '• ' + getRestaurantsFood(index),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: Constants.appFont,
                                      color: Constants.colorBlack,
                                      fontSize: 14.sp),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    ];
  }

  List<Widget> _buildBrowsByMeal() {
    return [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Languages.of(context)!.labelBrowsByMeal,
              style: TextStyle(
                fontSize: 18.sp,
                fontFamily: Constants.appFontBold,
                color: Constants.colorTheme,
              ),
            ),
            if (_allCuisineListData.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    Transitions(
                      transitionType: TransitionType.none,
                      curve: Curves.bounceInOut,
                      reverseCurve: Curves.fastLinearToSlowEaseIn,
                      widget: const AllCuisineScreen(),
                    ),
                  );
                },
                child: Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: Constants.appFontBold,
                    color: const Color(0xFF03041D),
                  ),
                ),
              ),
          ],
        ),
      ),
      _allCuisineListData.isEmpty
          ? !_isSyncing
              ? Column(
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
                        Languages.of(context)!.labelNoData,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: Constants.appFontBold,
                          color: Constants.colorTheme,
                        ),
                      ),
                    )
                  ],
                )
              : const SizedBox.shrink()
          : Container(
              height: 245.h,
              alignment: Alignment.center,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 22.w),
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: _allCuisineListData.length > 10
                    ? 10
                    : _allCuisineListData.length,
                itemBuilder: (BuildContext context, int index) => Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        Transitions(
                          transitionType: TransitionType.none,
                          curve: Curves.bounceInOut,
                          reverseCurve: Curves.fastLinearToSlowEaseIn,
                          widget: SingleCuisineDetailsScreen(
                            cuisineId: _allCuisineListData[index].id,
                            strCuisineName: _allCuisineListData[index].name,
                          ),
                        ),
                      );
                    },
                    child: SimpleShadow(
                      opacity: 0.6,
                      color: Colors.black12,
                      offset: const Offset(0, 0),
                      sigma: 10,
                      child: Container(
                        height: 200.h,
                        width: 160.w,
                        margin: EdgeInsets.only(right: 22.w),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: CachedNetworkImage(
                                height: 130.h,
                                width: double.infinity,
                                imageUrl: _allCuisineListData[index].image!,
                                fit: BoxFit.cover,
                                progressIndicatorBuilder: (_, __, progress) =>
                                    Center(
                                  child: SizedBox(
                                    width: 38.w,
                                    height: 38.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      backgroundColor:
                                          Constants.colorTheme.withOpacity(0.2),
                                      valueColor: AlwaysStoppedAnimation(
                                          Constants.colorTheme),
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
                            const Spacer(),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _allCuisineListData[index].name!,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontFamily: Constants.appFontBold,
                                    fontSize: 20.sp),
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
    ];
  }

  List<Widget> _buildPopularRestaurants() {
    return [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Languages.of(context)!.labelPopular,
              style: TextStyle(
                fontSize: 18.sp,
                fontFamily: Constants.appFontBold,
                color: Constants.colorTheme,
              ),
            ),
            if (_topListData.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    Transitions(
                      transitionType: TransitionType.fade,
                      curve: Curves.bounceInOut,
                      reverseCurve: Curves.fastLinearToSlowEaseIn,
                      widget: const PopularRestaurantsScreen(),
                    ),
                  );
                },
                child: Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: Constants.appFontBold,
                    color: const Color(0xFF03041D),
                  ),
                ),
              ),
          ],
        ),
      ),
      _topListData.isEmpty
          ? !_isSyncing
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LottieBuilder.asset(
                      'animations/empty_restaurant.json',
                      width: 150.w,
                      height: 150.w,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.h),
                      child: Text(
                        Languages.of(context)!.labelNoData,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: Constants.appFontBold,
                          color: Constants.colorTheme,
                        ),
                      ),
                    )
                  ],
                )
              : Container()
          : SizedBox(
              height: 320.h,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 22.w),
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: _topListData.length > 8 ? 8 : _topListData.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          Transitions(
                            transitionType: TransitionType.fade,
                            curve: Curves.bounceInOut,
                            reverseCurve: Curves.fastLinearToSlowEaseIn,
                            widget: RestaurantsDetailsScreen(
                              restaurantId: _topListData[index].id,
                              isFav: _topListData[index].like,
                              strRestaurantsAvgTime: _topListData[index]
                                  .avgDeliveryTime
                                  .toString(),
                            ),
                          ),
                        );
                      },
                      child: SimpleShadow(
                        opacity: 0.6,
                        color: Colors.black12,
                        offset: const Offset(0, 0),
                        sigma: 10,
                        child: Container(
                          height: 280.h,
                          width: 275.w,
                          margin: EdgeInsets.only(right: 22.w),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: CachedNetworkImage(
                                      height: 150.h,
                                      width: double.infinity,
                                      imageUrl: _topListData[index].image!,
                                      fit: BoxFit.cover,
                                      progressIndicatorBuilder:
                                          (_, __, progress) => Center(
                                        child: SizedBox(
                                          width: 38.w,
                                          height: 38.w,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            backgroundColor: Constants
                                                .colorTheme
                                                .withOpacity(0.2),
                                            valueColor: AlwaysStoppedAnimation(
                                                Constants.colorTheme),
                                            value:
                                                progress.downloaded.toDouble(),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Center(
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
                                  Container(
                                    height: 150.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.r),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          Colors.black54,
                                          Colors.black12,
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (SharedPreferenceUtil.getBool(
                                          Constants.isLoggedIn)) {
                                        Constants.checkNetwork().whenComplete(
                                            () => callAddRemoveFavorite(
                                                _topListData[index].id));
                                      } else {
                                        Constants.toastMessage(
                                            Languages.of(context)!
                                                .labelPleaseLoginToAddFavorite);
                                      }
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          right: 10.w, top: 10.w),
                                      child: _topListData[index].like!
                                          ? SvgPicture.asset(
                                              'assets/ic_favourite_filled.svg',
                                              color: Colors.white,
                                              width: 20.w,
                                              height: 20.w,
                                            )
                                          : SvgPicture.asset(
                                              'assets/ic_favourite_outline.svg',
                                              color: Colors.white,
                                              width: 20.w,
                                              height: 20.w,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(flex: 2),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _topListData[index].name!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: Constants.appFontBold,
                                      fontSize: 20.sp),
                                ),
                              ),
                              const Spacer(flex: 1),
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  '• ' + getPopularRestaurantsFood(index),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: Constants.appFont,
                                      color: Constants.colorBlack,
                                      fontSize: 14.sp),
                                ),
                              ),
                              const Spacer(flex: 2),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      RatingBar.builder(
                                        initialRating:
                                            _topListData[index].rate.toDouble(),
                                        ignoreGestures: true,
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        itemSize: 26.w,
                                        itemCount: 1,
                                        allowHalfRating: true,
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star_rate_rounded,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (double rating) {
                                          print(rating);
                                        },
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        '(${_topListData[index].review})',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontFamily: Constants.appFont,
                                          color: const Color(0xFF03041D),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 34.h,
                                        child: Chip(
                                          labelPadding:
                                              EdgeInsets.only(right: 10.w),
                                          avatar: Transform.translate(
                                            offset: const Offset(0, -1),
                                            child: Icon(
                                              Icons.location_on_rounded,
                                              color: Constants.colorYellow,
                                              size: 16.w,
                                            ),
                                          ),
                                          label: Transform.translate(
                                            offset: const Offset(-4, -1),
                                            child: Text(
                                              _topListData[index]
                                                      .distance
                                                      .toString() +
                                                  Languages.of(context)!
                                                      .labelKmFarAway,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: Constants.appFont,
                                                color: const Color(0xFF132229),
                                              ),
                                            ),
                                          ),
                                          backgroundColor: Constants.colorYellow
                                              .withOpacity(0.3),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                      SizedBox(width: 5.w),
                                      SizedBox(
                                        height: 34.h,
                                        child: Chip(
                                          labelPadding:
                                              EdgeInsets.only(right: 10.w),
                                          avatar: Transform.translate(
                                            offset: const Offset(0, -1),
                                            child: Icon(
                                              Icons.timer_rounded,
                                              color: Constants.colorYellow,
                                              size: 16.w,
                                            ),
                                          ),
                                          label: Transform.translate(
                                            offset: const Offset(-4, -1),
                                            child: Text(
                                              _topListData[index]
                                                      .avgDeliveryTime
                                                      .toString() +
                                                  ' mins',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: Constants.appFont,
                                                color: const Color(0xFF132229),
                                              ),
                                            ),
                                          ),
                                          backgroundColor: Constants.colorYellow
                                              .withOpacity(0.3),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    ];
  }

  List<Widget> _buildAllRestaurants() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            Languages.of(context)!.labelAllRestaurants,
            style: TextStyle(
              fontSize: 18.sp,
              fontFamily: Constants.appFontBold,
              color: Constants.colorTheme,
            ),
          ),
          if (_allRestaurantsListData.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  Transitions(
                    transitionType: TransitionType.fade,
                    curve: Curves.bounceInOut,
                    reverseCurve: Curves.fastLinearToSlowEaseIn,
                    widget: const AllRestaurantsScreen(),
                  ),
                );
              },
              child: Text(
                'See all',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: Constants.appFontBold,
                  color: const Color(0xFF03041D),
                ),
              ),
            ),
        ],
      ),
      SizedBox(height: 10.h),
      _allRestaurantsListData.isEmpty
          ? !_isSyncing
              ? Column(
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
                        Languages.of(context)!.labelNoData,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: Constants.appFontBold,
                          color: Constants.colorTheme,
                        ),
                      ),
                    )
                  ],
                )
              : Container()
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: _allRestaurantsListData.length > 3
                  ? 3
                  : _allRestaurantsListData.length,
              itemBuilder: (BuildContext context, int index) => GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    Transitions(
                      transitionType: TransitionType.fade,
                      curve: Curves.bounceInOut,
                      reverseCurve: Curves.fastLinearToSlowEaseIn,
                      widget: RestaurantsDetailsScreen(
                        restaurantId: _allRestaurantsListData[index].id,
                        isFav: _allRestaurantsListData[index].like,
                        strRestaurantsAvgTime: _allRestaurantsListData[index]
                            .avgDeliveryTime
                            .toString(),
                      ),
                    ),
                  );
                },
                child: SimpleShadow(
                  opacity: 0.6,
                  color: Colors.black12,
                  offset: const Offset(0, 3),
                  sigma: 10,
                  child: Container(
                    height: 150.h,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 10.h),
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: CachedNetworkImage(
                            width: 120.w,
                            height: 140.w,
                            imageUrl: _allRestaurantsListData[index].image!,
                            fit: BoxFit.cover,
                            progressIndicatorBuilder: (_, __, progress) =>
                                Center(
                              child: SizedBox(
                                width: 38.w,
                                height: 38.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  backgroundColor:
                                      Constants.colorTheme.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation(
                                      Constants.colorTheme),
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
                          flex: 5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _allRestaurantsListData[index].name!,
                                      style: TextStyle(
                                          fontFamily: Constants.appFontBold,
                                          fontSize: 18.sp),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (SharedPreferenceUtil.getBool(
                                          Constants.isLoggedIn)) {
                                        Constants.checkNetwork().whenComplete(
                                            () => callAddRemoveFavorite(
                                                _allRestaurantsListData[index]
                                                    .id));
                                      } else {
                                        Constants.toastMessage(
                                            Languages.of(context)!
                                                .labelPleaseLoginToAddFavorite);
                                      }
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(right: 5.w, top: 5.w),
                                      child:
                                          _allRestaurantsListData[index].like!
                                              ? SvgPicture.asset(
                                                  'assets/ic_favourite_filled.svg',
                                                  color: Constants.colorLike,
                                                  width: 20.w,
                                                  height: 20.w,
                                                )
                                              : SvgPicture.asset(
                                                  'assets/ic_favourite_outline.svg',
                                                  width: 20.w,
                                                  height: 20.w,
                                                ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  '• ' + getAllRestaurantsFood(index),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: Constants.appFont,
                                      color: Constants.colorBlack,
                                      fontSize: 14.sp),
                                ),
                              ),
                              const Spacer(flex: 1),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        color: Constants.colorYellow,
                                        size: 16.w,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        _allRestaurantsListData[index]
                                                .distance
                                                .toString() +
                                            Languages.of(context)!
                                                .labelKmFarAway,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: Constants.appFont,
                                          color: const Color(0xFF132229),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(width: 5.w),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.timer_rounded,
                                        color: Constants.colorYellow,
                                        size: 16.w,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        _allRestaurantsListData[index]
                                                .avgDeliveryTime
                                                .toString() +
                                            ' mins',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: Constants.appFont,
                                          color: const Color(0xFF132229),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(flex: 1),
                              Row(
                                children: [
                                  RatingBar.builder(
                                    initialRating:
                                        _allRestaurantsListData[index]
                                            .rate
                                            .toDouble(),
                                    ignoreGestures: true,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    itemSize: 18.w,
                                    allowHalfRating: true,
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star_rate_rounded,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (double rating) {
                                      print(rating);
                                    },
                                  ),
                                  Text(
                                    ' (${_allRestaurantsListData[index].review})',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontFamily: Constants.appFont,
                                      color: const Color(0xFF03041D),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(flex: 1),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
    ];
  }

  Future<BaseModel<AllCuisinesModel>> callAllCuisine() async {
    AllCuisinesModel response;
    if (mounted) {
      setState(() {
        _isSyncing = true;
      });
    }
    try {
      _allCuisineListData.clear();
      response = await RestClient(RetroApi().dioData()).allCuisine();
      print(response.success);
      if (response.success!) {
        if (mounted) {
          setState(() {
            _isSyncing = false;
            if (response.data!.isNotEmpty) {
              _allCuisineListData.addAll(response.data!);
            } else {
              _allCuisineListData.clear();
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

  Future<BaseModel<NearByRestaurantModel>> callNearByRestaurants() async {
    NearByRestaurantModel response;
    try {
      _nearbyListData.clear();
      setState(() {
        _isSyncing = true;
      });
      Map<String, String> body = {
        'lat': SharedPreferenceUtil.getString('selectedLat'),
        'lang': SharedPreferenceUtil.getString('selectedLng'),
      };
      response = await RestClient(RetroApi().dioData()).nearBy(body);
      print(response.success);
      if (response.success!) {
        if (mounted) {
          setState(() {
            if (response.data!.isNotEmpty) {
              _nearbyListData.addAll(response.data!);
            } else {
              _nearbyListData.clear();
            }
            _isSyncing = false;
          });
        }
      } else {
        setState(() {
          _isSyncing = false;
        });
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

  Future<BaseModel<TopRestaurantsListModel>> callTopRestaurants() async {
    TopRestaurantsListModel response;
    try {
      _topListData.clear();
      Map<String, String> body = {
        'lat': SharedPreferenceUtil.getString('selectedLat'),
        'lang': SharedPreferenceUtil.getString('selectedLng'),
      };
      response = await RestClient(RetroApi().dioData()).topRest(body);
      print(response.success);
      if (response.success!) {
        if (mounted) {
          setState(() {
            if (response.data!.isNotEmpty) {
              _topListData.addAll(response.data!);
            } else {
              _topListData.clear();
            }
          });
        }
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<VegRestaurantModel>> callVegRestaurants() async {
    VegRestaurantModel response;
    try {
      _vegListData.clear();
      Map<String, String> body = {
        'lat': SharedPreferenceUtil.getString('selectedLat'),
        'lang': SharedPreferenceUtil.getString('selectedLng'),
      };
      response = await RestClient(RetroApi().dioData()).vegRest(body);
      print(response.success);
      if (response.success!) {
        if (mounted) {
          setState(() {
            if (response.data!.isNotEmpty) {
              _vegListData.addAll(response.data!);
            } else {
              _vegListData.clear();
            }
          });
        }
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<NonVegRestaurantModel>> callNonVegRestaurants() async {
    NonVegRestaurantModel response;
    try {
      _nonvegListData.clear();
      Map<String, String> body = {
        'lat': SharedPreferenceUtil.getString('selectedLat'),
        'lang': SharedPreferenceUtil.getString('selectedLng'),
      };
      response = await RestClient(RetroApi().dioData()).nonVegRest(body);
      print(response.success);
      if (response.success!) {
        if (mounted) {
          setState(() {
            if (response.data!.isNotEmpty) {
              _nonvegListData.addAll(response.data!);
            } else {
              _nonvegListData.clear();
            }
          });
        }
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<ExploreRestaurantListModel>> callExploreRestaurants() async {
    ExploreRestaurantListModel response;
    try {
      _allRestaurantsListData.clear();
      Map<String, String> body = {
        'lat': SharedPreferenceUtil.getString('selectedLat'),
        'lang': SharedPreferenceUtil.getString('selectedLng'),
      };
      response = await RestClient(RetroApi().dioData()).exploreRest(body);
      print(response.success);
      if (response.success!) {
        if (mounted) {
          setState(() {
            if (response.data!.isNotEmpty) {
              _allRestaurantsListData.addAll(response.data!);
            } else {
              _allRestaurantsListData.clear();
            }
          });
        }
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CommonResponse>> callAddRemoveFavorite(
      int? vegRestId) async {
    CommonResponse response;
    try {
      if (mounted) {
        setState(() {
          _isSyncing = true;
        });
      }
      Map<String, String> body = {
        'id': vegRestId.toString(),
      };
      response = await RestClient(RetroApi().dioData()).favorite(body);
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
      print(response.success);
      if (response.success!) {
        Constants.toastMessage(response.data!);
        Constants.checkNetwork().whenComplete(() => callVegRestaurants());
        Constants.checkNetwork().whenComplete(() => callNearByRestaurants());
        Constants.checkNetwork().whenComplete(() => callTopRestaurants());
        Constants.checkNetwork().whenComplete(() => callNonVegRestaurants());
        Constants.checkNetwork().whenComplete(() => callExploreRestaurants());
        if (mounted) setState(() {});
      } else {
        Constants.toastMessage(Languages.of(context)!.labelErrorWhileUpdate);
      }
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<BannerResponse>> getBanners() async {
    BannerResponse response;
    try {
      response = await RestClient(RetroApi().dioData()).getBanner();
      if (response.data != null) {
        setState(() {
          print("check bannwe lwngrh ${response.data!.length}");
          bannerList = response.data!;
        });
      } else {
        bannerList = [];
      }
    } catch (error, stacktrace) {
      debugPrint("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  String getRestaurantsFood(int index) {
    restaurantsFood.clear();
    if (_nearbyListData.isNotEmpty) {
      var length = _nearbyListData[index].cuisine!.length > 2
          ? 2
          : _nearbyListData[index].cuisine!.length;
      for (int j = 0; j < length; j++) {
        restaurantsFood.add(_nearbyListData[index].cuisine![j].name);
      }
    }
    print(restaurantsFood.toString());

    return restaurantsFood.join(" • ");
  }

  String getVegRestaurantsFood(int index) {
    vegRestaurantsFood.clear();
    if (_vegListData.isNotEmpty) {
      var length = _vegListData[index].cuisine!.length > 2
          ? 2
          : _vegListData[index].cuisine!.length;
      for (int j = 0; j < length; j++) {
        vegRestaurantsFood.add(_vegListData[index].cuisine![j].name);
      }
    }
    print(vegRestaurantsFood.toString());

    return vegRestaurantsFood.join(" • ");
  }

  String getNonVegRestaurantsFood(int index) {
    nonVegRestaurantsFood.clear();
    if (_nonvegListData.isNotEmpty) {
      var length = _nonvegListData[index].cuisine!.length > 2
          ? 2
          : _nonvegListData[index].cuisine!.length;
      for (int j = 0; j < length; j++) {
        nonVegRestaurantsFood.add(_nonvegListData[index].cuisine![j].name);
      }
    }
    print(nonVegRestaurantsFood.toString());

    return nonVegRestaurantsFood.join(" • ");
  }

  String getPopularRestaurantsFood(int index) {
    topRestaurantsFood.clear();
    if (_topListData.isNotEmpty) {
      var length = _topListData[index].cuisine!.length > 2
          ? 2
          : _topListData[index].cuisine!.length;
      for (int j = 0; j < length; j++) {
        topRestaurantsFood.add(_topListData[index].cuisine![j].name);
      }
    }
    print(topRestaurantsFood.toString());

    return topRestaurantsFood.join(" • ");
  }

  String getAllRestaurantsFood(int index) {
    exploreRestaurantsFood.clear();
    if (_allRestaurantsListData.isNotEmpty) {
      var length = _allRestaurantsListData[index].cuisine!.length > 2
          ? 2
          : _allRestaurantsListData[index].cuisine!.length;
      for (int j = 0; j < length; j++) {
        exploreRestaurantsFood
            .add(_allRestaurantsListData[index].cuisine![j].name);
      }
    }
    print(exploreRestaurantsFood.toString());

    return exploreRestaurantsFood.join(" • ");
  }
}

class BottomCarousel extends StatelessWidget with PreferredSizeWidget {
  const BottomCarousel(
      {required this.visibility, required this.bannerList, Key? key})
      : super(key: key);

  final bool visibility;
  final List<Data> bannerList;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Visibility(
        visible: visibility,
        child: Container(
          margin: EdgeInsets.only(bottom: 36.h, top: 36.h),
          child: CarouselSlider(
            options: CarouselOptions(
              viewportFraction: 0.9,
              autoPlayAnimationDuration: const Duration(milliseconds: 500),
              autoPlay: true,
              enlargeCenterPage: true,
              height: 120.h,
            ),
            items: bannerList.isNotEmpty
                ? bannerList
                    .map(
                      (banner) => Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: CachedNetworkImage(
                            imageUrl: banner.image ?? '',
                            fit: BoxFit.cover,
                            height: 120.h,
                            width: MediaQuery.of(context).size.width,
                            progressIndicatorBuilder: (_, __, progress) =>
                                Center(
                              child: SizedBox(
                                width: 38.w,
                                height: 38.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  backgroundColor:
                                      Constants.colorTheme.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation(
                                      Constants.colorTheme),
                                  value: progress.downloaded.toDouble(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList()
                : [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/backgrounds/ic_carosol_home_1.png',
                          fit: BoxFit.fill,
                          height: 120.h,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                    ),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/backgrounds/ic_carosol_home_2.png',
                          fit: BoxFit.fill,
                          height: 120.h,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                    ),
                  ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
