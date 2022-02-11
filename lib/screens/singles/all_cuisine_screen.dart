import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:mealup/model/all_cuisines_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/singles/single_cuisine_details_screen.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils/widgets/customs/custom_app_bar.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:simple_shadow/simple_shadow.dart';

class AllCuisineScreen extends StatefulWidget {
  const AllCuisineScreen({Key? key}) : super(key: key);

  @override
  _AllCuisineScreenState createState() => _AllCuisineScreenState();
}

class _AllCuisineScreenState extends State<AllCuisineScreen> {
  final List<AllCuisineData> _allCuisineListData = [];

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    Constants.checkNetwork().whenComplete(() => callAllCuisine());
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    Constants.checkNetwork().whenComplete(() => callAllCuisine());
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
            title: 'Cuisines',
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
              child: _allCuisineListData.isEmpty
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
                  : GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.w),
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: _allCuisineListData.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 22.w, crossAxisSpacing: 22.w),
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
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
                                  SizedBox(height: 2.h),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _allCuisineListData[index].name!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(fontFamily: Constants.appFontBold, fontSize: 20.sp),
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
        ),
      ),
    );
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
}
