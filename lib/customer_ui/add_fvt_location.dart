
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/core/model/address.dart';
import 'package:search_map_place/search_map_place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'package:flutter_app/utilities/constant.dart';
import 'package:flutter_app/core/dataprovider/appData.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/helper/helperMethod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_app/utilities/location.dart' as LocationManager;
import 'package:flutter/services.dart' show rootBundle;

const String apiKEY = "AIzaSyAUqoje9DfiCojdYrICiT0643jh7N6stLc&sessiontoken=1234567890";


class AddFvtLocation extends StatefulWidget {

   final int variable;//if you have multiple values add here
AddFvtLocation(this.variable, {Key key}): super(key: key);//add also..example this.abc,this...



  @override
  State<AddFvtLocation> createState() => MapSampleState();
}

class MapSampleState extends State<AddFvtLocation> with SingleTickerProviderStateMixin {
  Completer<GoogleMapController> _mapController = Completer();

  String _mapStyle;
  List<LatLng> _polylinePoints = [];
  Set<Marker> _markers = {};

  AnimationController _ac;
  Animation<Offset> _animation;
   double latt =31.476101;
 // static var latt =32.1009479;
   double longg = 74.280672;
 // static var longg = 74.190527;
  Place _selectedPlace;
  Position position;
  final CameraPosition _initialCamera = CameraPosition(
    target: LatLng(31.476101, 74.280672),
    zoom: 14.0000,
  );

  GoogleMapController _controller ;
  Map<String, double> currentLocation;

