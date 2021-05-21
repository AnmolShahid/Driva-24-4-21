import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/core/dbmodels/driver.dart';
import 'package:flutter_app/core/model/directionDetails.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_app/core/helper/helperMethod.dart';
import 'package:flutter_app/customer_ui/massage_screen.dart';
import 'package:flutter_app/driver_ui/bill_screen.dart';
import 'package:flutter_app/utilities/brandDivider.dart';
import 'package:flutter_app/utilities/customer_buttons.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_app/utilities/flutter_switch.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_app/utilities/location.dart' as LocationManager;
import 'bar_drawer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_app/push_notification_service.dart';
import 'package:flutter_app/core/dbmodels/trip.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'package:flutter_app/core/dataprovider/appData.dart';
import 'package:provider/provider.dart';

class DriverHomeClass extends StatefulWidget {
  @override
  _DriverHomeClassState createState() => _DriverHomeClassState();
}

class _DriverHomeClassState extends State<DriverHomeClass> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  User user = FirebaseAuth.instance.currentUser;
  bool onlineStatus = true;
  int rideStatus = 0;
  bool gotLocation = false;
  var geoLocator = Geolocator();
  // declared only for ui showing nxt screen
  bool reached = false;
  DatabaseReference tripRequestRef;
  //DirectionDetails tripDirectionDetails;
// firebase

  DatabaseReference msgReference =
      FirebaseDatabase.instance.reference().child('message').push();
  DatabaseReference rideReference;
  DatabaseReference tripReference;
  bool istripRef = false;
  Position myPosition;
