// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mealup/utils/widgets/constants.dart';

class CateringHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          color: Constants.colorBackground,
          image: DecorationImage(
            image: AssetImage(
              'assets/catering.png',
            ),
            opacity: 0.04,
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(85.0, 85, 85, 50),
              child: Column(
                children: [
                  Image.asset(
                    'assets/daig.png',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                '    Choose from the Best\nCatering Service Providers',
                style: TextStyle(
                    fontFamily: Constants.appFontBold,
                    color: Constants.colorBlack,
                    fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 8, 15, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Restaurants',
                    style: TextStyle(
                        color: Colors.red[900],
                        fontFamily: Constants.appFontBold),
                  ),
                  Text(
                    'See All',
                    style: TextStyle(
                        color: Colors.black, fontFamily: Constants.appFont),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: 15,
                  itemBuilder: (context, index) {
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        height: 150,
                        padding: const EdgeInsets.all(0),
                        child: Row(children: [
                          Expanded(
                            flex: 6,
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    'https://cdn.shopify.com/s/files/1/0063/6348/0177/files/NAFEES-ONLINE-_1_03b93bae-575f-4724-b762-afbb35239ef6.png?v=1595689882',
                                    height: 150.0,
                                    width: 100.0,
                                  ),
                                )),
                          ),
                          Spacer(
                            flex: 1,
                          ),
                          Expanded(
                            flex: 14,
                            child: Container(
                              padding: const EdgeInsets.only(top: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("Title",
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold)),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        'Barcode : ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "barcode",
                                        style: TextStyle(fontSize: 15.0),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        'Harga : ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        'harga',
                                        style: TextStyle(fontSize: 20),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    ));
  }
}
