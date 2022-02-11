import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:mealup/model/common_response.dart';
import 'package:mealup/model/favorite_list_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/pager/dashboard_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:mealup/utils/widgets/customs/custom_app_bar_with_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:simple_shadow/simple_shadow.dart';

import '../restaurant_details/restaurants_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final List<FavoriteListData> _listFavoriteData = [];
  List<String?> favoriteRestaurantsFood = [];
  bool _isSyncing = false;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()

    Constants.checkNetwork().whenComplete(() => callGetFavoritesList());
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    Constants.checkNetwork().whenComplete(() => callGetFavoritesList());
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
          appBar: CustomAppBarWithButton(
            title: Languages.of(context)!.labelYourFavorites,
            buttonText: '+ ${Languages.of(context)!.labelAddAddress}',
            buttonColor: Constants.colorTheme,
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                Transitions(
                  transitionType: TransitionType.fade,
                  curve: Curves.bounceInOut,
                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                  // widget: HereMapDemo())
                  widget: DashboardScreen(1),
                ),
              );
            },
          ),
          backgroundColor: Colors.transparent,
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
                padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
                child: _listFavoriteData.isEmpty
                    ? !_isSyncing
                        ? SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Spacer(flex: 1),
                                LottieBuilder.asset(
                                  'animations/favourites.json',
                                  width: 250,
                                  height: 250,
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: 'Your Favourite List is ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: Constants.appFont,
                                      color: Colors.black54,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(text: 'Empty', style: TextStyle(color: Constants.colorTheme, fontFamily: Constants.appFontBold)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'You haven\'t added anything\nto your favourite list!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: Constants.appFont,
                                    color: Colors.black45,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.of(context).push(
                                      Transitions(
                                          transitionType: TransitionType.fade,
                                          curve: Curves.bounceInOut,
                                          reverseCurve: Curves.fastLinearToSlowEaseIn,
                                          // widget: HereMapDemo())
                                          widget: DashboardScreen(1)),
                                    );
                                  },
                                  icon: const Icon(Icons.bookmark_add, size: 20),
                                  label: Text(
                                    'Add Favourites',
                                    style: TextStyle(fontFamily: Constants.appFont, fontWeight: FontWeight.w900, color: Constants.colorWhite, fontSize: 16.0),
                                  ),
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<OutlinedBorder>(const StadiumBorder()),
                                    minimumSize: MaterialStateProperty.all<Size>(const Size(100, 40)),
                                    backgroundColor: MaterialStateProperty.all<Color>(Constants.colorTheme),
                                  ),
                                ),
                                const Spacer(flex: 2),
                              ],
                            ),
                          )
                        : const SizedBox.shrink()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: _listFavoriteData.length,
                        itemBuilder: (BuildContext context, int index) => GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              Transitions(
                                transitionType: TransitionType.fade,
                                curve: Curves.bounceInOut,
                                reverseCurve: Curves.fastLinearToSlowEaseIn,
                                widget: RestaurantsDetailsScreen(
                                  restaurantId: _listFavoriteData[index].id,
                                  isFav: true,
                                ),
                              ),
                            );
                          },
                          child: SimpleShadow(
                            opacity: 0.6,
                            color: Colors.black12,
                            offset: const Offset(0, 3),
                            sigma: 3,
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(vertical: 10.0),
                              padding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: CachedNetworkImage(
                                          imageUrl: _listFavoriteData[index].image!,
                                          fit: BoxFit.fill,
                                          placeholder: (context, url) => SpinKitDoubleBounce(color: Constants.colorTheme),
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
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                            _listFavoriteData[index].name!,
                                            style: TextStyle(fontFamily: Constants.appFontBold, fontSize: 20.0),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Spacer(flex: 2),
                                          Row(
                                            children: [
                                              Icon(Icons.lunch_dining_rounded, color: Constants.colorYellow, size: 15),
                                              const SizedBox(width: 5),
                                              Text(
                                                getFavRestaurantsFood(index),
                                                style: TextStyle(fontFamily: Constants.appFont, color: Colors.black54, fontSize: 14.0),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              const Icon(Icons.place_rounded, color: Colors.black54, size: 15),
                                              const SizedBox(width: 5),
                                              Text(
                                                _listFavoriteData[index].distance.toString() + Languages.of(context)!.labelKmFarAway,
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontFamily: Constants.appFont,
                                                  color: Colors.black54,
                                                ),
                                              )
                                            ],
                                          ),
                                          const Spacer(flex: 2),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  RatingBar.builder(
                                                    initialRating: _listFavoriteData[index].rate.toDouble(),
                                                    minRating: 1,
                                                    direction: Axis.horizontal,
                                                    itemSize: 20,
                                                    allowHalfRating: true,
                                                    itemBuilder: (context, _) => const Icon(
                                                      Icons.star_rate_rounded,
                                                      color: Colors.amber,
                                                    ),
                                                    onRatingUpdate: (double rating) {
                                                      log(rating.toString());
                                                    },
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    '(${_listFavoriteData[index].review})',
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontFamily: Constants.appFont,
                                                      color: Colors.black54,
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
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (SharedPreferenceUtil.getBool(Constants.isLoggedIn)) {
                                            _showDialog(_listFavoriteData[index].id);
                                          } else {
                                            Constants.toastMessage(Languages.of(context)!.labelPleaseLoginToAddFavorite);
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                          child: SvgPicture.asset(
                                            'assets/ic_favourite_filled.svg',
                                            color: Constants.colorLike,
                                            width: 30,
                                            height: 30,
                                          ),
                                        ),
                                      ),
                                      _listFavoriteData[index].vendorType == 'veg'
                                          ? Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 2),
                                                  child: SvgPicture.asset(
                                                    'assets/ic_veg.svg',
                                                    height: 10.0,
                                                    width: 10.0,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : _listFavoriteData[index].vendorType == 'non_veg'
                                              ? Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/ic_non_veg.svg',
                                                      height: 10.0,
                                                      width: 10.0,
                                                    ),
                                                  ],
                                                )
                                              : Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/ic_veg.svg',
                                                      height: 10.0,
                                                      width: 10.0,
                                                    ),
                                                    SvgPicture.asset(
                                                      'assets/ic_non_veg.svg',
                                                      height: 10.0,
                                                      width: 10.0,
                                                    )
                                                  ],
                                                )
                                    ],
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
      ),
    );
  }

  _showDialog(int? id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 0, top: 20),
              child: SizedBox(
                height: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Languages.of(context)!.labelRemoveFromTheList,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            fontFamily: Constants.appFontBold,
                          ),
                        ),
                        GestureDetector(
                          child: const Icon(Icons.close),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                      thickness: 1,
                      color: Color(0xffcccccc),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          Languages.of(context)!.labelAreYouSureToRemove,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, fontFamily: Constants.appFont, color: Constants.colorBlack),
                        ),
                        const SizedBox(height: 20),
                        const Divider(
                          thickness: 1,
                          color: Color(0xffcccccc),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  Languages.of(context)!.labelNoGoBack,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: Constants.appFontBold, color: Constants.colorGray),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    callAddRemoveFavorite(id);
                                  },
                                  child: Text(
                                    Languages.of(context)!.labelYesRemoveIt,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: Constants.appFontBold, color: Constants.colorBlue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<BaseModel<CommonResponse>> callAddRemoveFavorite(int? vegRestId) async {
    CommonResponse response;
    try {
      setState(() {
        _isSyncing = true;
      });
      Map<String, String> body = {
        'id': vegRestId.toString(),
      };
      response = await RestClient(RetroApi().dioData()).favorite(body);
      setState(() {
        _isSyncing = false;
      });
      log(response.success.toString());
      if (response.success!) {
        Constants.toastMessage(response.data!);
        callGetFavoritesList();
        setState(() {});
      } else {
        Constants.toastMessage(Languages.of(context)!.labelErrorWhileUpdate);
      }
    } catch (error, stacktrace) {
      log("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  String getFavRestaurantsFood(int index) {
    favoriteRestaurantsFood.clear();
    if (_listFavoriteData.isNotEmpty) {
      for (int j = 0; j < _listFavoriteData[index].cuisine!.length; j++) {
        favoriteRestaurantsFood.add(_listFavoriteData[index].cuisine![j].name);
      }
    }
    log(favoriteRestaurantsFood.toString());

    return favoriteRestaurantsFood.join(" , ");
  }

  Future<BaseModel<FavoriteListModel>> callGetFavoritesList() async {
    FavoriteListModel response;
    try {
      _listFavoriteData.clear();
      setState(() {
        _isSyncing = true;
      });
      response = await RestClient(RetroApi().dioData()).restFavorite();
      log(response.success.toString());
      setState(() {
        _isSyncing = false;
      });
      if (response.success!) {
        setState(() {
          _listFavoriteData.addAll(response.data!);
          // _listFavoriteData.clear();
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
}