// map veriables and controller
  GoogleMapController _controller;
  final CameraPosition _initialPosition =
      CameraPosition(target: LatLng(24.903623, 67.198367));
  static var latt = 31.476101;
  // static var latt =32.1009479;
  static var longg = 74.280672;
  // static var longg = 74.190527;
  static LatLng currentlocation = LatLng(latt, longg);
  LatLng _lastMapPosition = currentlocation;
  Set<Marker> markers = new Set<Marker>();
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  String trip_id;
  Set<Marker> _Markers = {};
  Set<Circle> _Circle = {};
  Position position;
  bool isLoading = true;

  Position currentPosition;

  String durationString;

  LatLng oldPosition;

  var driver_feed;

  void showSnackBar(String title) {
    final snackBar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      //resizeToAvoidBottom: false,
      key: _scaffoldKey,
      drawer: DriverDrawerPage(context),
      appBar: AppBar(
        backgroundColor: whtColor,
        elevation: 0,
        actions: [
          rideStatus == 0 ||
                  rideStatus == 1 ||
                  rideStatus == 2 ||
                  rideStatus == 5
              ? Container(
                  margin: EdgeInsets.all(10),
                  child: FlutterSwitch(
                    width: 90,
                    height: 35,
                    valueFontSize: 12,
                    toggleSize: 35.0,
                    activeColor: Colors.green,
                    inactiveColor: Colors.redAccent,
                    activeIcon: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    inactiveIcon: Icon(Icons.remove_circle_outline_outlined,
                        color: Colors.redAccent),
                    value: onlineStatus,
                    borderRadius: 30.0,
                    padding: 3.0,
                    activeText: "Online",
                    inactiveText: "Offline",
                    showOnOff: true,
                    onToggle: (val) {
                      setState(() {
                        onlineStatus = val;

                        if (onlineStatus == true) {
                          //  var _duration = Duration(seconds:3);
                          //     Timer(_duration, rideRequest);
                          setState(() {
                            geoOnline(onlineStatus);
                            checkRequest();
                          });
                        } else {
                          geoOnline(onlineStatus);
                        }
                      });
                    },
                  ),
                )
              : Container()
        ],
        leading: GestureDetector(
          onTap: () {
            _scaffoldKey.currentState.openDrawer();
          },
          child: Icon(
            Icons.menu,
            color: DarkGray,
          ),
        ),
      ),
      body: isLoading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SizedBox(
              child: Stack(
                children: [
                  mapWidget(),
                  _controllLayer(),
                ],
              ),
            ),

      // floatingActionButton: statusChangeBar(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget mapWidget() {
    return GoogleMap(
      initialCameraPosition:
          CameraPosition(target: currentlocation, zoom: 15.0),
      polylines: _polylines,
      myLocationEnabled: true,
      markers: _Markers,
      circles: _Circle,
      myLocationButtonEnabled: true,
      mapType: MapType.normal,
      onMapCreated: _onMapCreated,
      onCameraMove: _onCameraMove,
      zoomControlsEnabled: false,
      mapToolbarEnabled: true,
    );
  }

  Widget _controllLayer() {
    return Container(
      height: MediaQuery.of(context).size.height * .9,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //   statusChangeBar(),
          rideStatus == 4 || rideStatus == 2
              ? Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  padding: EdgeInsets.all(10),
                  color: Colors.black,
                  child: Row(
                    children: [
                      Icon(
                        Icons.assistant_direction,
                        size: 30,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Text(
                          rideStatus == 4
                              ? tripList[0].destination_address == null
                                  ? 'House no 20, block no 502 ,Aprt # 201, Street 50, Phase 4, near Ali baba store, opposite rawali GT Road, Lahore'
                                  : tripList[0].destination_address
                              : tripList[0].pickup_address == null
                                  ? 'House no 20, block no 502 ,Aprt # 201, Street 50, Phase 4, near Ali baba store, opposite rawali GT Road, Lahore'
                                  : tripList[0].pickup_address,
                          overflow: TextOverflow.clip,
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ))
              : SizedBox(),
          bottomWidgetChanger()
        ],
      ),
    );
  }

  Widget statusChangeBar() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      padding: EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //  rideStatus==1? declineButton():SizedBox(),
          SizedBox(
            width: 5,
          ),
          //  requestLocation()
          //  statusButton()
        ],
      ),
    );
  }

  Widget requestLocation() {
    return GestureDetector(
      child: Container(
        width: MediaQuery.of(context).size.width - 105,
        height: 40,
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Text(
          'Decline',
          style: TextStyle(color: whtColor, fontSize: 14),
        ),
      ),
    );
  }

  Widget declineButton() {
    return GestureDetector(
      child: Container(
        width: 80,
        height: 40,
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
        decoration: BoxDecoration(
            color: redColor,
            border: Border.all(width: 0, color: DarkGray),
            borderRadius: BorderRadius.circular(20)),
        child: Text(
          'Decline',
          style: TextStyle(color: whtColor, fontSize: 14),
        ),
      ),
    );
  }

  Widget statusButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      height: 30,
      width: 80,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: onlineStatus ? primaryColor : whtColor,
          border: Border.all(width: 1, color: primaryColor)),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeIn,
            top: 1,
            left: onlineStatus ? 45 : 0,
            right: onlineStatus ? 0 : 45,
            child: GestureDetector(
              onTap: statusChangePress,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    child: child,
                    scale: animation,
                  );
                },
                child: onlineStatus
                    ? Icon(
                        Icons.check_circle,
                        color: green,
                        size: 25,
                        key: UniqueKey(),
                      )
                    : Icon(
                        Icons.remove_circle_outline,
                        color: redColor,
                        size: 25,
                        key: UniqueKey(),
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget bottomWidgetChanger() {
    return onlineStatus
        ? rideStatus == 0
            ? _ifOnline()
            : rideStatus == 1
                ? driverOnTheWay()
                : rideStatus == 2
                    ? driverOnTheWay()
                    : driverOnTheWay()
        : _ifOffline();
  }

  Widget _ifOffline() {
    // return PrimaryButton(FillColor: green,Heading: 'You are offline',onTap: statusChangePress,);
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded, size: 14),
          SizedBox(
            width: 2,
          ),
          Text('You are offline'),
        ],
      ),
    );
  }

  Widget _ifOnline() {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle_notifications, size: 14),
          SizedBox(
            width: 2,
          ),
          Text('You are online'),
        ],
      ),
    );
  }

  Widget rideStatusRequest() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: whtColor, borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Text(
            'Estimated Fair  QAR 15',
            style: TextStyle(
                fontSize: 20,
                backgroundColor: whtColor,
                fontWeight: FontWeight.bold),
          ),
          PrimaryButton(
            FillColor: green,
            Heading: 'Accept',
            onTap: acceptPressed,
          )
        ],
      ),
    );
  }

  Widget driverOnTheWay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 10),
          color: whtColor,
          child: Column(
            children: [
              // Driver name and Time Row

              Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl: driver_img,
                          imageBuilder: (context, imageProvider) => Container(
                            height: 50,
                            width: 50,
                            // color: Colors.white
                            margin: EdgeInsets.only(right: 15),

                            decoration: new BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            rideStatus == 2
                                ? Text(
                                    'Picking up',
                                    overflow: TextOverflow.visible,
                                    style: TextStyle(
                                        color: DarkGray,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  )
                                : rideStatus == 3
                                    ? Text(
                                        'Arrived & Waiting',
                                        overflow: TextOverflow.visible,
                                        style: TextStyle(
                                            color: DarkGray,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : rideStatus == 4 || rideStatus == 5
                                        ? Text(
                                            'Dropping Off',
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(
                                                color: DarkGray,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          )
                                        : Container(),
                            Text(
                              tripList[0].rider_name == null
                                  ? 'Customer Name'
                                  : tripList[0].rider_name,
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                  color: DarkGray,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                        rideStatus == 1
                            ? tripDirectionDetails == null
                                ? Container(
                                    margin: EdgeInsets.only(
                                      left: 10,
                                    ),
                                    padding: EdgeInsets.only(
                                        left: 20, right: 20, top: 5, bottom: 5),
                                    color: rideStatus == 5
                                        ? Colors.red
                                        : Colors.black,
                                    child: Text(
                                        rideStatus == 3 ? '\nWaiting' : '',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: whtColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  )
                                : Container(
                                    margin: EdgeInsets.only(
                                      left: 10,
                                    ),
                                    padding: EdgeInsets.only(
                                        left: 20, right: 20, top: 5, bottom: 5),
                                    color: Colors.black,
                                    child: Text(
                                        tripDirectionDetails.durationText +
                                            '\n' +
                                            tripDirectionDetails.distanceText,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: whtColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  )
                            : SizedBox()
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // image and detail Row
                    rideStatus == 1
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Image.asset(
                                      'assets/pickicon.png',
                                      height: 16,
                                      width: 16,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 0),
                                      child: Dash(
                                          direction: Axis.vertical,
                                          length: 35,
                                          dashLength: 4,
                                          dashColor: Colors.grey),
                                    ),
                                    Image.asset(
                                      'assets/desticon.png',
                                      height: 16,
                                      width: 16,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                height: 100,
                                width: MediaQuery.of(context).size.width - 85,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Expanded(
                                      child: Text(
                                        tripList[0].pickup_address == null
                                            ? 'Barkat wala gala, Bismillah Colony, Gujranwala'
                                            : tripList[0].pickup_address,
                                        overflow: TextOverflow.clip,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Expanded(
                                      child: Text(
                                        tripList[0].destination_address == null
                                            ? 'Appt. no 32, Phase IV, Street 59, Ring Road Lahore'
                                            : tripList[0].destination_address,
                                        overflow: TextOverflow.clip,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                // Massega and calling row
                              ),
                            ],
                          )
                        : Container(),
                    rideStatus > 1 && rideStatus < 4
                        ? BrandDivider()
                        : SizedBox(),
                    SizedBox(
                      height: 10,
                    ),
                    rideStatus > 1 && rideStatus < 6
                        ? _callMessageButton()
                        : SizedBox(),
                    // rideStatus==3?Container(padding: EdgeInsets.all(10),child: Text('Change Address'),):SizedBox(),
                    rideStatus > 1 && rideStatus < 4
                        ? BrandDivider()
                        : SizedBox(),
                  ],
                ),
              ),

              SizedBox(
                height: 10,
              ),

              rideStatus == 1
                  ? PrimaryButton(
                      FillColor: green,
                      Heading: 'Accept',
                      onTap: acceptPressed,
                    )
                  : rideStatus == 2
                      ? PrimaryButton(
                          FillColor: green,
                          Heading: 'Arrived',
                          onTap: arrivedPress,
                        )
                      : rideStatus == 3
                          ? PrimaryButton(
                              FillColor: green,
                              Heading: 'Start Trip',
                              onTap: startRidePress,
                            )
                          : rideStatus == 4
                              ? PrimaryButton(
                                  FillColor: Colors.red,
                                  Heading: 'Complete Trip',
                                  onTap: rideCompletPress,
                                )
                              : rideStatus == 5
                                  ? PrimaryButton(
                                      FillColor: green,
                                      Heading: 'Calculate Fare',
                                      onTap: collectCash)
                                  : SizedBox(),
              rideStatus == 1 || rideStatus == 2
                  ? FlatButton(
                      child:
                          Text('Decline', style: TextStyle(color: Colors.red)),
                      onPressed: declinePressed,
                    )
                  : SizedBox(),
            ],
          ),
        )
      ],
    );
  }

  Widget _callMessageButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FlatButton(
            onPressed: () {
              print(tripList[0].rider_phone);
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    elevation: 16,
                    child: Container(
                        height: 200.0,
                        width: 360.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(tripList[0].rider_phone),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RaisedButton(
                                  child: Text('Call'),
                                  onPressed: () {
                                    launch("tel:${tripList[0].rider_phone}");
                                  },
                                ),
                                /*   SizedBox(width: 5,),
                      RaisedButton(child: Text('Cancel'),
                      onPressed: (){
                        Navigator.of(context).pop();
                      },),*/
                              ],
                            )
                          ],
                        )),
                  );
                },
              );
            },
            child: Row(
              children: [
                Icon(
                  Icons.call,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text('Call')
              ],
            )),
        FlatButton(
            onPressed: () {
              massegePress();
            },
            child: Row(
              children: [
                Icon(
                  Icons.message,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text('Message')
              ],
            )),
        /*  FlatButton(
            onPressed: () {},
            child: Row(
              children: [
                Icon(
                  Icons.cancel,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text('Cancel')
              ],
            ))
            */
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getUserLocation();
    //  listnerMessage();
    getCurrentDriverInfo();
    setState(() {});
    geoOnline(true);
    HelperMethods.getCurrentUSerInfo();
    startTime();
    getUserData();
    setState(() {});
    checkRequest();
  }

  void listnerMessage() {
    msgReference.onValue.listen((event) {
      print('Triggered Listener on -- ADDED -- friend info');
      print(
          'info that changed: ${event.snapshot.key}: ${event.snapshot.value}');
      if (event.snapshot.key == 'sent_to') {
        var sent_to = event.snapshot.value;
        msg = true;
        if (constant_uid == sent_to) {
          showSnackBar('New Message');
        }
      }
    });
  }

  startTime() async {
    var _duration = Duration(seconds: 0);
    return Timer(_duration, getUserLocation);
  }

  getUserData() {
    DatabaseReference driverReference = FirebaseDatabase.instance
        .reference()
        .child('users/${currentUserInfo.id}');
    driverReference.once().then((DataSnapshot dataSnapshot) async {
      total_km = dataSnapshot.value["distance"];

      total_earn = dataSnapshot.value["total"];
      /*  DatabaseReference  driverR = FirebaseDatabase.instance.reference()
                  .child('rideRequest')
                  .orderByChild('driver_id')
                  .equalTo(currentUserInfo.id);
              driverR.once().then((DataSnapshot dataSnapsh) async {
                  totol_ride = dataSnapsh.value.length;
                });*/
    });
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
    //position.target = _lastMapPosition;
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  void getUserLocation() async {
    
    final GoogleMapController mapController = await _controller;
    setState(() {
      isLoading = false;
    });
    var currentLocation = <String, double>{};
    final location = LocationManager.Location();

    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    currentLocation = await location.getLocation();

    final lat = currentLocation["latitude"];
    final lng = currentLocation["longitude"];
    setState(() {
      latt = lat;
      longg = lng;
      gotLocation = true;
    });
    DatabaseReference teRef = FirebaseDatabase.instance
        .reference()
        .child('users/${currentUserInfo.id}');

    Map currentPosition = {'lat': lat, 'lng': lng};
    teRef.child('position').set(currentPosition);

    PushNotificationService p = PushNotificationService();
    var token = await p.getToken();

    print('Your Latitude is: $latt, Longitude is: $longg');
    try {
      await _controller
          .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(lat, lng),
        zoom: 15,
      )));
    } catch (e) {
      AppRoutes.replace(context, DriverHomeClass());
      currentLocation = null;
      return null;
    }
    setState(() {});
    String address =
        await HelperMethods.findCordinateAddress(position, context);

    location.onLocationChanged().listen((event) {
      currentLocation = event;
      DatabaseReference teRef = FirebaseDatabase.instance
          .reference()
          .child('users/${currentUserInfo.id}');

      Map currentPosition = {
        'lat': currentLocation["latitude"],
        'lng': currentLocation["longitude"]
      };
      if (onlineStatus) {
        teRef.child('position').set(currentPosition);

        Geofire.setLocation(user.uid, currentLocation["latitude"],
            currentLocation["longitude"]);
      }
    });
    rideReference =
        FirebaseDatabase.instance.reference().child('users/${user.uid}/newReq');
    await checkRequest();

    
  }

  Future<void> geoOnline(status) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    User user = FirebaseAuth.instance.currentUser;
    Geofire.initialize('driversAvailable');
    if (status) {
      Geofire.setLocation(user.uid, position.latitude, position.longitude);

      tripRequestRef = FirebaseDatabase.instance
          .reference()
          .child('users/${user.uid}/newtrip');
      tripRequestRef.set('waiting');

      tripRequestRef.onValue.listen((event) {
        print(event.snapshot.key);
      });
    } else if (!status) {
      tripRequestRef = FirebaseDatabase.instance
          .reference()
          .child('users/${user.uid}/newtrip');
      tripRequestRef.set('offline');
      Geofire.removeLocation(user.uid);
    }
  }

  void getCurrentDriverInfo() async {
    //  PushNotificationService p = PushNotificationService();
    //   p.setUpFirebase();
    //   p.getToken();
    User user = FirebaseAuth.instance.currentUser;
    DatabaseReference driverRef = FirebaseDatabase.instance
        .reference()
        .child("users/${currentUserInfo.id}");
    driverRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        currentDriverInfo = Drivers.fromSnapshot(snapshot);
      }
    });

    PushNotificationService p = PushNotificationService();

    var token = await p.getToken();
  }

  // online status change button
  void statusChangePress() {
    setState(() {
      onlineStatus = !onlineStatus;
    });
    if (onlineStatus == true) {
      var _duration = Duration(seconds: 2);
      Timer(_duration, rideRequest);

      geoOnline(true);
    }
  }

  void massegePress() {
    AppRoutes.push(context, MassageScreen());
  }

  void rideRequest() {
    //  setState(() {
    //   rideStatus=1;
    //  });
  }
  void acceptPressed() async {
//status
//1 = accepted
//0 = pending
//2 = cancel
//9 = arrived
//3 = on the way
//4 = complated
//5 = calculate fare

    // add driver details
    DatabaseReference rideRef =
        FirebaseDatabase.instance.reference().child('rideRequest/${trip_id}');

    rideRef.child('driver_name').set(currentUserInfo.username);
    rideRef.child('driver_phone').set(currentUserInfo.phone);
    rideRef.child('driver_id').set(currentUserInfo.id);
    rideRef.child('driver_image').set(currentUserInfo.displayImage);

    Map locationMap = {
      'latitude': latt.toString(),
      'longitude': longg.toString(),
    };
    rideRef.child('driver_location').set(locationMap);
    rideRef.child('request_to_status').set(1);
    rideRef.child('status').set(1);
    DatabaseReference tripRef =
        FirebaseDatabase.instance.reference().child('rideRequest/${trip_id}');
    tripRef.once().then((DataSnapshot dataSnapshot) async {
      var trip = Trip(
          tripID: trip_id,
          destination_address: dataSnapshot.value["destination_address"],
          destination_latitude: dataSnapshot.value["destination"]["latitude"],
          destination_longitude: dataSnapshot.value["destination"]["longitude"],
          driver_id: dataSnapshot.value["driver_id"],
          pickup_address: dataSnapshot.value["pickup_address"],
          pickup_latitude: dataSnapshot.value["location"]["latitude"],
          pickup_longitude: dataSnapshot.value["location"]["longitude"],
          payment_method: dataSnapshot.value["payment_method"],
          request_to: dataSnapshot.value["request_to"],
          request_to_status: dataSnapshot.value["request_to_status"],
          rider_id: dataSnapshot.value["rider_id"],
          rider_name: dataSnapshot.value["rider_name"],
          rider_phone: dataSnapshot.value["rider_phone"],
          status: dataSnapshot.value["status"],
          tag: dataSnapshot.value["tag"]);
      setState(() {
        tripList.clear();
        custom_rider = dataSnapshot.value["rider_name"];
        custom_rider_id = dataSnapshot.value["rider_id"];
        custom_trip_id = trip_id;
      });
      tripList.add(trip);
      print(tripList.length);
      DatabaseReference updat = FirebaseDatabase.instance
          .reference()
          .child('users/${custom_rider_id}');
      updat.once().then((DataSnapshot event) async {
        setState(() {
          driver_img = event.value["displayImage"];
          driver_feed = event.value["feedback"];
        });
      });
    });
    setState(() {
      rideStatus = 2;
    });
    await getDirectiontoCustomer();
    getLocationUpdates();

    DatabaseReference checkDriverLocation = FirebaseDatabase.instance
        .reference()
        .child('users/${user.uid}/position');

    checkDriverLocation.onChildChanged.listen((event) async {
      print('Triggered Listener on -- CHANGED -- friend info');
      print(
          'info that changed: ${event.snapshot.key}: ${event.snapshot.value}');
      //  await  getDirectiontoCustomer();

      Map locationMap = {
        'latitude': myPosition.latitude.toString(),
        'longitude': myPosition.longitude.toString(),
      };
      DatabaseReference rideRef =
          FirebaseDatabase.instance.reference().child('rideRequest/${trip_id}');

      rideRef.child('driver_location').set(locationMap);
    });
  }

  void endTrip() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destinationLntLng = LatLng(pickup.longitude, pickup.latitude);

    var currentLatLng = LatLng(myPosition.latitude, myPosition.longitude);
    var directionDetails = await HelperMethods.getDirectionDetails(
        destinationLntLng, currentLatLng);
    int fares = HelperMethods.estimatedFares(directionDetails);
    DatabaseReference rideRef =
        FirebaseDatabase.instance.reference().child('rideRequest/${trip_id}');
    rideRef.child('fares').set(fares.toString());
    ridePositionStream.cancel();
  }

  void getLocationUpdates() {
    ridePositionStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 4,
            forceAndroidLocationManager: true)
        .listen((event) {
      myPosition = position;
      currentPosition = position;
      LatLng pos = LatLng(position.latitude, position.longitude);
      Marker movingMarker = Marker(
          markerId: MarkerId("moving"),
          position: pos,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: 'Current Location'));

      setState(() {
        CameraPosition cp = new CameraPosition(target: pos, zoom: 17);
        _controller.animateCamera(CameraUpdate.newCameraPosition(cp));
        _Markers.retainWhere((marker) => marker.markerId.value == "moving");
        _Markers.add(movingMarker);
      });

      oldPosition = pos;

      updateTripDetails();

      Map locationMap = {
        'latitude': myPosition.latitude.toString(),
        'longitude': myPosition.longitude.toString(),
      };
      DatabaseReference rideRef =
          FirebaseDatabase.instance.reference().child('rideRequest/${trip_id}');

      rideRef.child('driver_location').set(locationMap);
    });
  }

  Future<void> updateTripDetails() async {
    if (myPosition == null) {
      return;
    }

    var positionLatLng = LatLng(myPosition.latitude, myPosition.longitude);

    LatLng destinationLntLng;

    if (rideStatus == 2) {
      var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
      destinationLntLng = LatLng(pickup.longitude, pickup.latitude);
    } else {
      destinationLntLng = LatLng(
          tripList[0].destination_latitude, tripList[0].destination_longitude);
    }

    var directionDetails = await HelperMethods.getDirectionDetails(
        positionLatLng, destinationLntLng);
    if (directionDetails == null) {
      setState(() {
        durationString = directionDetails.durationText;
      });
    }
  }

  void declinePressed() {
    User user = FirebaseAuth.instance.currentUser;
    DatabaseReference teRef = FirebaseDatabase.instance
        .reference()
        .child('rideRequest/${trip_id}/status');
    teRef.set(2);
    DatabaseReference teReft = FirebaseDatabase.instance
        .reference()
        .child('rideRequest/${trip_id}/request_to_status');
    teReft.set(2);
    DatabaseReference teRefti = FirebaseDatabase.instance
        .reference()
        .child('rideRequest/${trip_id}/request_to');
    teRefti.set("");
    DatabaseReference teReftix = FirebaseDatabase.instance
        .reference()
        .child('rideRequest/${trip_id}/driver_id');
    teReftix.set("");
    rideReference =
        FirebaseDatabase.instance.reference().child('users/${user.uid}/newReq');
    rideReference.remove();
    DatabaseReference teRefs =
        FirebaseDatabase.instance.reference().child('users/${user.uid}');
    teRefs.child("newReq").set("");
    teRefs.child("newTrip").set("");
    setState(() {
      rideStatus = 0;
      _polylines.clear();
      _Markers.clear();
      polylineCoordinates.clear();
    });
    if (onlineStatus == true) {
      var _duration = Duration(seconds: 5);
      Timer(_duration, rideRequest);
      setState(() {});
    }
  }

  void arrivedPress() {
   

    DatabaseReference tripHistory = FirebaseDatabase.instance
        .reference()
        .child('tripHistory/${trip_id}/status');
    tripHistory.set(9);
    DatabaseReference teRef = FirebaseDatabase.instance
        .reference()
        .child('rideRequest/${trip_id}/status');
    teRef.set(9);
    //  HelperMethods.disableHomeTabLocationUpdates();
    setState(() {
      rideStatus = 3;
    
    });
  }

  void startRidePress() {
    //  HelperMethods.enableHomeTabLocationUpdates();

    DatabaseReference teRef = FirebaseDatabase.instance
        .reference()
        .child('rideRequest/${trip_id}/status');
    teRef.set(3);
    DatabaseReference tripHistory = FirebaseDatabase.instance
        .reference()
        .child('tripHistory/${trip_id}/status');
    tripHistory.set(3);
    getDirectiontoDes();
    setState(() {
      rideStatus = 4;
    });
  }

  void rideCompletPress() {
    //  Ringtone.play();
    DatabaseReference teRef = FirebaseDatabase.instance
        .reference()
        .child('rideRequest/${trip_id}/status');
    teRef.set(4);
    DatabaseReference complaint =
        FirebaseDatabase.instance.reference().child('rideRequest/${trip_id}');
    complaint.child('complaintByDriver').set(0);
    complaint.child('complaintByCustomer').set(0);

    setState(() {
      rideStatus = 5;
    });
    // AppRoutes.push(context, DriverBillCalculationClass());
  }

  void collectCash() async {
    DatabaseReference feedbackReference =
        FirebaseDatabase.instance.reference().child('rideRequest/$trip_id');
    feedbackReference.child("additional").set(additional);
    feedbackReference.child("discount").set('');
    feedbackReference.child("time").set(tripDirectionDetails.durationText);
    feedbackReference.child("total").set(total);

    feedbackReference.child("distance").set(tripDirectionDetails.distanceText);
    feedbackReference.child("ride_end").set(DateTime.now().toString());
    feedbackReference.child('complaintByDriver').set(0);
    feedbackReference.child('complaintByCustomer').set(0);
    DatabaseReference updateRefo = FirebaseDatabase.instance
        .reference()
        .child('users/${currentUserInfo.id}');

    updateRefo.child("total_EstimatedFare").set(total);
    updateRefo.child("distance").set(tripDirectionDetails.distanceText);

    DatabaseReference teRef = FirebaseDatabase.instance
        .reference()
        .child('rideRequest/${trip_id}/status');
    teRef.set(5);
    DatabaseReference teRefs =
        FirebaseDatabase.instance.reference().child('users/${user.uid}');
    teRefs.child("newReq").remove();
    teRefs.child("newtrip").remove();

    // await endTrip();
    polylineCoordinates.clear();
    _polylines.clear();
    _Markers.clear();
    setState(() {
      rideStatus = 0;
    });
    AppRoutes.push(context, DriverBillCalculationClass(trip_id));
  }

  void checkResume() {}

  void checkRequest() {
    try {
      listnerMessage();
      rideReference.onValue.listen((event) {
        print('Triggered Listener on -- CHANGED -- friend info');
        print(
            'info that changed: ${event.snapshot.key}:${event.snapshot.value}');
        if (event.snapshot != null) {
          trip_id = event.snapshot.value;
          if (trip_id == "") {
            setState(() {
              rideStatus = 0;
            });
          } else {
            tripReference = FirebaseDatabase.instance
                .reference()
                .child('rideRequest/${trip_id}');
            tripReference.once().then((DataSnapshot dataSnapshot) async {
              if (dataSnapshot.value != null) {
                print(dataSnapshot.value.toString());

                print(
                    '${dataSnapshot.value["destination"]["longitude"]}, ${dataSnapshot.value["destination"]["latitude"]}');
                DatabaseReference tripRef = FirebaseDatabase.instance
                    .reference()
                    .child('rideRequest/${trip_id}/request_to_status');
                tripRef.once().then((DataSnapshot b) async {
                  var trip = Trip(
                      tripID: trip_id,
                      destination_address:
                          dataSnapshot.value["destination_address"],
                      destination_latitude: dataSnapshot.value["destination"]
                          ["latitude"],
                      destination_longitude: dataSnapshot.value["destination"]
                          ["longitude"],
                      driver_id: dataSnapshot.value["driver_id"],
                      pickup_address: dataSnapshot.value["pickup_address"],
                      pickup_latitude: dataSnapshot.value["location"]
                          ["latitude"],
                      pickup_longitude: dataSnapshot.value["location"]
                          ["longitude"],
                      payment_method: dataSnapshot.value["payment_method"],
                      request_to: dataSnapshot.value["request_to"],
                      request_to_status:
                          dataSnapshot.value["request_to_status"],
                      rider_id: dataSnapshot.value["rider_id"],
                      rider_name: dataSnapshot.value["rider_name"],
                      rider_phone: dataSnapshot.value["rider_phone"],
                      status: dataSnapshot.value["status"],
                      tag: dataSnapshot.value["tag"]);
                  setState(() {
                    tripList.clear();
                    custom_rider = dataSnapshot.value["rider_name"];
                    custom_rider_id = dataSnapshot.value["rider_id"];
                    custom_trip_id = trip_id;
                  });

                  DatabaseReference updat = FirebaseDatabase.instance
                      .reference()
                      .child('users/${custom_rider_id}');
                  updat.once().then((DataSnapshot event) async {
                    setState(() {
                      driver_img = event.value["displayImage"];
                      driver_feed = event.value["feedback"];
                    });
                  });
                  tripList.add(trip);
                  print(tripList.length);

                  if (b.value == 0) {
                    await getDirectiontoCustomer();
                    getLocationUpdates();
                    setState(() {
                      istripRef = true;
                      rideStatus = 1;
                    });

                    DatabaseReference updat = FirebaseDatabase.instance
                        .reference()
                        .child('users/${custom_rider_id}');
                    updat.once().then((DataSnapshot event) async {
                      setState(() {
                        driver_img = event.value["displayImage"];
                        driver_feed = event.value["feedback"];
                      });
                    });
                  }

                  //retore resume state:
                  // if //status
                  //1 = accepted
                  //0 = pending
                  //2 = cancel
                  //9 = arrived
                  //3 = on the way
                  //4 = complated
                  //5 = calculate fare

                  if (b.value == 1) {
                    DatabaseReference teRefer = FirebaseDatabase.instance
                        .reference()
                        .child('rideRequest/${trip_id}/request_to_status');
                    teRefer.set(1);
                    acceptPressed();
                  } else if (b.value == 2) {
                    declinePressed();
                  } else if (b.value == 3) {
                    startRidePress();
                  } else if (b.value == 4) {
                    rideCompletPress();
                  } else if (b.value == 5) {
                    collectCash();
                  } else if (b.value == 9) {
                    arrivedPress();
                  }
                });
              }
            });
          }
        } else {
          print('no req');
          setState(() {
            rideStatus = 0;
          });
        }
      });
    } catch (e) {}
  }

  Future<void> getDirectiontoCustomer() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination = tripList[0].pickup_address;

    var pickupLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destinationLatLng =
        LatLng(tripList[0].pickup_latitude, tripList[0].pickup_longitude);

    var thisDetails = await HelperMethods.getDirectionDetails(
        pickupLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetails = thisDetails;
      rideStatus = 2;
    });

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails.encodedPoints);

    polylineCoordinates.clear();

    if (results.isNotEmpty) {
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _polylines.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Colors.black54,
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      _polylines.add(polyline);
    });
    LatLngBounds bounds;
    if (pickupLatLng.latitude > destinationLatLng.latitude &&
        pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);
    } else if (pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
          northeast:
              LatLng(destinationLatLng.latitude, pickupLatLng.longitude));
    } else if (pickupLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickupLatLng.longitude),
          northeast:
              LatLng(pickupLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickupLatLng, northeast: destinationLatLng);
    }

    _controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickupLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow:
          InfoWindow(title: pickup.placeName, snippet: 'Driver location'),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(
          title: tripList[0].pickup_address, snippet: 'Rider Pickup location'),
    );

    setState(() {
      _Markers.add(pickupMarker);
      _Markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
        circleId: CircleId('Current Location'),
        strokeColor: Colors.black45,
        strokeWidth: 3,
        center: pickupLatLng,
        fillColor: Colors.black38);

    Circle destinationCircle = Circle(
        circleId: CircleId('Customer Pickup'),
        strokeColor: Colors.black45,
        strokeWidth: 3,
        center: destinationLatLng,
        fillColor: Colors.black38);

    setState(() {
      _Circle.add(pickupCircle);
      _Circle.add(destinationCircle);
    });
  }

  Future<void> getDirection() async {
    var pickup = tripList[0].pickup_address;
    var destination = tripList[0].destination_address;

    var pickupLatLng =
        LatLng(tripList[0].pickup_latitude, tripList[0].pickup_longitude);
    var destinationLatLng = LatLng(
        tripList[0].destination_latitude, tripList[0].destination_longitude);

    var thisDetails = await HelperMethods.getDirectionDetails(
        pickupLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetails = thisDetails;
      rideStatus = 1;
    });

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails.encodedPoints);

    polylineCoordinates.clear();

    if (results.isNotEmpty) {
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _polylines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Colors.black54,
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      _polylines.add(polyline);
    });
    LatLngBounds bounds;
    if (pickupLatLng.latitude > destinationLatLng.latitude &&
        pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);
    } else if (pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
          northeast:
              LatLng(destinationLatLng.latitude, pickupLatLng.longitude));
    } else if (pickupLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickupLatLng.longitude),
          northeast:
              LatLng(pickupLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickupLatLng, northeast: destinationLatLng);
    }

    _controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickupLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(
          title: tripList[0].pickup_address, snippet: 'Rider Pickup location'),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(
          title: tripList[0].pickup_address, snippet: 'Rider Destination'),
    );

    setState(() {
      _Markers.add(pickupMarker);
      _Markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
        circleId: CircleId('pickup'),
        strokeColor: Colors.black45,
        strokeWidth: 3,
        center: pickupLatLng,
        fillColor: Colors.black38);

    Circle destinationCircle = Circle(
        circleId: CircleId('destination'),
        strokeColor: Colors.black45,
        strokeWidth: 3,
        center: destinationLatLng,
        fillColor: Colors.black38);

    setState(() {
      _Circle.add(pickupCircle);
      _Circle.add(destinationCircle);
    });
  }

  Future<void> getDirectiontoDes() async {
    var pickup = tripList[0].pickup_address;
    var destination = tripList[0].destination_address;

    var pickupLatLng =
        LatLng(tripList[0].pickup_latitude, tripList[0].pickup_longitude);
    var destinationLatLng = LatLng(
        tripList[0].destination_latitude, tripList[0].destination_longitude);

    var thisDetails = await HelperMethods.getDirectionDetails(
        pickupLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetails = thisDetails;
    });

    int fares = HelperMethods.estimatedFares(thisDetails);
    DatabaseReference rideRef =
        FirebaseDatabase.instance.reference().child('rideRequest/${trip_id}');
    rideRef.child('fares').set(fares.toString());
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails.encodedPoints);

    polylineCoordinates.clear();

    if (results.isNotEmpty) {
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _polylines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Colors.black54,
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      _polylines.add(polyline);
    });
    LatLngBounds bounds;
    if (pickupLatLng.latitude > destinationLatLng.latitude &&
        pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);
    } else if (pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
          northeast:
              LatLng(destinationLatLng.latitude, pickupLatLng.longitude));
    } else if (pickupLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickupLatLng.longitude),
          northeast:
              LatLng(pickupLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickupLatLng, northeast: destinationLatLng);
    }
    setState(() {
      _controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
    });

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickupLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(
          title: tripList[0].pickup_address, snippet: 'Rider Pickup location'),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(
          title: tripList[0].destination_address, snippet: 'Rider Destination'),
    );

    setState(() {
      _Markers.add(pickupMarker);
      _Markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
        circleId: CircleId('pickup'),
        strokeColor: Colors.black45,
        strokeWidth: 3,
        center: pickupLatLng,
        fillColor: Colors.black38);

    Circle destinationCircle = Circle(
        circleId: CircleId('destination'),
        strokeColor: Colors.black45,
        strokeWidth: 3,
        center: destinationLatLng,
        fillColor: Colors.black38);

    setState(() {
      _Circle.add(pickupCircle);
      _Circle.add(destinationCircle);
    });
  }
}
