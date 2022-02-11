import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mealup/utils/widgets/constants.dart';
import 'package:mealup/utils_google_map/place_service.dart';
import 'package:simple_shadow/simple_shadow.dart';

class AddressSearch extends SearchDelegate<SuggestionWithLatLong> {
  AddressSearch(this.sessionToken) {
    apiClient = PlaceApiProvider(sessionToken);
  }

  final String sessionToken;
  late PlaceApiProvider apiClient;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  // @override
  // Widget
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        SuggestionWithLatLong suggestion1 = SuggestionWithLatLong('', '', 0.0, 0.0);
        close(context, suggestion1);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<SuggestionWithLatLong>>(
      future: query == ""
          ? null
          : Future.delayed(const Duration(seconds: 1), () async {
              return await apiClient.fetchLatitudeLongitude(query, Localizations.localeOf(context).languageCode);
            }),
      builder: (context, snapshot) => query == ''
          ? Center(
              child: Text(
                'Search Address',
                style: TextStyle(color: Constants.colorGray, fontSize: 16.sp),
              ),
            )
          : snapshot.hasData
              ? Scaffold(
                  resizeToAvoidBottomInset: true,
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 22.h),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              close(context, snapshot.data![index]);
                            },
                            child: SimpleShadow(
                              opacity: 0.6,
                              color: Colors.black12,
                              offset: const Offset(0, 0),
                              sigma: 2,
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 22.w),
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text((snapshot.data![index]).description),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: Constants.colorGray, fontSize: 16.sp),
                  ),
                ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<SuggestionWithLatLong>>(
      future: query == ""
          ? null
          : Future.delayed(const Duration(seconds: 1), () async {
              return await apiClient.fetchLatitudeLongitude(query, Localizations.localeOf(context).languageCode);
            }),
      builder: (context, snapshot) => query == ''
          ? Center(
              child: Text(
                'Search Address',
                style: TextStyle(color: Constants.colorGray, fontSize: 16.sp),
              ),
            )
          : snapshot.hasData
              ? Scaffold(
                  resizeToAvoidBottomInset: true,
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 22.h),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              close(context, snapshot.data![index]);
                            },
                            child: SimpleShadow(
                              opacity: 0.6,
                              color: Colors.black12,
                              offset: const Offset(0, 0),
                              sigma: 2,
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 22.w),
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text((snapshot.data![index]).description),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: Constants.colorGray, fontSize: 16.sp),
                  ),
                ),
    );
  }
}
