import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class CustomHomeAppBar extends StatelessWidget with PreferredSizeWidget {
  final Function()? onOfferTap, onSearchTap, onLocationTap, onFilterTap;
  bool? isFilter = false;

  String? selectedAddress = '';
  CustomHomeAppBar({
    Key? key,
    required this.onOfferTap,
    this.isFilter,
    required this.onSearchTap,
    required this.onLocationTap,
    this.onFilterTap,
    this.selectedAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onLocationTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 15.w),
                  child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18.w),
                ),
              ),
              // const Icon(Icons.near_me_rounded, color: Colors.white),
              // SizedBox(width: 5.w),
              // Text(
              //   selectedAddress!.isEmpty || selectedAddress == null
              //       ? Languages.of(context)!.labelSelectAddress
              //       : selectedAddress!.length > 20
              //           ? selectedAddress!.substring(0, 20) + '...'
              //           : selectedAddress!,
              //   overflow: TextOverflow.ellipsis,
              //   style: TextStyle(fontSize: 16.0, fontFamily: Constants.appFont),
              // ),
              // Icon(Icons.keyboard_arrow_down, color: Constants.colorYellow),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onOfferTap,
              child: const Icon(Icons.local_offer_rounded, color: Colors.white),
            ),
            SizedBox(width: 20.w),
            Visibility(
              visible: isFilter!,
              child: Padding(
                padding: EdgeInsets.only(right: 20.w),
                child: GestureDetector(
                  onTap: onFilterTap,
                  child: const Icon(Icons.filter_alt_rounded, color: Colors.white),
                ),
              ),
            ),
            GestureDetector(
              onTap: onSearchTap,
              child: const Icon(Icons.search_rounded, color: Colors.white),
            ),
          ],
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
