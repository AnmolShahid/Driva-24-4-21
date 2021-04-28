import 'dart:math';

import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/core/dbmodels/fare.dart';
import 'package:flutter_app/core/helper/requesthelper.dart';
import 'package:flutter_app/core/model/address.dart';
import 'package:flutter_app/core/model/directionDetails.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_app/core/dataprovider/appData.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_app/core/dbmodels/user.dart';
import 'package:flutter_app/core/dbmodels/estimatedFare.dart';

class HelperMethods extends GetxController {
  static void getCurrentUSerInfo() async {
    User user = FirebaseAuth.instance.currentUser;
    String userid = user.uid;
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference().child('users/$userid');
    databaseReference.once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        currentUserInfo = Users.fromSnapshot(dataSnapshot);
        image = currentUserInfo.displayImage;
        print('my name is ${currentUserInfo.username}');
      } else {
        return false;
      }
    });
  }

  static Future<String> findCordinateAddress(Position position, context) async {
    String placeAddress = '';

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return placeAddress;
    }

    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyAUqoje9DfiCojdYrICiT0643jh7N6stLc';

    var response = await RequestHelper.getRequest(url);
    if (response != 'failed') {
      placeAddress = response['results'][0]['formatted_address'];

      Address pickupAddress = new Address();
      pickupAddress.latitude = position.latitude;
      pickupAddress.longitude = position.longitude;
      pickupAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickupAddress(pickupAddress);
    }
    return placeAddress;
  }

  static Future<DirectionDetails> getDirectionDetails(
      LatLng startPosition, LatLng endPosition) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=AIzaSyAUqoje9DfiCojdYrICiT0643jh7N6stLc';

    var response = await RequestHelper.getRequest(url);
    if (response == 'failed') {
      return null;
    }
    if (response["status"] == "ZERO_RESULTS") {
      url =
          'https://maps.googleapis.com/maps/api/directions/json?destination=${startPosition.latitude},${startPosition.longitude}&origin=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=AIzaSyAUqoje9DfiCojdYrICiT0643jh7N6stLc';
      response = await RequestHelper.getRequest(url);
    }

    DirectionDetails directionDetails = new DirectionDetails();
    directionDetails.durationText =
        response['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue =
        response['routes'][0]['legs'][0]['duration']['value'];
    directionDetails.distanceText =
        response['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue =
        response['routes'][0]['legs'][0]['distance']['value'];
    directionDetails.encodedPoints =
        response['routes'][0]['overview_polyline']['points'];

    return directionDetails;
  }

  static int estimatedFares(DirectionDetails details) {
    double totalFare;
    var timeFare;
    var distanceFare;
    var baseFare;

    try {
      /*
      DatabaseReference databaseReference =
          FirebaseDatabase.instance.reference().child('fareSettings');
      databaseReference.once().then((DataSnapshot dataSnapshot) {
        if (dataSnapshot.value != null) {
          //  fareSetting = Fare.fromSnapshot(dataSnapshot);
          //  print('my base fare is ${fareSetting.base_fare}');
          print(dataSnapshot.value["base_fare"]);
          baseFare = dataSnapshot.value["base_fare"];
          distanceFare = (details.distanceValue / 1000) *
              dataSnapshot.value["distance_fare"];
          timeFare =
              (details.distanceValue / 60) * dataSnapshot.value["time_fare"];

          totalFare = baseFare + distanceFare;
          //  print(totalFare.truncate());

          var extFare = EstimatedFare(
              base_EstimatedFare: baseFare,
              distance_EstimatedFare: distanceFare,
              time_EstimatedFare: timeFare,
              total_EstimatedFare: totalFare.truncate());
          estimatedFare.clear();
          estimatedFare.add(extFare);
          print(estimatedFare.length);
          print(totalFare);
          return totalFare.truncate();
        }
      });
      */

      // time per hour.
      String splitValue = details.durationText;
      var parts = splitValue.split(' ');
      var hours = int.tryParse(parts[0]);
      var mints = int.tryParse(parts[2]);

      estimated_time = hours;
      additional = 0;
      total = 39;
      if (estimated_time >= 1) {
        total = 39;
        additional = 1.15 * mints;
      }
      if (estimated_time == 1) {
        total = 59;
        additional = 1.00 * mints;
      }
      if (estimated_time == 2) {
        total = 89;
        additional = 0.8 * mints;
      }
      if (estimated_time == 4) {
        total = 158;
        additional = 0.7 * mints;
      }
      if (estimated_time == 6) {
        total = 195;
        additional = 0.7 * mints;
      }
      if (estimated_time == 8) {
        total = 224;
        additional = 0.7 * mints;
      }
      if (estimated_time == 10) {
        total = 297;
        additional = 0.7 * mints;
      }
      total = total + additional;
      // price
      // discount
      // additional charges
      baseFare = 1.5;
      distanceFare = (details.distanceValue / 1000) * 0.5;
      timeFare = (details.distanceValue / 60) * 0.01;

      totalFare = baseFare + distanceFare + timeFare;

      var extFare = EstimatedFare(
          base_EstimatedFare: baseFare,
          distance_EstimatedFare: distanceFare,
          time_EstimatedFare: timeFare,
          total_EstimatedFare: total);
      estimatedFare.clear();
      estimatedFare.add(extFare);
      print(estimatedFare.length);
      print(totalFare);
      return totalFare.truncate();
    } catch (e) {
      baseFare = 1.5;
      distanceFare = (details.distanceValue / 1000) * 0.5;
      timeFare = (details.distanceValue / 60) * 0.01;

      totalFare = baseFare + distanceFare + timeFare;
      return totalFare.truncate();
    }
  }

  static double generateRandomNumber(int max) {
    var randGenerator = Random();
    int randInt = randGenerator.nextInt(max);

    return randInt.toDouble();
  }

  static Future<void> disableHomeTabLocationUpdates() async {
    homeTabPositionStream.pause();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    Geofire.setLocation(
        currentUserInfo.id, position.latitude, position.longitude);
  }

  static void enableHomeTabLocationUpdates() {
    homeTabPositionStream.resume();
    Geofire.removeLocation(currentUserInfo.id);
  }
}
