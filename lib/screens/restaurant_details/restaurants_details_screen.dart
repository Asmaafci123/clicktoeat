import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/model/cart_model.dart';
import 'package:mealup/model/common_response.dart';
import 'package:mealup/model/customization_item_model.dart';
import 'package:mealup/model/single_restaurants_details_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/pager/dashboard_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/custom_shared_preference_util.dart';
import 'package:mealup/utils/widgets/customs/custom_scrollable_list_tabview.dart';
import 'package:mealup/utils/widgets/database_helper.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:scrollable_list_tabview/model/list_tab.dart';
import 'package:scrollable_list_tabview/model/scrollable_list_tab.dart';
import 'package:simple_shadow/simple_shadow.dart';

final dbHelper = DatabaseHelper.instance;
List<Product> _listCart = [];

double totalCartAmount = 0;
int totalQty = 0;
List<bool> _listFinalCustomizationCheck = [];

class RestaurantsDetailsScreen extends StatefulWidget {
  final int? restaurantId;
  final bool? isFav;
  final String? strRestaurantsAvgTime;

  const RestaurantsDetailsScreen(
      {Key? key,
      required this.restaurantId,
      this.isFav,
      this.strRestaurantsAvgTime})
      : super(key: key);

  @override
  _RestaurantsDetailsScreenState createState() =>
      _RestaurantsDetailsScreenState();
}

class _RestaurantsDetailsScreenState extends State<RestaurantsDetailsScreen> {
  bool _keyboardIsVisible() {
    return !(MediaQuery.of(context).viewInsets.bottom == 0.0);
  }

  bool isNotSearch = true;
  TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSyncing = false;
  String? strRestaurantsAvgTime = '',
      strRestaurantsName = '',
      strRestaurantsAddress = '',
      strRestaurantsForTwoPerson = '',
      strRestaurantsType = '',
      strRestaurantsReview = '',
      strRestaurantImage = '';
  double strRestaurantsRate = 0.0;
  final List<RestaurantsDetailsMenuListData> _listRestaurantsMenu = [];
  final List<RestaurantsDetailsMenuListData> _searchListRestaurantsMenu = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool? isFavorite;

  late ScrollController _scrollController;

  String hash = '';

  String cuisineItems = '';

  //RefreshController _refreshController = RefreshController(initialRefresh: false);

  void callSetState() {
    setState(() {});
  }

