
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'dart:async';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:permission_handler/permission_handler.dart';
import 'loging.dart';
import 'package:flutter_app/utilities/location.dart' as LocationManager;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/driver_ui/driver_home.dart';
import 'package:flutter_app/customer_ui/cust_home.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_app/core/helper/helperMethod.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Map currentPosition;
  startTime() async {
    var _duration = Duration(seconds: 3);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
    print('Splash time out');
     User user = FirebaseAuth.instance.currentUser;
     if(user!=null){
       try{
          DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users/${user.uid}');
      databaseReference.once().then((DataSnapshot dataSnapshot) async {
          if(dataSnapshot.value!=null){
            print(dataSnapshot.value.toString());
            constant_phone = dataSnapshot.value['phone'];
            constant_role =  dataSnapshot.value['role'];
            constant_uid = dataSnapshot.value['uid'];
            login=true;
              await  HelperMethods.getCurrentUSerInfo();
               DatabaseReference teRef = FirebaseDatabase.instance.reference().child('users/${user.uid}');
              
              
              teRef.child('position').set(currentPosition); 
            if(constant_role==0){
                   AppRoutes.makeFirst(context, CustomerHomeClass());
              }else if(constant_role==1){
                
                AppRoutes.makeFirst(context, DriverHomeClass());
              }
          }else{
              AppRoutes.replace(context, LogingClass());
          }
      });
       }catch(e){
          AppRoutes.replace(context, LogingClass());
       }
     }else{
         AppRoutes.replace(context, LogingClass());
     }
   
   // AppRoutes.replace(context, CustomerHomeClass());
  }

  @override
  void initState() {
    super.initState();
    locationPermission();

  }

  @override
  Widget build(BuildContext context) {
//FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    return Scaffold(
      backgroundColor: black,
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.width*.4,
          width: MediaQuery.of(context).size.width*.4,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/splashlogo.png'),
                  fit: BoxFit.fill
              )
          ),


        ),
      ),
    );
  }


  Future<void> locationPermission() async {
    var status = await Permission.location.status;
    if(status.isGranted){
      startTime();
       await getUserLocation();
        print('Granted');
      }else{
        var status = await Permission.location.request();
        status.isGranted?locationPermission():locationPermission();
        print('requested');
        // startTime();
}


  }


  void getUserLocation() async {
    var currentLocation = <String, double>{};
    final location = LocationManager.Location();
    try {
      currentLocation = await location.getLocation();
     
      final lat = currentLocation["latitude"];
      final lng = currentLocation["longitude"];
   //   Position  position = await Geolocator.getLastKnownPosition();
   //   String address = await HelperMethods.findCordinateAddress(position,context);
      print('Your Latitude is: $lat, Longitude is: $lng ');

      currentPosition = {
        'lat':lat,
        'lng':lng
      };
      //await _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target:LatLng(lat, lng),zoom: 15,))) ;

    } on Exception {
      currentLocation = null;
      return null;
    }
  }


}



