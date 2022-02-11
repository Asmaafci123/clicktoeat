import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:mealup/model/common_response.dart';
import 'package:mealup/model/near_by_restaurants_model.dart';
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

class NearYouRestaurantsScreen extends StatefulWidget {
  const NearYouRestaurantsScreen({Key? key}) : super(key: key);

  @override
  _NearYouRestaurantsScreenState createState() => _NearYouRestaurantsScreenState();
}

class _NearYouRestaurantsScreenState extends State<NearYouRestaurantsScreen> {
  final List<NearByRestaurantListData> _nearbyListData = [];
  List<String?> restaurantsFood = [];

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    Constants.checkNetwork().whenComplete(() => callNearByRestaurants());
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    Constants.checkNetwork().whenComplete(() => callNearByRestaurants());
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
            title: 'Near By Restaurants',
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
              child: _nearbyListData.isEmpty
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
                  : GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.w),
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: _nearbyListData.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 22.w, crossAxisSpacing: 22.w, childAspectRatio: 10 / 13),
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
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
                                width: double.infinity,
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
                                            if (SharedPreferenceUtil.getBool(Constants.isLoggedIn)) {
                                              Constants.checkNetwork().whenComplete(() => callAddRemoveFavorite(_nearbyListData[index].id));
                                            } else {
                                              Constants.toastMessage(Languages.of(context)!.labelPleaseLoginToAddFavorite);
                                            }
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.only(right: 10.w, top: 10.w),
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
                                            style: TextStyle(fontFamily: Constants.appFontBold, fontSize: 18.sp),
                                          ),
                                        ),
                                        RatingBar.builder(
                                          initialRating: _nearbyListData[index].rate.toDouble(),
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
                                        style: TextStyle(fontFamily: Constants.appFont, color: Constants.colorBlack, fontSize: 14.sp),
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
        Constants.checkNetwork().whenComplete(() => callNearByRestaurants());
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

  String getRestaurantsFood(int index) {
    restaurantsFood.clear();
    if (_nearbyListData.isNotEmpty) {
      var length = _nearbyListData[index].cuisine!.length > 2 ? 2 : _nearbyListData[index].cuisine!.length;
      for (int j = 0; j < length; j++) {
        restaurantsFood.add(_nearbyListData[index].cuisine![j].name);
      }
    }
    print(restaurantsFood.toString());

    return restaurantsFood.join(" • ");
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
}
