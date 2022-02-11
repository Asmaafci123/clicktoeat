import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:mealup/model/cuisine_vendor_details_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/restaurant_details/restaurants_details_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/customs/custom_app_bar.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:simple_shadow/simple_shadow.dart';

class SingleCuisineDetailsScreen extends StatefulWidget {
  final int? cuisineId;
  final String? strCuisineName;

  const SingleCuisineDetailsScreen({Key? key, required this.cuisineId, required this.strCuisineName}) : super(key: key);

  @override
  _SingleCuisineDetailsScreenState createState() => _SingleCuisineDetailsScreenState();
}

class _SingleCuisineDetailsScreenState extends State<SingleCuisineDetailsScreen> {
  final List<CuisineVendorDetailsListData> _listCuisineVendorRestaurants = [];
  List<String?> exploreRestaurantsFood = [];

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    Constants.checkNetwork().whenComplete(() => getCallSingleCuisineDetails(widget.cuisineId));
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    Constants.checkNetwork().whenComplete(() => getCallSingleCuisineDetails(widget.cuisineId));
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
            title: widget.strCuisineName,
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
              child: _listCuisineVendorRestaurants.isEmpty
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
                      padding: EdgeInsets.symmetric(horizontal: 22.w),
                      itemCount: _listCuisineVendorRestaurants.length,
                      itemBuilder: (BuildContext context, int index) => GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            Transitions(
                              transitionType: TransitionType.fade,
                              curve: Curves.bounceInOut,
                              reverseCurve: Curves.fastLinearToSlowEaseIn,
                              widget: RestaurantsDetailsScreen(
                                restaurantId: _listCuisineVendorRestaurants[index].id,
                                isFav: null,
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
                                    imageUrl: _listCuisineVendorRestaurants[index].image!,
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
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          _listCuisineVendorRestaurants[index].name!,
                                          style: TextStyle(fontFamily: Constants.appFontBold, fontSize: 18.sp),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          '• ' + getExploreRestaurantsFood(index),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontFamily: Constants.appFont, color: Constants.colorBlack, fontSize: 14.sp),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          RatingBar.builder(
                                            initialRating: _listCuisineVendorRestaurants[index].rate.toDouble(),
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            itemSize: 20.w,
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
                                            ' (${_listCuisineVendorRestaurants[index].review})',
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontFamily: Constants.appFont,
                                              color: const Color(0xFF03041D),
                                            ),
                                          ),
                                        ],
                                      ),
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

  String getExploreRestaurantsFood(int index) {
    exploreRestaurantsFood.clear();
    if (_listCuisineVendorRestaurants.isNotEmpty) {
      for (int j = 0; j < _listCuisineVendorRestaurants[index].cuisine!.length; j++) {
        exploreRestaurantsFood.add(_listCuisineVendorRestaurants[index].cuisine![j].name);
      }
    }
    print(exploreRestaurantsFood.toString());

    return exploreRestaurantsFood.join(" • ");
  }

  Future<BaseModel<CuisineVendorDetailsModel>> getCallSingleCuisineDetails(cuisineId) async {
    CuisineVendorDetailsModel response;
    try {
      _listCuisineVendorRestaurants.clear();
      setState(() {
        _isSyncing = true;
      });
      response = await RestClient(RetroApi().dioData()).cuisineVendor(cuisineId);
      setState(() {
        _isSyncing = false;
        _listCuisineVendorRestaurants.addAll(response.data!);
      });
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