  bool _visibility = true;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _visibility = _isSliverAppBarExpanded ? false : true;
        });
      });

    Constants.checkNetwork()
        .whenComplete(() => callGetRestaurantsDetails(widget.restaurantId));
    if (widget.isFav != null) {
      isFavorite = widget.isFav;
    }

    _queryFirst(context);
  }

  bool get _isSliverAppBarExpanded {
    return _scrollController.hasClients && _scrollController.offset > 100.h;
  }

  bool showTextField = false;

  double _width = 40.w;
  double _height = 40.w;
  Color _color = Colors.black;
  BorderRadiusGeometry _borderRadius = BorderRadius.circular(0);

  Widget _buildTextField() {
    return AnimatedContainer(
      width: _width,
      height: _height,
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: _borderRadius,
      ),
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
      child: Row(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: showTextField
                  ? TextFormField(
                      controller: searchController,
                      onChanged: onSearchTextChanged,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Constants.colorHint),
                        errorStyle: TextStyle(
                            fontFamily: Constants.appFont, color: Colors.red),
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15.w),
                        errorMaxLines: 1,
                        hintText: 'Search',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.r),
                          borderSide: const BorderSide(
                              width: 0.5, color: Colors.transparent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.r),
                          borderSide: const BorderSide(
                              width: 0.5, color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.r),
                          borderSide: const BorderSide(
                              width: 0.5, color: Colors.transparent),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(
            width: 38.w,
            height: 38.w,
            child: FloatingActionButton(
              backgroundColor: Constants.colorTheme,
              child: Icon(Icons.search, size: 20.w),
              onPressed: () {
                setState(() {
                  showTextField = !showTextField;
                  if (showTextField) {
                    _height = 40.w;
                    _width = 350.w;
                    _color = Colors.white;
                    _borderRadius = BorderRadius.circular(50.r);
                  } else {
                    _height = 40.w;
                    _width = 40.w;
                    _color = Colors.transparent;
                  }
                });
              },
            ),
          ),
          SizedBox(width: 1.w),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF252627),
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          bottomNavigationBar: Visibility(
            visible: ScopedModel.of<CartModel>(context, rebuildOnChange: true)
                    .cart
                    .isNotEmpty
                ? true
                : false,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  Transitions(
                    transitionType: TransitionType.fade,
                    curve: Curves.bounceInOut,
                    reverseCurve: Curves.fastLinearToSlowEaseIn,
                    widget: DashboardScreen(2),
                  ),
                );
              },
              child: Container(
                height: 64.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
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
                      Container(
                        height: 34.w,
                        width: 34.w,
                        padding: EdgeInsets.all(5.w),
                        decoration: const ShapeDecoration(
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.white, width: 1),
                          ),
                        ),
                        child: FittedBox(
                          child: Text(
                            totalQty.toString(),
                            style: TextStyle(
                              color: Constants.colorWhite,
                              fontFamily: Constants.appFont,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'View your cart',
                        style: TextStyle(
                          color: Constants.colorWhite,
                          fontFamily: Constants.appFontBold,
                          fontSize: 16.sp,
                        ),
                      ),
                      Text(
                        'Rs. ${totalCartAmount.toInt()}',
                        style: TextStyle(
                          color: Constants.colorWhite,
                          fontFamily: Constants.appFontBold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: ModalProgressHUD(
            inAsyncCall: _isSyncing,
            child: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 175.h,
                    pinned: true,
                    snap: false,
                    floating: true,
                    forceElevated: true,
                    backgroundColor: const Color(0xFF252627),
                    centerTitle: false,
                    automaticallyImplyLeading: false,
                    leading: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 15.w),
                        child: Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white, size: 18.w),
                      ),
                    ),
                    bottom: AppBar(
                      automaticallyImplyLeading: false,
                      leading: !_visibility
                          ? GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 15.w),
                                child: Icon(Icons.arrow_back_ios_rounded,
                                    color: Colors.white, size: 18.w),
                              ),
                            )
                          : null,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      title: Align(
                          alignment: Alignment.centerRight,
                          child: _buildTextField()),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        children: [
                          strRestaurantImage!.isEmpty
                              ? Image.asset(
                                  'assets/ic_no_image.png',
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  strRestaurantImage!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5)),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(top: 40.h),
                              child: SimpleShadow(
                                opacity: 1,
                                color: Colors.black54,
                                offset: const Offset(0, 0),
                                sigma: 8,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.r),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(seconds: 5),
                                    child: strRestaurantImage!.isEmpty
                                        ? Container(
                                            color: Colors.white,
                                            child: Image.asset(
                                              'assets/ic_no_image.png',
                                              height: 100.h,
                                              width: 100.h,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Image.network(
                                            strRestaurantImage!,
                                            height: 100.h,
                                            width: 100.h,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22.w),
                    child: Visibility(
                      visible: !_keyboardIsVisible(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 22.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  strRestaurantsName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: Constants.appFontBold,
                                      fontSize: 36.sp),
                                ),
                              ),
                              if (widget.isFav != null)
                                GestureDetector(
                                  onTap: () {
                                    if (SharedPreferenceUtil.getBool(
                                        Constants.isLoggedIn)) {
                                      callAddRemoveFavorite(
                                          widget.restaurantId);
                                    } else {
                                      Constants.toastMessage(
                                          Languages.of(context)!
                                              .labelPleaseLoginToAddFavorite);
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        right: 5.w, top: 5.w, left: 20.w),
                                    child: isFavorite!
                                        ? SvgPicture.asset(
                                            'assets/ic_favourite_filled.svg',
                                            color: Constants.colorLike,
                                            width: 25.w,
                                            height: 25.w,
                                          )
                                        : SvgPicture.asset(
                                            'assets/ic_favourite_outline.svg',
                                            width: 25.w,
                                            height: 25.w,
                                          ),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            strRestaurantsAddress ?? 'Address not available',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: Constants.appFont,
                                color: Constants.colorBlack,
                                fontSize: 12.sp),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            "• " + cuisineItems,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: Constants.appFont,
                                color: Constants.colorBlack,
                                fontSize: 16.sp),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Row(
                            children: [
                              Row(
                                children: [
                                  RatingBar.builder(
                                    initialRating: strRestaurantsRate,
                                    ignoreGestures: true,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    itemSize: 24.w,
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
                                    '($strRestaurantsRate)',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontFamily: Constants.appFont,
                                      color: const Color(0xFF03041D),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 22.w),
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer_rounded,
                                    color: Constants.colorYellow,
                                    size: 22.w,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    '$strRestaurantsAvgTime mins',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontFamily: Constants.appFont,
                                      color: const Color(0xFF132229),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: Theme(
                      data: ThemeData(cardColor: Constants.colorTheme),
                      child: _searchListRestaurantsMenu.isNotEmpty ||
                              searchController.text.isNotEmpty
                          ? _searchListRestaurantsMenu.isNotEmpty
                              ? ScrollableListTabView(
                                  names: _searchListRestaurantsMenu
                                      .map((menu) => menu.name ?? 'N/A')
                                      .toList(),
                                  tabHeight: 40.h,
                                  tabs: _searchListRestaurantsMenu
                                      .map(
                                        (menu) => ScrollableListTab(
                                          tab: ListTab(
                                            label: Text(
                                              menu.name ?? 'N/A',
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontFamily:
                                                      Constants.appFont),
                                            ),
                                            activeBackgroundColor:
                                                Constants.colorYellow,
                                            inactiveBackgroundColor:
                                                Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15.r),
                                          ),
                                          body: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 22.w),
                                            itemCount:
                                                menu.submenu?.length ?? 0,
                                            itemBuilder: (_, index) =>
                                                FoodMenuItem(
                                              subMenu: menu.submenu![index],
                                              onSetState: callSetState,
                                              restaurantsId:
                                                  widget.restaurantId!,
                                              restaurantsImage:
                                                  strRestaurantImage!,
                                              restaurantsName:
                                                  strRestaurantsName!,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                )
                              : Center(
                                  child: Text(
                                    'Existing empty data!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(18),
                                      fontFamily: Constants.appFontBold,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                          : _listRestaurantsMenu.isNotEmpty
                              ? ScrollableListTabView(
                                  names: _listRestaurantsMenu
                                      .map((menu) => menu.name ?? 'N/A')
                                      .toList(),
                                  tabs: _listRestaurantsMenu
                                      .map(
                                        (menu) => ScrollableListTab(
                                          tab: ListTab(
                                            label: Text(
                                              menu.name ?? 'N/A',
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontFamily:
                                                      Constants.appFont),
                                            ),
                                            activeBackgroundColor:
                                                Constants.colorYellow,
                                            inactiveBackgroundColor:
                                                Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15.r),
                                          ),
                                          body: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 22.w),
                                            itemCount:
                                                menu.submenu?.length ?? 0,
                                            itemBuilder: (_, index) =>
                                                FoodMenuItem(
                                              subMenu: menu.submenu![index],
                                              onSetState: callSetState,
                                              restaurantsId:
                                                  widget.restaurantId!,
                                              restaurantsImage:
                                                  strRestaurantImage!,
                                              restaurantsName:
                                                  strRestaurantsName!,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                )
                              : Center(
                                  child: Text(
                                    Languages.of(context)!.labelNoData,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(18),
                                      fontFamily: Constants.appFontBold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<CommonResponse>> callAddRemoveFavorite(
      int? vegRestId) async {
    CommonResponse response;
    try {
      Map<String, String> body = {
        'id': vegRestId.toString(),
      };
      response = await RestClient(RetroApi().dioData()).favorite(body);
      print(response.success);
      if (response.success!) {
        Constants.toastMessage(response.data!);
        setState(() {
          isFavorite = !isFavorite!;
        });
      } else {
        Constants.toastMessage(Languages.of(context)!.labelErrorWhileUpdate);
      }
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<SingleRestaurantsDetailsModel>> callGetRestaurantsDetails(
      int? restaurantId) async {
    SingleRestaurantsDetailsModel response;
    try {
      setState(() {
        _isSyncing = true;
      });
      response =
          await RestClient(RetroApi().dioData()).singleVendor(restaurantId);
      if (response.success!) {
        setState(() {
          _isSyncing = false;
          strRestaurantsType = response.data!.vendor!.vendorType;
          strRestaurantsName = response.data!.vendor!.name;
          strRestaurantsForTwoPerson = response.data!.vendor!.forTwoPerson;
          strRestaurantsRate = response.data!.vendor!.rate.toDouble();
          strRestaurantsReview = response.data!.vendor!.review.toString();
          strRestaurantsAddress = response.data!.vendor!.mapAddress;
          strRestaurantsAvgTime = response.data!.vendor!.avgDeliveryTime ??
              widget.strRestaurantsAvgTime;
          _listRestaurantsMenu.addAll(response.data!.menu!);

          strRestaurantImage = response.data!.vendor!.image;

          List<String> cuisineList = [];
          var length = response.data!.vendor!.cuisine!.length > 2
              ? 2
              : response.data!.vendor!.cuisine!.length;
          for (int i = 0; i < length; i++) {
            cuisineList.add(response.data!.vendor!.cuisine![i].name!);
          }

          cuisineItems = cuisineList.join(" • ");

          _listCart.addAll(
              ScopedModel.of<CartModel>(context, rebuildOnChange: true).cart);

          if (_listCart.isNotEmpty) {
            for (int i = 0; i < _listCart.length; i++) {
              if (_listRestaurantsMenu.isNotEmpty) {
                for (int j = 0; j < _listRestaurantsMenu.length; j++) {
                  for (int k = 0;
                      k < _listRestaurantsMenu[j].submenu!.length;
                      k++) {
                    bool isRepeatCustomization;
                    int? repeatCustomization =
                        _listCart[i].isRepeatCustomization;
                    if (repeatCustomization == 1) {
                      isRepeatCustomization = true;
                    } else {
                      isRepeatCustomization = false;
                    }
                    if (_listRestaurantsMenu[j].submenu![k].id ==
                        _listCart[i].id) {
                      _listRestaurantsMenu[j].submenu![k].isAdded = true;
                      _listRestaurantsMenu[j].submenu![k].count =
                          _listCart[i].qty!;
                      _listRestaurantsMenu[j]
                          .submenu![k]
                          .isRepeatCustomization = isRepeatCustomization;
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
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  onSearchTextChanged(String text) {
    _searchListRestaurantsMenu.clear();
    print('[Search]: $text');
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for (int i = 0; i < _listRestaurantsMenu.length; i++) {
      for (int j = 0; j < _listRestaurantsMenu[i].submenu!.length; j++) {
        var submenu = _listRestaurantsMenu[i].submenu![j];
        var item = _listRestaurantsMenu[i];

        if (item.name!.toLowerCase().contains(text.toLowerCase()) ||
            submenu.name!.toLowerCase().contains(text.toLowerCase())) {
          _searchListRestaurantsMenu.add(item);
          _searchListRestaurantsMenu.toSet();
        }
      }
    }

    setState(() {});
  }
}

void _queryFirst(BuildContext context) async {
  CartModel model = CartModel();

  double tempTotal1 = 0, tempTotal2 = 0;
  _listCart.clear();
  totalCartAmount = 0;
  totalQty = 0;
  final allRows = await dbHelper.queryAllRows();
  print('query all rows:');
  for (var row in allRows) {
    print(row);
  }
  for (int i = 0; i < allRows.length; i++) {
    _listCart.add(Product(
      id: allRows[i]['pro_id'],
      restaurantsName: allRows[i]['restName'],
      title: allRows[i]['pro_name'],
      imgUrl: allRows[i]['pro_image'],
      price: double.parse(allRows[i]['pro_price']),
      qty: allRows[i]['pro_qty'],
      restaurantsId: allRows[i]['restId'],
      restaurantImage: allRows[i]['restImage'],
      foodCustomization: allRows[i]['pro_customization'],
      isRepeatCustomization: allRows[i]['isRepeatCustomization'],
      tempPrice: double.parse(allRows[i]['itemTempPrice'].toString()),
      itemQty: allRows[i]['itemQty'],
      isCustomization: allRows[i]['isCustomization'],
    ));

    model.addProduct(Product(
      id: allRows[i]['pro_id'],
      restaurantsName: allRows[i]['restName'],
      title: allRows[i]['pro_name'],
      imgUrl: allRows[i]['pro_image'],
      price: double.parse(allRows[i]['pro_price']),
      qty: allRows[i]['pro_qty'],
      restaurantsId: allRows[i]['restId'],
      restaurantImage: allRows[i]['restImage'],
      foodCustomization: allRows[i]['pro_customization'],
      isRepeatCustomization: allRows[i]['isRepeatCustomization'],
    ));
    if (allRows[i]['pro_customization'] == '') {
      totalCartAmount +=
          double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
      tempTotal1 +=
          double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
    } else {
      totalCartAmount +=
          double.parse(allRows[i]['pro_price']) + totalCartAmount;
      tempTotal2 += double.parse(allRows[i]['pro_price']);
    }

    print(totalCartAmount);

    print('First cart model cart data' +
        ScopedModel.of<CartModel>(context, rebuildOnChange: true)
            .cart
            .toString());
    print('First cart ListCart array' + _listCart.length.toString());
    print('First cart ListCart string' + _listCart.toString());

    totalQty += allRows[i]['pro_qty'] as int;
    print(totalQty);
  }

  print('TempTotal1 $tempTotal1');
  print('TempTotal2 $tempTotal2');
  totalCartAmount = tempTotal1 + tempTotal2;
}

class FoodMenuItem extends StatefulWidget {
  FoodMenuItem({
    required this.subMenu,
    required this.restaurantsName,
    required this.restaurantsId,
    required this.onSetState,
    required this.restaurantsImage,
    Key? key,
  }) : super(key: key);

  final SubMenuListData subMenu;
  final String restaurantsName;
  final String restaurantsImage;
  final int restaurantsId;
  final Function onSetState;
  final List<Product> _products = [];

  @override
  State<FoodMenuItem> createState() => _FoodMenuItemState();
}

class _FoodMenuItemState extends State<FoodMenuItem> {
  final defaultImageUrl =
      'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=3744&q=80';

  CartModel? get cartmodel => null;

  get model => null;

  @override
  Widget build(BuildContext context) {
    SubMenuListData item = widget.subMenu;
    return ScopedModelDescendant<CartModel>(
      builder: (context, child, model) {
        return SimpleShadow(
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
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: CachedNetworkImage(
                    width: 100.w,
                    height: 130.w,
                    imageUrl: item.image ?? defaultImageUrl,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (_, __, progress) => Center(
                      child: SizedBox(
                        width: 38.w,
                        height: 38.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          backgroundColor:
                              Constants.colorTheme.withOpacity(0.2),
                          valueColor:
                              AlwaysStoppedAnimation(Constants.colorTheme),
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
                        item.name ?? 'N/A',
                        style: TextStyle(
                            fontSize: 18.sp, fontFamily: Constants.appFontBold),
                      ),
                      if (item.custimization!.isNotEmpty) const Spacer(),
                      Text(
                        item.description ?? '',
                        style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: Constants.appFont,
                            color: Constants.colorTheme),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.custimization!.isNotEmpty) ...[
                        const Spacer(),
                        Text(
                          'Customizable',
                          style: TextStyle(
                              fontSize: 10.sp,
                              fontFamily: Constants.appFont,
                              color: Constants.colorGray,
                              fontStyle: FontStyle.italic),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5.h),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rs. ${item.price ?? 0}',
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: Constants.appFontBold),
                          ),
                          /*Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (item.custimization!.isNotEmpty &&
                                            item.isRepeatCustomization!) {
                                          int isRepeatCustomization =
                                              item.isRepeatCustomization!
                                                  ? 1
                                                  : 0;

                                          setState(() {
                                            if (item.count != 1) {
                                              item.count--;
                                            } else {
                                              item.isAdded = false;
                                              item.count = 0;
                                            }
                                          });
                                          model.updateProduct(
                                              item.id, item.count);
                                          print(
                                              "Total: ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                                  ScopedModel.of<CartModel>(
                                                          context,
                                                          rebuildOnChange: true)
                                                      .totalCartValue
                                                      .toString() +
                                                  "");
                                          print("Cart List" +
                                              ScopedModel.of<CartModel>(context,
                                                      rebuildOnChange: true)
                                                  .cart
                                                  .toString() +
                                              "");

                                          String? finalFoodCustomization;
                                          //String title;
                                          double? price, tempPrice;
                                          int? qty;
                                          for (int z = 0;
                                              z < model.cart.length;
                                              z++) {
                                            if (item.id == model.cart[z].id) {
                                              json.decode(model
                                                  .cart[z].foodCustomization!);
                                              finalFoodCustomization = model
                                                  .cart[z].foodCustomization;
                                              price = model.cart[z].price;
                                              // title = model.cart[z].title;
                                              qty = model.cart[z].qty;
                                              tempPrice =
                                                  model.cart[z].tempPrice;
                                            }
                                          }
                                          if (qty != null &&
                                              tempPrice != null) {
                                            price = tempPrice * qty;
                                          } else {
                                            price = 0;
                                          }

                                          _updateForCustomizedFood(
                                              item.id,
                                              item.count,
                                              price.toString(),
                                              item.price,
                                              item.image,
                                              item.name,
                                              widget.restaurantsId,
                                              widget.restaurantsName,
                                              finalFoodCustomization,
                                              widget.onSetState,
                                              isRepeatCustomization,
                                              1);
                                        } else {
                                          setState(() {
                                            if (item.count != 1) {
                                              item.count--;
                                              // ConstantsUtils.removeItem(widget.listRestaurantsMenu[widget.index].name, item,item.id);
                                            } else {
                                              item.isAdded = false;
                                              item.count = 0;
                                            }
                                          });
                                          model.updateProduct(
                                              item.id, item.count);
                                          print(
                                              "Total: ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                                  ScopedModel.of<CartModel>(
                                                          context,
                                                          rebuildOnChange: true)
                                                      .totalCartValue
                                                      .toString() +
                                                  "");
                                          print("Cart List" +
                                              ScopedModel.of<CartModel>(context,
                                                      rebuildOnChange: true)
                                                  .cart
                                                  .toString() +
                                              "");
                                          _update(
                                              item.id,
                                              item.count,
                                              item.price.toString(),
                                              item.image,
                                              item.name,
                                              widget.restaurantsId,
                                              widget.restaurantsName,
                                              widget.onSetState,
                                              0,
                                              0,
                                              0,
                                              '0');
                                        }
                                      },
                                      child: Icon(
                                        Icons.remove_circle_rounded,
                                        color: Constants.colorGray,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      '${item.count}',
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontFamily: Constants.appFontBold),
                                    ),
                                    SizedBox(width: 10.w),
                                    GestureDetector(
                                      onTap: () {
                                        if (item.qtyReset == 'daily' &&
                                            item.count >= item.availableItem!) {
                                          Constants.toastMessage(
                                            Languages.of(context)!.outOfStock,
                                          );
                                        } else {
                                          if (item.custimization!.isNotEmpty) {
                                            var jsonResponse;
                                            String? finalFoodCustomization;
                                            //String title;
                                            double price = 0;
                                            int qty = 0;

                                            for (int z = 0;
                                                z < model.cart.length;
                                                z++) {
                                              if (item.id == model.cart[z].id) {
                                                jsonResponse = json.decode(model
                                                    .cart[z]
                                                    .foodCustomization!);
                                                finalFoodCustomization = model
                                                    .cart[z].foodCustomization;
                                                price = model.cart[z].price!;
                                                //title = model.cart[z].title;
                                                qty = model.cart[z].qty!;
                                                // tempPrice = model.cart[z].tempPrice!;
                                              }
                                            }
                                            List<String?> nameOfCustomization =
                                                [];
                                            for (int i = 0;
                                                i < jsonResponse.length;
                                                i++) {
                                              nameOfCustomization.add(
                                                  jsonResponse[i]['data']
                                                      ['name']);
                                            }
                                            //  print('before starting ${price.toString()}');
                                            //  print('before starting tempPrice $tempPrice');
                                            item.isRepeatCustomization = true;

                                            updateCustomizationFoodDataToDB(
                                              finalFoodCustomization,
                                              item,
                                              model,
                                              price += price * qty,
                                            );
                                          } else {
                                            setState(() {
                                              item.count++;
                                            });
                                            model.updateProduct(
                                                item.id, item.count);
                                            print(
                                                "Total: ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                                    ScopedModel.of<CartModel>(
                                                            context,
                                                            rebuildOnChange:
                                                                true)
                                                        .totalCartValue
                                                        .toString() +
                                                    "");
                                            print("Cart List" +
                                                ScopedModel.of<CartModel>(
                                                        context,
                                                        rebuildOnChange: true)
                                                    .cart
                                                    .toString() +
                                                "");
                                            _update(
                                                item.id,
                                                item.count,
                                                item.price.toString(),
                                                item.image,
                                                item.name,
                                                widget.restaurantsId,
                                                widget.restaurantsName,
                                                widget.onSetState,
                                                0,
                                                0,
                                                0,
                                                '0');
                                          }
                                        }
                                      },
                                      child: Icon(
                                        Icons.add_circle_rounded,
                                        color: Constants.colorYellow,
                                      ),
                                    )
                                  ],
                                )*/
                          GestureDetector(
                            onTap: () {
                              if (item.qtyReset == 'daily' &&
                                  item.count >= item.availableItem!) {
                                Constants.toastMessage(
                                  Languages.of(context)!.outOfStock,
                                );
                              } else {
                                if (item.custimization!.isNotEmpty) {
                                  openFoodCustomizationBottomSheet(
                                      model,
                                      item,
                                      double.parse(item.price.toString()),
                                      totalCartAmount,
                                      totalQty,
                                      item.custimization!);
                                } else {
                                  if (ScopedModel.of<CartModel>(context,
                                          rebuildOnChange: true)
                                      .cart
                                      .isEmpty) {
                                    setState(() {
                                      item.isAdded = !item.isAdded!;
                                      item.count++;
                                    });
                                    widget._products.add(Product(
                                        id: item.id,
                                        qty: item.count,
                                        price:
                                            double.parse(item.price.toString()),
                                        imgUrl: item.image,
                                        title: item.name,
                                        restaurantsId: widget.restaurantsId,
                                        restaurantsName: widget.restaurantsName,
                                        restaurantImage:
                                            widget.restaurantsImage,
                                        foodCustomization: '',
                                        isRepeatCustomization: 0,
                                        isCustomization: 0,
                                        itemQty: 0,
                                        tempPrice: 0));
                                    model.addProduct(Product(
                                        id: item.id,
                                        qty: item.count,
                                        price:
                                            double.parse(item.price.toString()),
                                        imgUrl: item.image,
                                        title: item.name,
                                        restaurantsId: widget.restaurantsId,
                                        restaurantsName: widget.restaurantsName,
                                        restaurantImage:
                                            widget.restaurantsImage,
                                        foodCustomization: '',
                                        isRepeatCustomization: 0,
                                        isCustomization: 0,
                                        itemQty: 0,
                                        tempPrice: 0));
                                    print(
                                        "Total: ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                            ScopedModel.of<CartModel>(context,
                                                    rebuildOnChange: true)
                                                .totalCartValue
                                                .toString() +
                                            "");
                                    _insert(
                                        item.id,
                                        item.count,
                                        item.price.toString(),
                                        '0',
                                        item.image,
                                        item.name,
                                        item.qtyReset,
                                        item.availableItem,
                                        item.itemResetValue,
                                        widget.restaurantsId,
                                        widget.restaurantsName,
                                        widget.restaurantsImage,
                                        '',
                                        widget.onSetState,
                                        0,
                                        0,
                                        0,
                                        0);
                                  } else {
                                    print(widget.restaurantsId);
                                    print(ScopedModel.of<CartModel>(context,
                                            rebuildOnChange: true)
                                        .getRestId());
                                    if (widget.restaurantsId !=
                                        ScopedModel.of<CartModel>(context,
                                                rebuildOnChange: true)
                                            .getRestId()) {
                                      showDialogRemoveCart(
                                          ScopedModel.of<CartModel>(context,
                                                  rebuildOnChange: true)
                                              .getRestName(),
                                          widget.restaurantsName);
                                    } else {
                                      setState(() {
                                        item.isAdded = !item.isAdded!;
                                        item.count++;
                                      });
                                      widget._products.add(Product(
                                          id: item.id,
                                          qty: item.count,
                                          price: double.parse(
                                              item.price.toString()),
                                          imgUrl: item.image,
                                          title: item.name,
                                          restaurantsId: widget.restaurantsId,
                                          restaurantsName:
                                              widget.restaurantsName,
                                          restaurantImage:
                                              widget.restaurantsImage,
                                          foodCustomization: '',
                                          isCustomization: 0,
                                          isRepeatCustomization: 0,
                                          itemQty: 0,
                                          tempPrice: 0));
                                      model.addProduct(Product(
                                          id: item.id,
                                          qty: item.count,
                                          price: double.parse(
                                              item.price.toString()),
                                          imgUrl: item.image,
                                          title: item.name,
                                          restaurantsId: widget.restaurantsId,
                                          restaurantsName:
                                              widget.restaurantsName,
                                          restaurantImage:
                                              widget.restaurantsImage,
                                          foodCustomization: '',
                                          isRepeatCustomization: 0,
                                          isCustomization: 0,
                                          itemQty: 0,
                                          tempPrice: 0));
                                      print(
                                          "Total: ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                              ScopedModel.of<CartModel>(context,
                                                      rebuildOnChange: true)
                                                  .totalCartValue
                                                  .toString() +
                                              "");
                                      _insert(
                                          item.id,
                                          item.count,
                                          item.price.toString(),
                                          '0',
                                          item.image,
                                          item.name,
                                          item.qtyReset,
                                          item.availableItem,
                                          item.itemResetValue,
                                          widget.restaurantsId,
                                          widget.restaurantsName,
                                          widget.restaurantsImage,
                                          '',
                                          widget.onSetState,
                                          0,
                                          0,
                                          0,
                                          0);
                                    }
                                  }
                                }
                              }
                            },
                            child: Icon(
                              Icons.add_circle_rounded,
                              color: Constants.colorYellow,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showDialogRemoveCart(String? restName, String? currentRestName) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, bottom: 0, top: 10),
              child: SizedBox(
                height: ScreenUtil().setHeight(170),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Languages.of(context)!.labelRemoveCartItem,
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
                    SizedBox(
                      height: ScreenUtil().setHeight(5),
                    ),
                    const Divider(
                      thickness: 1,
                      color: Color(0xffcccccc),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: ScreenUtil().setHeight(5),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(70),
                          child: Text(
                            '${Languages.of(context)!.labelYourCartContainsDishesFrom} $restName. ${Languages.of(context)!.labelYourCartContains1} $currentRestName?',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 4,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(14),
                                fontFamily: Constants.appFont,
                                color: Constants.colorBlack),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(5),
                        ),
                        const Divider(
                          thickness: 1,
                          color: Color(0xffcccccc),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  Languages.of(context)!.labelNoGoBack,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Constants.appFontBold,
                                      color: Constants.colorGray),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    ScopedModel.of<CartModel>(context,
                                            rebuildOnChange: true)
                                        .clearCart();
                                    _deleteTable();
                                    setState(() {
                                      totalQty = 0;
                                      totalCartAmount = 0;
                                    });
                                  },
                                  child: Text(
                                    Languages.of(context)!.labelYesRemoveIt,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: Constants.appFontBold,
                                        color: Constants.colorBlue),
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

  void _insert(
      int? proId,
      int? proQty,
      String proPrice,
      String currentPriceWithoutCustomization,
      String? proImage,
      String? proName,
      String? qtyReset,
      int? availableItem,
      int? itemResetValue,
      int? restId,
      String? restName,
      String? restImage,
      String customization,
      Function? onSetState,
      int isRepeatCustomization,
      int isCustomization,
      int itemQty,
      double tempPrice) async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnProId: proId,
      DatabaseHelper.columnProImageUrl: proImage,
      DatabaseHelper.columnProName: proName,
      DatabaseHelper.columnProPrice: proPrice,
      DatabaseHelper.columnProQty: proQty,
      DatabaseHelper.columnRestId: restId,
      DatabaseHelper.columnRestName: restName,
      DatabaseHelper.columnRestImage: restImage,
      DatabaseHelper.columnProCustomization: customization,
      DatabaseHelper.columnIsRepeatCustomization: isRepeatCustomization,
      DatabaseHelper.columnIsCustomization: isCustomization,
      DatabaseHelper.columnItemQty: itemQty,
      DatabaseHelper.columnItemTempPrice: tempPrice,
      DatabaseHelper.columnCurrentPriceWithoutCustomization:
          currentPriceWithoutCustomization,
      DatabaseHelper.columnQTYReset: qtyReset,
      DatabaseHelper.columnAvailableItem: availableItem,
      DatabaseHelper.columnItemResetValue: itemResetValue,
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
    _query(widget.onSetState);
  }

  void _updateForCustomizedFood(
      int? proId,
      int? proQty,
      String proPrice,
      String? currentPriceWithoutCustomization,
      String? proImage,
      String? proName,
      int? restId,
      String? restName,
      String? customization,
      Function onSetState,
      int isRepeatCustomization,
      int isCustomization) async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnProId: proId,
      DatabaseHelper.columnProImageUrl: proImage,
      DatabaseHelper.columnProName: proName,
      DatabaseHelper.columnProPrice: proPrice,
      DatabaseHelper.columnProQty: proQty,
      DatabaseHelper.columnRestId: restId,
      DatabaseHelper.columnRestName: restName,
      DatabaseHelper.columnProCustomization: customization,
      DatabaseHelper.columnIsRepeatCustomization: isRepeatCustomization,
      DatabaseHelper.columnIsCustomization: isRepeatCustomization,
      DatabaseHelper.columnCurrentPriceWithoutCustomization:
          currentPriceWithoutCustomization,
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');

    _query(onSetState);
  }

  void _update(
      int? proId,
      int? proQty,
      String proPrice,
      String? proImage,
      String? proName,
      int? restId,
      String? restName,
      Function onSetState,
      int isRepeatCustomization,
      int isCustomization,
      int itemQty,
      String customizationTempPrice) async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnProId: proId,
      DatabaseHelper.columnProImageUrl: proImage,
      DatabaseHelper.columnProName: proName,
      DatabaseHelper.columnProPrice: proPrice,
      DatabaseHelper.columnProQty: proQty,
      DatabaseHelper.columnRestId: restId,
      DatabaseHelper.columnRestName: restName,
      DatabaseHelper.columnIsRepeatCustomization: isRepeatCustomization,
      DatabaseHelper.columnIsCustomization: isCustomization,
      DatabaseHelper.columnItemQty: itemQty,
      DatabaseHelper.columnItemTempPrice: customizationTempPrice,
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');

    _query(onSetState);
  }

  void _query(Function onSetState) async {
    double tempTotal1 = 0, tempTotal2 = 0;
    _listCart.clear();
    totalCartAmount = 0;
    totalQty = 0;
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');
    for (var row in allRows) {
      print(row);
    }
    for (int i = 0; i < allRows.length; i++) {
      _listCart.add(Product(
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
      if (allRows[i]['pro_customization'] == '') {
        totalCartAmount +=
            double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
        tempTotal1 +=
            double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
      } else {
        totalCartAmount +=
            double.parse(allRows[i]['pro_price']) + totalCartAmount;
        tempTotal2 += double.parse(allRows[i]['pro_price']);
      }

      print(totalCartAmount);

      totalQty += allRows[i]['pro_qty'] as int;
      print(totalQty);
    }

    print('TempTotal1 $tempTotal1');
    print('TempTotal2 $tempTotal2');
    totalCartAmount = tempTotal1 + tempTotal2;
    onSetState();
  }

  void _deleteTable() async {
    final table = await dbHelper.deleteTable();
    print('table deleted $table');
  }

  void openFoodCustomizationBottomSheet(
    CartModel cartModel,
    SubMenuListData item,
    double currentFoodItemPrice,
    double totalCartAmount,
    int totalQty,
    List<Custimization> custimization,
  ) {
    print('open $currentFoodItemPrice');
    double tempPrice = 0;
    currentFoodItemPrice = 0;
    List<String> _listForAPI = [];

    List<CustomizationItemModel> _listCustomizationItem = [];
    List<int> _radioButtonFlagList = [];
    List<CustomModel> _listFinalCustomization = [];
    _listFinalCustomizationCheck.clear();
    for (int i = 0; i < custimization.length; i++) {
      String? myJSON = custimization[i].customizationItem;
      if (custimization[i].customizationItem != null) {
        _listFinalCustomizationCheck.add(true);
      } else {
        _listFinalCustomizationCheck.add(false);
      }
      if (custimization[i].customizationItem != null) {
        var json = jsonDecode(myJSON!);

        _listCustomizationItem = (json as List)
            .map((i) => CustomizationItemModel.fromJson(i))
            .toList();

        for (int j = 0; j < _listCustomizationItem.length; j++) {
          print(_listCustomizationItem[j].name);
        }
        _listFinalCustomization
            .add(CustomModel(custimization[i].name, _listCustomizationItem));

        for (int k = 0; k < _listFinalCustomization[i].list.length; k++) {
          if (_listFinalCustomization[i].list[k].isDefault == 1) {
            _listFinalCustomization[i].list[k].isSelected = false;
            _radioButtonFlagList.add(k);
            /*       currentFoodItemPrice +=
                double.parse(_listFinalCustomization[i].list[k].price);*/

            tempPrice +=
                double.parse(_listFinalCustomization[i].list[k].price!);
            _listForAPI.add(
                '{"main_menu":"${_listFinalCustomization[i].title}","data":{"name":"${_listFinalCustomization[i].list[k].name}","price":"${_listFinalCustomization[i].list[k].price}"}}');
          } else {
            _listFinalCustomization[i].list[k].isSelected = false;
          }
        }
        print(_listFinalCustomization.length);
        print('temp ' + tempPrice.toString());
      } else {
        _listFinalCustomization
            .add(CustomModel(custimization[i].name, _listCustomizationItem));
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
                                    '${Languages.of(context)!.labelItem} ${totalQty + 1}'
                                    '  |  '
                                    '${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} ${currentFoodItemPrice + tempPrice}',
                                    style: TextStyle(
                                        fontFamily: Constants.appFont,
                                        color: Constants.colorWhite,
                                        fontSize: ScreenUtil().setSp(16)),
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
                                print(
                                    '===================Continue with List Data=================');
                                print(_listForAPI.toString());

                                addCustomizationFoodDataToDB(
                                    _listForAPI.toString(),
                                    item,
                                    cartModel,
                                    currentFoodItemPrice + tempPrice,
                                    currentFoodItemPrice,
                                    false,
                                    0,
                                    0);
                              },
                              child: Container(
                                color: Constants.colorBlack,
                                child: Center(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: Languages.of(context)!
                                              .labelContinue,
                                          style: TextStyle(
                                              fontFamily: Constants.appFont,
                                              color: Constants.colorWhite,
                                              fontSize: ScreenUtil().setSp(16)),
                                        ),
                                        WidgetSpan(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: SvgPicture.asset(
                                              'assets/ic_green_arrow.svg',
                                              width: 15,
                                              height:
                                                  ScreenUtil().setHeight(15),
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
                              padding: EdgeInsets.only(
                                  top: ScreenUtil().setHeight(20),
                                  left: ScreenUtil().setWidth(10)),
                              child: Text(
                                _listFinalCustomization[outerIndex].title!,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: Constants.appFontBold),
                              ),
                            ),
                            _listFinalCustomization[outerIndex].list.isNotEmpty
                                ? _listFinalCustomizationCheck[outerIndex] ==
                                        true
                                    ? ListView.builder(
                                        itemBuilder: (context, innerIndex) {
                                          print(
                                              "print the index of inner loop $innerIndex outer index is $outerIndex");
                                          return Padding(
                                              padding: EdgeInsets.only(
                                                  top: ScreenUtil()
                                                      .setHeight(10),
                                                  left: ScreenUtil()
                                                      .setWidth(20)),
                                              child: InkWell(
                                                onTap: () {
                                                  // changeIndex(index);
                                                  print({
                                                    'On Tap tempPrice : ' +
                                                        tempPrice.toString()
                                                  });

                                                  if (!_listFinalCustomization[
                                                          outerIndex]
                                                      .list[innerIndex]
                                                      .isSelected!) {
                                                    tempPrice = 0;
                                                    _listForAPI.clear();
                                                    setState(() {
                                                      _radioButtonFlagList[
                                                              outerIndex] =
                                                          innerIndex;

                                                      for (var element
                                                          in _listFinalCustomization[
                                                                  outerIndex]
                                                              .list) {
                                                        element.isSelected =
                                                            false;
                                                      }
                                                      _listFinalCustomization[
                                                              outerIndex]
                                                          .list[innerIndex]
                                                          .isSelected = true;

                                                      for (int i = 0;
                                                          i <
                                                              _listFinalCustomization
                                                                  .length;
                                                          i++) {
                                                        for (int j = 0;
                                                            j <
                                                                _listFinalCustomization[
                                                                        i]
                                                                    .list
                                                                    .length;
                                                            j++) {
                                                          if (_listFinalCustomization[
                                                                  i]
                                                              .list[j]
                                                              .isSelected!) {
                                                            tempPrice +=
                                                                double.parse(
                                                                    _listFinalCustomization[
                                                                            i]
                                                                        .list[j]
                                                                        .price!);

                                                            print(
                                                                _listFinalCustomization[
                                                                        i]
                                                                    .title);
                                                            print(
                                                                _listFinalCustomization[
                                                                        i]
                                                                    .list[j]
                                                                    .name);
                                                            print(
                                                                _listFinalCustomization[
                                                                        i]
                                                                    .list[j]
                                                                    .isDefault);
                                                            print(
                                                                _listFinalCustomization[
                                                                        i]
                                                                    .list[j]
                                                                    .isSelected);
                                                            print(
                                                                _listFinalCustomization[
                                                                        i]
                                                                    .list[j]
                                                                    .price);

                                                            _listForAPI.add(
                                                                '{"main_menu":"${_listFinalCustomization[i].title}","data":{"name":"${_listFinalCustomization[i].list[j].name}","price":"${_listFinalCustomization[i].list[j].price}"}}');
                                                            print(_listForAPI
                                                                .toString());
                                                          }
                                                        }
                                                      }
                                                    });
                                                  }
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          _listFinalCustomization[
                                                                  outerIndex]
                                                              .list[innerIndex]
                                                              .name,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  Constants
                                                                      .appFont,
                                                              fontSize:
                                                                  ScreenUtil()
                                                                      .setSp(
                                                                          14)),
                                                        ),
                                                        Text(
                                                          SharedPreferenceUtil
                                                                  .getString(
                                                                      Constants
                                                                          .appSettingCurrencySymbol) +
                                                              ' ' +
                                                              _listFinalCustomization[
                                                                      outerIndex]
                                                                  .list[
                                                                      innerIndex]
                                                                  .price!,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  Constants
                                                                      .appFont,
                                                              fontSize:
                                                                  ScreenUtil()
                                                                      .setSp(
                                                                          14)),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right: ScreenUtil()
                                                              .setWidth(20)),
                                                      child: _radioButtonFlagList[
                                                                  outerIndex] ==
                                                              innerIndex
                                                          ? getChecked()
                                                          : getUnChecked(),
                                                    ),
                                                  ],
                                                ),
                                              ));
                                        },
                                        itemCount:
                                            _listFinalCustomization[outerIndex]
                                                .list
                                                .length,
                                        shrinkWrap: true,
                                        physics: const ClampingScrollPhysics(),
                                      )
                                    : SizedBox(
                                        height: ScreenUtil().setHeight(100),
                                        child: Center(
                                          child: Text(
                                            Languages.of(context)!
                                                .noCustomizationAvailable,
                                            style: TextStyle(
                                                fontFamily:
                                                    Constants.appFontBold,
                                                fontSize:
                                                    ScreenUtil().setSp(18)),
                                          ),
                                        ),
                                      )
                                : SizedBox(
                                    height: ScreenUtil().setHeight(100),
                                    child: Center(
                                      child: Text(
                                        Languages.of(context)!
                                            .noCustomizationAvailable,
                                        style: TextStyle(
                                            fontFamily: Constants.appFontBold,
                                            fontSize: ScreenUtil().setSp(18)),
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

  void openUpdateFoodCustomizationBottomSheet(
      CartModel cartModel,
      SubMenuListData item,
      double currentFoodItemPrice,
      double totalCartAmount,
      int totalQty,
      List<Custimization> custimization,
      int isRepeat) {
    print(currentFoodItemPrice);
    double tempPrice = currentFoodItemPrice;

    List<String> _listForAPI = [];

    List<CustomizationItemModel> _listCustomizationItem = [];
    List<int> _radioButtonFlagList = [];
    List<CustomModel> _listFinalCustomization = [];
    for (int i = 0; i < custimization.length; i++) {
      String? myJSON = custimization[i].customizationItem;
      if (custimization[i].customizationItem != null) {
        var json = jsonDecode(myJSON!);
        tempPrice += currentFoodItemPrice;
        _listCustomizationItem = (json as List)
            .map((i) => CustomizationItemModel.fromJson(i))
            .toList();

        for (int j = 0; j < _listCustomizationItem.length; j++) {
          print(_listCustomizationItem[j].name);
        }
        _listFinalCustomization
            .add(CustomModel(custimization[i].name, _listCustomizationItem));

        for (int k = 0; k < _listFinalCustomization[i].list.length; k++) {
          if (_listFinalCustomization[i].list[k].isDefault == 1) {
            _listFinalCustomization[i].list[k].isSelected = true;
            _radioButtonFlagList.add(k);
            /*       currentFoodItemPrice +=
                double.parse(_listFinalCustomization[i].list[k].price);*/

            tempPrice +=
                double.parse(_listFinalCustomization[i].list[k].price!);
            _listForAPI.add(
                '{"main_menu":"${_listFinalCustomization[i].title}","data":{"name":"${_listFinalCustomization[i].list[k].name}","price":"${_listFinalCustomization[i].list[k].price}"}}');
          } else {
            _listFinalCustomization[i].list[k].isSelected = false;
          }
        }
        print(_listFinalCustomization.length);
        print('temp ' + tempPrice.toString());
      } else {
        _listFinalCustomization
            .add(CustomModel(custimization[i].name, _listCustomizationItem));
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
                                    'Item ${totalQty + 1}'
                                    '  |  '
                                    '${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} ${currentFoodItemPrice + tempPrice}',
                                    style: TextStyle(
                                        fontFamily: Constants.appFont,
                                        color: Constants.colorWhite,
                                        fontSize: ScreenUtil().setSp(16)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            // ic_green_arrow.svg
                            child: InkWell(
                              onTap: () {
                                // item.itemQty = item.count + item.itemQty;
                                item.itemQty = item.itemQty + 1;
                                Navigator.pop(context);
                                print(
                                    '=================== Continue with List Data =================');
                                print(_listForAPI.toString());
                                addCustomizationFoodDataToDB(
                                    _listForAPI.toString(),
                                    item,
                                    cartModel,
                                    currentFoodItemPrice + tempPrice,
                                    currentFoodItemPrice,
                                    true,
                                    isRepeat,
                                    item.itemQty);
                              },
                              child: Container(
                                color: Constants.colorBlack,
                                child: Center(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Continue',
                                          style: TextStyle(
                                              fontFamily: Constants.appFont,
                                              color: Constants.colorWhite,
                                              fontSize: ScreenUtil().setSp(16)),
                                        ),
                                        WidgetSpan(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: SvgPicture.asset(
                                              'assets/ic_green_arrow.svg',
                                              width: 15,
                                              height:
                                                  ScreenUtil().setHeight(15),
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
                              padding: EdgeInsets.only(
                                  top: ScreenUtil().setHeight(20),
                                  left: ScreenUtil().setWidth(10)),
                              child: Text(
                                _listFinalCustomization[outerIndex].title!,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: Constants.appFontBold),
                              ),
                            ),
                            _listFinalCustomization[outerIndex].list.isNotEmpty
                                ? ListView.builder(
                                    itemBuilder: (context, innerIndex) {
                                      return Padding(
                                          padding: EdgeInsets.only(
                                              top: ScreenUtil().setHeight(10),
                                              left: ScreenUtil().setWidth(20)),
                                          child: InkWell(
                                            onTap: () {
                                              // changeIndex(index);
                                              print({
                                                'On Tap tempPrice : ' +
                                                    tempPrice.toString()
                                              });

                                              if (!_listFinalCustomization[
                                                      outerIndex]
                                                  .list[innerIndex]
                                                  .isSelected!) {
                                                tempPrice = 0;
                                                _listForAPI.clear();
                                                setState(() {
                                                  _radioButtonFlagList[
                                                      outerIndex] = innerIndex;

                                                  for (var element
                                                      in _listFinalCustomization[
                                                              outerIndex]
                                                          .list) {
                                                    element.isSelected = false;
                                                  }
                                                  _listFinalCustomization[
                                                          outerIndex]
                                                      .list[innerIndex]
                                                      .isSelected = true;

                                                  for (int i = 0;
                                                      i <
                                                          _listFinalCustomization
                                                              .length;
                                                      i++) {
                                                    for (int j = 0;
                                                        j <
                                                            _listFinalCustomization[
                                                                    i]
                                                                .list
                                                                .length;
                                                        j++) {
                                                      if (_listFinalCustomization[
                                                              i]
                                                          .list[j]
                                                          .isSelected!) {
                                                        tempPrice += double.parse(
                                                            _listFinalCustomization[
                                                                    i]
                                                                .list[j]
                                                                .price!);

                                                        print(
                                                            _listFinalCustomization[
                                                                    i]
                                                                .title);
                                                        print(
                                                            _listFinalCustomization[
                                                                    i]
                                                                .list[j]
                                                                .name);
                                                        print(
                                                            _listFinalCustomization[
                                                                    i]
                                                                .list[j]
                                                                .isDefault);
                                                        print(
                                                            _listFinalCustomization[
                                                                    i]
                                                                .list[j]
                                                                .isSelected);
                                                        print(
                                                            _listFinalCustomization[
                                                                    i]
                                                                .list[j]
                                                                .price);

                                                        _listForAPI.add(
                                                            '{"main_menu":"${_listFinalCustomization[i].title}","data":{"name":"${_listFinalCustomization[i].list[j].name}","price":"${_listFinalCustomization[i].list[j].price}"}}');
                                                        print(_listForAPI
                                                            .toString());
                                                      }
                                                    }
                                                  }
                                                });
                                              }
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _listFinalCustomization[
                                                              outerIndex]
                                                          .list[innerIndex]
                                                          .name,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              Constants.appFont,
                                                          fontSize: ScreenUtil()
                                                              .setSp(14)),
                                                    ),
                                                    Text(
                                                      SharedPreferenceUtil
                                                              .getString(Constants
                                                                  .appSettingCurrencySymbol) +
                                                          ' ' +
                                                          _listFinalCustomization[
                                                                  outerIndex]
                                                              .list[innerIndex]
                                                              .price!,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              Constants.appFont,
                                                          fontSize: ScreenUtil()
                                                              .setSp(14)),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: ScreenUtil()
                                                          .setWidth(20)),
                                                  child: _radioButtonFlagList[
                                                              outerIndex] ==
                                                          innerIndex
                                                      ? getChecked()
                                                      : getUnChecked(),
                                                ),
                                              ],
                                            ),
                                          ));
                                    },
                                    itemCount:
                                        _listFinalCustomization[outerIndex]
                                            .list
                                            .length,
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                  )
                                : SizedBox(
                                    height: ScreenUtil().setHeight(100),
                                    child: Center(
                                      child: Text(
                                        Languages.of(context)!
                                            .noCustomizationAvailable,
                                        style: TextStyle(
                                            fontFamily: Constants.appFontBold,
                                            fontSize: ScreenUtil().setSp(18)),
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
      height: ScreenUtil().setHeight(25),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SvgPicture.asset(
          'assets/ic_check.svg',
          width: 15,
          height: ScreenUtil().setHeight(15),
        ),
      ),
      decoration: myBoxDecorationChecked(false, Constants.colorTheme),
    );
  }

  Widget getUnChecked() {
    return Container(
      width: 25,
      height: ScreenUtil().setHeight(25),
      decoration: myBoxDecorationChecked(true, Constants.colorWhite),
    );
  }

  BoxDecoration myBoxDecorationChecked(bool isBorder, Color color) {
    return BoxDecoration(
      color: color,
      border: isBorder ? Border.all(width: 1.0) : null,
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
    );
  }

  void addCustomizationFoodDataToDB(
      String customization,
      SubMenuListData item,
      CartModel model,
      double cartPrice,
      double currentPriceWithoutCustomization,
      bool isFromAddRepeatCustomization,
      int iRepeat,
      int itemQty) {
    int isRepeat = iRepeat;

    if (ScopedModel.of<CartModel>(context, rebuildOnChange: true)
        .cart
        .isEmpty) {
      setState(() {
        if (!isFromAddRepeatCustomization) {
          item.isAdded = !item.isAdded!;
        }
        item.count++;
      });
      widget._products.add(Product(
          id: item.id,
          qty: item.count,
          price: cartPrice,
          imgUrl: item.image,
          title: item.name,
          restaurantsId: widget.restaurantsId,
          restaurantsName: widget.restaurantsName,
          restaurantImage: widget.restaurantsImage,
          foodCustomization: customization,
          isCustomization: 1,
          isRepeatCustomization: isRepeat,
          itemQty: itemQty,
          tempPrice: cartPrice));
      model.addProduct(Product(
          id: item.id,
          qty: item.count,
          price: cartPrice,
          imgUrl: item.image,
          title: item.name,
          restaurantsId: widget.restaurantsId,
          restaurantsName: widget.restaurantsName,
          restaurantImage: widget.restaurantsImage,
          foodCustomization: customization,
          isCustomization: 1,
          isRepeatCustomization: isRepeat,
          tempPrice: cartPrice,
          itemQty: item.itemQty));
      print(
          "Total: ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
              ScopedModel.of<CartModel>(context, rebuildOnChange: true)
                  .totalCartValue
                  .toString() +
              "");
      _insert(
        item.id,
        item.count,
        cartPrice.toString(),
        currentPriceWithoutCustomization.toString(),
        item.image,
        item.name,
        item.qtyReset,
        item.availableItem,
        item.itemResetValue,
        widget.restaurantsId,
        widget.restaurantsName,
        widget.restaurantsImage,
        customization,
        widget.onSetState,
        isRepeat,
        1,
        item.itemQty,
        cartPrice,
      );
    } else {
      print(widget.restaurantsId);
      print(ScopedModel.of<CartModel>(context, rebuildOnChange: true)
          .getRestId());
      if (widget.restaurantsId !=
          ScopedModel.of<CartModel>(context, rebuildOnChange: true)
              .getRestId()) {
        showDialogRemoveCart(
            ScopedModel.of<CartModel>(context, rebuildOnChange: true)
                .getRestName(),
            widget.restaurantsName);
      } else {
        setState(() {
          if (!isFromAddRepeatCustomization) {
            item.isAdded = !item.isAdded!;
          }
          item.count++;
        });
        widget._products.add(Product(
            id: item.id,
            qty: item.count,
            price: cartPrice,
            imgUrl: item.image,
            title: item.name,
            restaurantsId: widget.restaurantsId,
            restaurantsName: widget.restaurantsName,
            restaurantImage: widget.restaurantsImage,
            foodCustomization: customization,
            isCustomization: 1,
            isRepeatCustomization: isRepeat,
            tempPrice: cartPrice,
            itemQty: itemQty));
        model.addProduct(Product(
            id: item.id,
            qty: item.count,
            price: cartPrice,
            imgUrl: item.image,
            title: item.name,
            restaurantsId: widget.restaurantsId,
            restaurantsName: widget.restaurantsName,
            restaurantImage: widget.restaurantsImage,
            foodCustomization: customization,
            isCustomization: 1,
            isRepeatCustomization: isRepeat,
            tempPrice: cartPrice,
            itemQty: itemQty));
        print(
            "Total: ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                ScopedModel.of<CartModel>(context, rebuildOnChange: true)
                    .totalCartValue
                    .toString() +
                "");
        _insert(
          item.id,
          item.count,
          cartPrice.toString(),
          currentPriceWithoutCustomization.toString(),
          item.image,
          item.name,
          item.qtyReset,
          item.availableItem,
          item.itemResetValue,
          widget.restaurantsId,
          widget.restaurantsName,
          widget.restaurantsImage,
          customization,
          widget.onSetState,
          isRepeat,
          1,
          item.itemQty,
          cartPrice,
        );
      }
    }
  }

  void updateCustomizationFoodDataToDB(String? customization,
      SubMenuListData item, CartModel model, double cartPrice) {
    setState(() {
      item.count++;
      // ConstantsUtils.addCartItem(widget.listRestaurantsMenu[widget.index].name, item,item.count,int.parse(item.price));
      /*              ConstantsUtils.allItems
                                      .add(Cart(widget.listRestaurantsMenu[widget.index].name, submenu));*/
    });
    model.updateProduct(item.id, item.count);
    print(
        "Total: ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
            ScopedModel.of<CartModel>(context, rebuildOnChange: true)
                .totalCartValue
                .toString() +
            "");
    print("Cart List" +
        ScopedModel.of<CartModel>(context, rebuildOnChange: true)
            .cart
            .toString() +
        "");
    int isRepeatCustomization = item.isRepeatCustomization! ? 1 : 0;
    _updateForCustomizedFood(
        item.id,
        item.count,
        cartPrice.toString(),
        item.price,
        item.image,
        item.name,
        widget.restaurantsId,
        widget.restaurantsName,
        customization,
        widget.onSetState,
        isRepeatCustomization,
        1);
  }
}

class CustomModel {
  List<CustomizationItemModel> list = [];
  final String? title;

  CustomModel(this.title, this.list);
}
