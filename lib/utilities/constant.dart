import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/dbmodels/fare.dart';
import 'package:flutter_app/core/dbmodels/user.dart';
import 'package:flutter_app/core/dbmodels/estimatedFare.dart';
import 'package:flutter_app/core/dbmodels/driver.dart';
import 'package:flutter_app/core/dbmodels/trip.dart';

import 'package:flutter_app/core/model/directionDetails.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/customer_ui/cust_complaint.dart';
import 'package:flutter_app/utilities/customer_buttons.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_app/utilities/constant.dart';

import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'dart:async'; // Import package

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

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_app/utilities/brandDivider.dart';
import 'package:flutter_app/core/dataprovider/appData.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

String image;
String date, time;
var timestamp;
String custom_rider, custom_rider_id, custom_trip_id;
String constant_phone;
String constant_name;
String constant_email;
var constant_role;
String constant_uid;
bool constant_login = false;
bool login = false;
var destinationController = TextEditingController();
Users currentUserInfo;
Fare fareSetting;
int locationSet = 0;
int setLocation = 0;
var apiKey = 'AIzaSyAUqoje9DfiCojdYrICiT0643jh7N6stLc';

    var estimated_time ;
      var total;
      var additional;


StreamSubscription<Position> homeTabPositionStream;

StreamSubscription<Position> ridePositionStream;
Drivers currentDriverInfo;

//all drivers

List<Drivers> allDrivers = List<Drivers>();

List<EstimatedFare> estimatedFare = List<EstimatedFare>();

DirectionDetails tripDirectionDetails;
bool msg;

// trip
//
List<Trip> tripHistory = List<Trip>();
List<Trip> tripList = List<Trip>();

var total_km;
var totol_ride;
var total_earn;

// driver
String driver_img;

Set<Marker> markers = new Set<Marker>();
Set<Marker> Mmarkers = {};
Set<Circle> circle = {};
LatLng currentlocation;
Position position;
List<LatLng> polylineCoordinates = [];
Set<Polyline> polylines = {};

// map veriables and controller
GoogleMapController controller;
