import 'package:flutter/material.dart';
import 'package:flutter_app/customer_ui/cust_sigle_tripdetail.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_app/utilities/constant.dart';

import 'package:flutter_app/core/dbmodels/trip.dart';
import 'package:firebase_database/firebase_database.dart';
import 'bar_drawer.dart';
import 'package:flutter_app/core/functions/trip_methods.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_app/push_notification_service.dart';

import 'add_fvt_location.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'search_pickup.dart';
import 'package:flutter_app/core/model/address.dart';
import 'fvt_locations.dart';
import 'package:flutter_app/customer_ui/customer_bill.dart';
import 'package:flutter_app/core/dbmodels/trip.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/core/dbmodels/nearbyDrivers.dart';
import 'package:flutter_app/core/helper/firehelper.dart';
import 'package:flutter_app/customer_ui/searchpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/helper/helperMethod.dart';
import 'package:flutter_app/customer_ui/massage_screen.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'package:flutter_app/utilities/customer_buttons.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_app/utilities/location.dart' as LocationManager;
import 'package:flutter_app/core/dbmodels/driver.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'bar_drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_app/utilities/brandDivider.dart';
import 'package:flutter_app/core/dataprovider/appData.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'search_map.dart';

class CustomerTripHistoryClass extends StatefulWidget {
  @override
  _CustomerTripHistoryClassState createState() =>
      _CustomerTripHistoryClassState();
}

