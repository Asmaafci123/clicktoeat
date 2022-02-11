import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomHomeScreen extends StatefulWidget {
  const CustomHomeScreen({Key? key}) : super(key: key);

  @override
  State<CustomHomeScreen> createState() => _CustomHomeScreenState();
}

class _CustomHomeScreenState extends State<CustomHomeScreen> {
  late ScrollController _scrollController;

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
  }

  bool get _isSliverAppBarExpanded {
    return _scrollController.hasClients && _scrollController.offset > (194.h - kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/backgrounds/ic_home_background.jpg'), alignment: Alignment.topCenter),
      ),
      child: SafeArea(
        child: Scaffold(
          body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 250.h,
                  pinned: true,
                  snap: true,
                  floating: true,
                  forceElevated: true,
                  backgroundColor: const Color(0xFF252627),
                  automaticallyImplyLeading: false,
                  title: const Text(
                    'Home Screen',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  // bottom: BottomCarousel(visibility: _visibility),
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
            body: ListView.builder(
              itemCount: 20,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: Container(padding: const EdgeInsets.all(8), width: 100, child: const Placeholder()),
                  title: Text('Place ${index + 1}', textScaleFactor: 2),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
