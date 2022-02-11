import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:mealup/model/common_response.dart';
import 'package:mealup/model/explore_restaurants_list_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/restaurant_details/restaurants_details_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:mealup/utils/widgets/customs/custom_app_bar.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:simple_shadow/simple_shadow.dart';

class AllRestaurantsScreen extends StatefulWidget {
  const AllRestaurantsScreen({Key? key}) : super(key: key);

  @override
  _AllRestaurantsScreenState createState() => _AllRestaurantsScreenState();
}

class _AllRestaurantsScreenState extends State<AllRestaurantsScreen> {
  final List<ExploreRestaurantsListData> _allRestaurantsListData = [];
  List<String?> exploreRestaurantsFood = [];

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    Constants.checkNetwork().whenComplete(() => callExploreRestaurants());
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    Constants.checkNetwork().whenComplete(() => callExploreRestaurants());
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
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
      child: SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(
            title: 'All Restaurants',
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
              child: _allRestaurantsListData.isEmpty
                  ? !_isSyncing
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
                      : const SizedBox.shrink()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: _allRestaurantsListData.length,
                      padding: EdgeInsets.symmetric(horizontal: 22.w),
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
                                  flex: 5,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _allRestaurantsListData[index].name!,
                                              style: TextStyle(fontFamily: Constants.appFontBold, fontSize: 18.sp),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (SharedPreferenceUtil.getBool(Constants.isLoggedIn)) {
                                                Constants.checkNetwork().whenComplete(() => callAddRemoveFavorite(_allRestaurantsListData[index].id));
                                              } else {
                                                Constants.toastMessage(Languages.of(context)!.labelPleaseLoginToAddFavorite);
                                              }
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.only(right: 5.w, top: 5.w),
                                              child: _allRestaurantsListData[index].like!
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
                                          style: TextStyle(fontFamily: Constants.appFont, color: Constants.colorBlack, fontSize: 14.sp),
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
                                                _allRestaurantsListData[index].distance.toString() + Languages.of(context)!.labelKmFarAway,
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
                                                _allRestaurantsListData[index].avgDeliveryTime.toString() + ' mins',
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
                                            initialRating: _allRestaurantsListData[index].rate.toDouble(),
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
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<CommonResponse>> callAddRemoveFavorite(int? vegRestId) async {
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

  String getAllRestaurantsFood(int index) {
    exploreRestaurantsFood.clear();
    if (_allRestaurantsListData.isNotEmpty) {
      var length = _allRestaurantsListData[index].cuisine!.length > 2 ? 2 : _allRestaurantsListData[index].cuisine!.length;
      for (int j = 0; j < length; j++) {
        exploreRestaurantsFood.add(_allRestaurantsListData[index].cuisine![j].name);
      }
    }
    print(exploreRestaurantsFood.toString());

    return exploreRestaurantsFood.join(" • ");
  }

  Future<BaseModel<ExploreRestaurantListModel>> callExploreRestaurants() async {
    ExploreRestaurantListModel response;
    try {
      setState(() {
        _isSyncing = true;
      });
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
}