class _CustomerTripHistoryClassState extends State<CustomerTripHistoryClass> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      //drawer: CusDrawerPage(context),
      appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(appBarHeight), // here the desired height
          child: CusAppBarClass(context, 'Trip History', false, _scaffoldKey)),

      body: Historylist(),
    );
  }

  Widget Historylist() {
    return StreamBuilder(
        stream: constant_role == 0
            ? FirebaseDatabase.instance
                .reference()
                .child('rideRequest')
                .orderByChild('rider_id')
                .equalTo(currentUserInfo.id)
                // .orderByChild('timestamp')
                // .limitToFirst(20)
                .onValue
            : FirebaseDatabase.instance
                .reference()
                .child('rideRequest')
                .orderByChild('driver_id')
                .equalTo(currentUserInfo.id)
                // .orderByChild('timestamp')
                // .limitToFirst(20)
                .onValue,
        builder: (BuildContext context, AsyncSnapshot<Event> snap) {
          if (snap.hasError) return Text('Error: ${snap.error}');
          if (!snap.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Loading..."),
                  SizedBox(
                    height: 50.0,
                  ),
                  CircularProgressIndicator()
                ],
              ),
            );
          } else if (snap.data.snapshot.value != null) {
            if (snap.data.snapshot.value.length == 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 50.0,
                    ),
                    Text("NO TRIP HISTORY"),
                    SizedBox(
                      height: 50.0,
                    ),
                  ],
                ),
              );
            } else {
              Map<dynamic, dynamic> map = snap.data.snapshot.value;
              List<dynamic> list = map.values.toList();

              return Container(
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () async {
                          tripHistory.clear();
                          if (constant_role == 0) {
                            DatabaseReference updateRef = FirebaseDatabase
                                .instance
                                .reference()
                                .child('users/${list[index]["driver_id"]}');
                            updateRef.once().then((DataSnapshot event) async {
                              setState(() {
                                driver_img = event.value["displayImage"];
                              });
                            });
                          } else {
                            DatabaseReference updateRef = FirebaseDatabase
                                .instance
                                .reference()
                                .child('users/${list[index]["rider_id"]}');
                            updateRef.once().then((DataSnapshot event) async {
                              setState(() {
                                driver_img = event.value["displayImage"];
                              });
                            });
                          }
                          var _tripHistory = Trip(
                            tripID: list[index]["trip_id"],
                            destination_address: list[index]
                                ["destination_address"],
                            destination_latitude: list[index]["destination"]
                                ["latitude"],
                            destination_longitude: list[index]["destination"]
                                ["longitude"],
                            driver_id: list[index]["driver_id"],
                            pickup_address: list[index]["pickup_address"],
                            pickup_latitude: list[index]["location"]
                                ["latitude"],
                            pickup_longitude: list[index]["location"]
                                ["longitude"],
                            payment_method: list[index]["payment_method"],
                            request_to: list[index]["request_to"],
                            request_to_status: list[index]["request_to_status"],
                            rider_id: list[index]["rider_id"],
                            rider_name: list[index]["rider_name"],
                            rider_phone: list[index]["rider_phone"],
                            status: list[index]["status"],
                            tag: list[index]["tag"],
                            driver_name: list[index]["driver_name"],
                            driver_phone: list[index]["driver_phone"],
                            driver_latitude: list[index]["driver_location"]
                                ["latitude"],
                            driver_longitude: list[index]["driver_location"]
                                ["longitude"],
                            total_EstimatedFare:
                                list[index]["total_EstimatedFare"].toString(),
                            base_EstimatedFare:
                                list[index]["base_EstimatedFare"].toString(),
                            distance_EstimatedFare: list[index]
                                    ["distance_EstimatedFare"]
                                .toString(),
                            time_EstimatedFare:
                                list[index]["time_EstimatedFare"].toString(),
                            distance: list[index]["distance"].toString(),
                            ride_start: list[index]["ride_start"],
                            ride_end: list[index]["ride_end"],
                            complaintByCustomer: list[index]
                                ["complaintByCustomer"],
                            complaintByDriver: list[index]["complaintByDriver"],
                            feedback_to_driver: list[index]
                                ["feedback_to_driver"],
                            feedback_to_customer: list[index]
                                ["feedback_to_customer"],
                          );

                          await tripHistory.add(_tripHistory);

                          date = list[index]["date"];
                          time = list[index]["time"];
                          timestamp = list[index]["timestamp"];

                          AppRoutes.push(context, CustomerSingleTripDetail());
                        },
                        child: Card(
                            margin: EdgeInsets.all(10),

                            //  padding: EdgeInsets.all(20),
                            // decoration: BoxDecoration(
                            //     color: whtColor,
                            //     border: Border(bottom: BorderSide(width: 1, color: lightGray))

                            // ),
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // time and cash row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            constant_role == 0
                                                ? list[index]["driver_name"] ??
                                                    'Driver'
                                                : list[index]["rider_name"] ??
                                                    'Customer',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800),
                                          ),
                                          Container(
                                            child: Text(
                                              list[index]["date"] ?? '',
                                              style: TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              list[index]["time"] ?? '',
                                              style: TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          //    Flexible(child:Text('Trip ID: ${list[index]["rider_id"]}', style: TextStyle(fontSize: 12, )),),
                                          Text(
                                            'QAR ${list[index]["total_EstimatedFare"]}' ??
                                                'QAR ${(index + 1) * 6}',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'Cash',
                                            style: TextStyle(
                                                color: lightGray,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),

                                  //    mapImage()
                                  /*       Container(
      margin: EdgeInsets.all(15),
      child: Column(
        children: [
          Text(
            'From:\n '+list[index]["pickup_address"]??
            'From:\n Shop 56 Al Arab Center Street no 4, sector 94, Sharjah Dubai',
            
             style: TextStyle( color: DarkGray),),
          Text(
            
            '\n\nTo:\n ' + list[index]["destination_address"]??
            '\n\nTo:\n Shop 56 Al Arab Center Street no 4, sector 94, Sharjah Dubai'
            
            , style: TextStyle(  color: DarkGray),),

         ],
      ),
    ),
   
*/
                                ],
                              ),
                            )),
                      );
                    }),
              );
            }
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 50.0,
                  ),
                  Text("NO TRIP HISTORY"),
                  SizedBox(
                    height: 50.0,
                  ),
                ],
              ),
            );
          }
        });
  }

  Widget historyTile(int index) {
    return GestureDetector(
      onTap: () {
        AppRoutes.push(context, CustomerSingleTripDetail());
      },
      child: Card(
          margin: EdgeInsets.all(10),

          //  padding: EdgeInsets.all(20),
          // decoration: BoxDecoration(
          //     color: whtColor,
          //     border: Border(bottom: BorderSide(width: 1, color: lightGray))

          // ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // time and cash row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          constant_role == 0 ? 'Driver Name' : 'Customer Name',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${(index + 1) * 3}/${(index + 1) * 2}/2020,  ${(index + 1) * 2}:55 ${index.isOdd ? 'AM' : 'PM'}',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Trip ID: 049583785',
                            style: TextStyle(
                              fontSize: 14,
                            )),
                        Text(
                          'QAR ${(index + 1) * 6}',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Cash',
                          style: TextStyle(
                              color: lightGray,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),

                //   mapImage()
              ],
            ),
          )),
    );
  }

  Widget mapImage() {
    return Container(
      width: MediaQuery.of(context).size.width * .9,
      height: MediaQuery.of(context).size.height * .15,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                'assets/map.png',
              ),
              fit: BoxFit.fill)),
    );
  }
}