  TextEditingController textController = TextEditingController();
 void getUserLocation() async {
   
     currentLocation = <String, double>{};
   
    try {
      final location = LocationManager.Location();
      currentLocation = await location.getLocation();
      position = position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
   
      final lat = currentLocation["latitude"];
      final lng = currentLocation["longitude"];
     setState(() {
       latt = lat;
       longg = lng;
     
      
     });
       
      print('Your Latitude is: $latt, Longitude is: $longg');
     // await _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target:LatLng(lat, lng),zoom: 15,)));
     
      String address = await HelperMethods.findCordinateAddress(position,context);


    } on Exception {
      currentLocation = null;
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
textController.text = 'Current Location';
    // Loads MapStyle file
/*    rootBundle.loadString('assets/maps_style.txt').then((string) {
      _mapStyle = string;
    });
*/
    _ac = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 750),
    );
    _animation = Tween<Offset>(
      begin: Offset(-1.0, 2.75),
      end: Offset(0.05, 2.75),
    ).animate(CurvedAnimation(
      curve: Curves.easeOut,
      parent: _ac,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //  resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          // Map widget
          GoogleMap(
            initialCameraPosition: _initialCamera,
            markers: _markers,
          
            myLocationEnabled: true,

            // Adds Path from user to selected location
            polylines: Set()
              ..add(
                Polyline(
                  polylineId: PolylineId('path'),
                  points: _polylinePoints,
                  color: Colors.teal[200].withOpacity(0.8),
                  endCap: Cap.roundCap,
                  geodesic: true,
                  jointType: JointType.round,
                  startCap: Cap.squareCap,
                  width: 5,
                ),
              ),
            onMapCreated: (GoogleMapController controller) async {
              _mapController.complete(controller);

              // Changes the Map Style
              controller.setMapStyle(_mapStyle);

              // Creates Marker on current user location, using a current icon.
              final userLocation = Marker(
                markerId: MarkerId('user-location'),
                icon: await BitmapDescriptor.fromAssetImage(
                  ImageConfiguration(
                    devicePixelRatio: 2.5,
                  ),
                  'assets/pickicon.png',
                ),
                position: _initialCamera.target,
              );

              setState(() => _markers.add(userLocation));
            },
          ),

          // SearchMapPlace widget
          Positioned(
            top: 60,
            left: MediaQuery.of(context).size.width * 0.05,
            child: SearchMapPlaceWidget(
              apiKey: apiKEY,
              icon: Icons.search,
              clearIcon: Icons.clear,
              iconColor: Colors.teal[200].withOpacity(0.8),
              placeType: PlaceType.establishment,
              location: _initialCamera.target,
              placeholder: widget.variable==0?'Search Home Location':'Search Location',
              radius: 30000,
              onSelected: (place) async {
                final geolocation = await place.geolocation;
                  

                 Address  thisPlace = Address();
                    thisPlace.placeName = place.description;
                    thisPlace.placeId= place.placeId;
                    thisPlace.placeFormattedAddress = place.description;
                    thisPlace.latitude = geolocation.coordinates.latitude;
                    thisPlace.longitude = geolocation.coordinates.longitude;
                    print(place.fullJSON);
                    
                    
          DatabaseReference updateRefo = FirebaseDatabase.instance.reference().child('users/${currentUserInfo.id}/place/${widget.variable}');
           Map locationMap = {
              'placeID':thisPlace.placeId,
              'placeName':thisPlace.placeName,
              'lat':thisPlace.latitude,
              'lng':thisPlace.longitude,
              
              
            };
              updateRefo.set(locationMap);
              DatabaseReference updateRefow = FirebaseDatabase.instance.reference().child('users/${currentUserInfo.id}/tag');
              updateRefow.set(1);
             
                       Navigator.pop(context);



                    
              },
            ),
          ),

          // Box that will be animated in to the screen when user selects place.
            SlideTransition(
      position: _animation,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        height: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black12,
              spreadRadius: 15.0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              (_selectedPlace != null)
                  ? (_selectedPlace.description.length < 25
                      ? "${_selectedPlace.description}"
                      : "${_selectedPlace.description.replaceRange(25, _selectedPlace.description.length, "")} ...")
                  : "",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26.0,
              ),
            ),
            SizedBox(height: 5),
           
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    Address  thisPlace = Address();
                    thisPlace.placeName = _selectedPlace.description;
                    thisPlace.placeId= _selectedPlace.placeId;
                    thisPlace.placeFormattedAddress = _selectedPlace.description;
                    print(_selectedPlace.fullJSON);
                   // thisPlace.latitude = _selectedPlace.;
                  //  Provider.of<AppData>(context,listen: false).updatePickupAddress(thisPlace);
                 //  Navigator.pop(context, 'getDirection');

                  Provider.of<AppData>(context,listen: false).updateDestinationAddress(thisPlace);
                       Navigator.pop(context, 'getDirection');
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Text(
                    "Done",
                    style: TextStyle(fontSize: 16),
                  ),
                  color: Colors.teal[200].withOpacity(0.8),
                ),
              ],
            ),
          ],
        ),
      ),
    )
 
        ],
      ),
    );
  }

  Widget confirmationBox() {
    return 
    SlideTransition(
      position: _animation,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        height: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black12,
              spreadRadius: 15.0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              (_selectedPlace != null)
                  ? (_selectedPlace.description.length < 25
                      ? "${_selectedPlace.description}"
                      : "${_selectedPlace.description.replaceRange(25, _selectedPlace.description.length, "")} ...")
                  : "",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26.0,
              ),
            ),
            SizedBox(height: 5),
           
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    Address  thisPlace = Address();
                    thisPlace.placeName = _selectedPlace.description;
                    thisPlace.placeId= _selectedPlace.placeId;
                    thisPlace.placeFormattedAddress = _selectedPlace.description;
                    print(_selectedPlace.fullJSON);
                   // thisPlace.latitude = _selectedPlace.;
                  //  Provider.of<AppData>(context,listen: false).updatePickupAddress(thisPlace);
                 //  Navigator.pop(context, 'getDirection');

                  Provider.of<AppData>(context,listen: false).updateDestinationAddress(thisPlace);
                       Navigator.pop(context, 'getDirection');
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Text(
                    "Done",
                    style: TextStyle(fontSize: 16),
                  ),
                  color: Colors.teal[200].withOpacity(0.8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}