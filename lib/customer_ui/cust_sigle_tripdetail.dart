import 'package:flutter/material.dart';
import 'package:flutter_app/customer_ui/cust_complaint.dart';
import 'package:flutter_app/utilities/customer_buttons.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'bar_drawer.dart';

import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'dart:async';// Import package

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_app/push_notification_service.dart';
import 'package:ringtone/ringtone.dart';
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


class CustomerSingleTripDetail extends StatefulWidget {
  @override
  _CustomerSingleTripDetailState createState() => _CustomerSingleTripDetailState();
}

class _CustomerSingleTripDetailState extends State<CustomerSingleTripDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
 Future<void> getDirection() async {
   
    var pickup = tripHistory[0].pickup_address;
    var destination = tripHistory[0].destination_address;
    
    var pickupLatLng = LatLng(tripHistory[0].pickup_latitude,tripHistory[0].pickup_longitude);
    var destinationLatLng = LatLng(tripHistory[0].destination_latitude,tripHistory[0].destination_longitude);

   
      var thisDetails = await HelperMethods.getDirectionDetails(pickupLatLng,destinationLatLng);
   // cost = await HelperMethods.estimatedFares(thisDetails);
   
  
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(thisDetails.encodedPoints);
    
    polylineCoordinates.clear();
    
    if(results.isNotEmpty){
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));

      });

    }
  polylines.clear();
  setState(() {
     Polyline polyline = Polyline(
      polylineId: PolylineId('polyid'),
      color:Colors.black,
      points: polylineCoordinates,
      jointType: JointType.round,
      width: 4,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
    );

    polylines.add(polyline);
  });
   LatLngBounds bounds;
   if(pickupLatLng.latitude > destinationLatLng.latitude && pickupLatLng.longitude > destinationLatLng.longitude){
     bounds = LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);
  }else if(pickupLatLng.longitude > destinationLatLng.longitude){
     bounds = LatLngBounds(
       southwest: LatLng(pickupLatLng.latitude,destinationLatLng.longitude), 
       northeast: LatLng(destinationLatLng.latitude,pickupLatLng.longitude)
       );
  }else if(pickupLatLng.latitude > destinationLatLng.latitude){
      bounds = LatLngBounds(
       southwest: LatLng(destinationLatLng.latitude,pickupLatLng.longitude), 
       northeast: LatLng(pickupLatLng.latitude,destinationLatLng.longitude)
       );
  }else{
    bounds = LatLngBounds(southwest: pickupLatLng, northeast:destinationLatLng );
  }

  controller.animateCamera(CameraUpdate.newLatLngBounds(bounds,70));
  setState(() {
  
});
  Marker pickupMarker = Marker(
    markerId: MarkerId('pickup'),
    position: pickupLatLng,
     icon: await BitmapDescriptor.fromAssetImage(
                    ImageConfiguration(
                      devicePixelRatio: 2.5,
                    ),
                    'assets/pickup_ico.png',
                  ),
 //   infoWindow: InfoWindow(title: tripHistory[0].pickup_address,snippet: 'My Location'),
  );
  
  Marker destinationMarker = Marker(
    markerId: MarkerId('destination'),
    position: destinationLatLng,
     icon: await BitmapDescriptor.fromAssetImage(
                    ImageConfiguration(
                      devicePixelRatio: 2.5,
                    ),
                    'assets/dropoff_ico.png',
                  ),
 //   infoWindow: InfoWindow(title: destination.placeName,snippet: 'Destination'),
  );
  
  setState(() {
    Mmarkers.clear();
    Mmarkers.add(pickupMarker);
    Mmarkers.add(destinationMarker);

  });
  
  Circle pickupCircle = Circle(
    circleId: CircleId('pickup'),
    strokeColor: Colors.black45,
    strokeWidth: 3,
    center: pickupLatLng,
    fillColor: Colors.black38
  );

  Circle destinationCircle = Circle(
    circleId: CircleId('destination'),
    strokeColor: Colors.black45,
    strokeWidth: 3,
    center: destinationLatLng,
    fillColor: Colors.black38
  );
  
 setState(() {
    circle.add(pickupCircle);
  circle.add(destinationCircle);

 });

  }

 
  // Drop Down Item Value
  int _value = 1;

  var check = 0;

  double searchSheetHeight = (Platform.isIOS) ? 300:275 ;

 


  @override
  Widget build(BuildContext context) {
    getDirection();
    if(constant_role==0){
     check = tripHistory[0].complaintByCustomer;
     
    }else{
      check = tripHistory[0].complaintByDriver;
    }
    return Scaffold(
        key: _scaffoldKey,
        //drawer: CusDrawerPage(context),
    appBar: PreferredSize(
    preferredSize: Size.fromHeight(appBarHeight), // here the desired height
    child: CusAppBarClass( context, 'Trip Detail', false,_scaffoldKey) ),

      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              mapImage(),
              
              payDetail(),
              locationPoints(),
              check==0
              ?
              PrimaryButton(Heading: 'Complaint/Report',onTap: complaintPress,)
              :
              complaintDetail()
            ],
          ),
        ),
      ),

    );
    }


    Widget mapImage(){
 // getDirection();
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height*.25,

        child:GoogleMap(
      initialCameraPosition:CameraPosition(
          target: LatLng(tripHistory[0].pickup_latitude,tripHistory[0].pickup_longitude),
          zoom: 15.0
      ),
      polylines: polylines,

      myLocationEnabled: false,
      markers: Mmarkers,
      circles: circle,
      myLocationButtonEnabled: false,
      mapType: MapType.normal,
    //  onMapCreated: _onMapCreated,
    //  onCameraMove: _onCameraMove,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false
      
      
    )
    );
    }

  Widget complaintDetail(){
    return Container(
      margin: EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Complaint: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
              Text('Status: Pending', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
            ],
          ),
        ],
      ),
    );
    }


    Widget payDetail(){
    return Container(
      margin: EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date??'20/10/2020', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
              Text('QAR '+tripHistory[0].total_EstimatedFare??'QAR --', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                constant_role == 0
                ?
                tripHistory[0].driver_name??'Aftaab Ahmed'
                :
                tripHistory[0].rider_name??'Aftaab Ahmed'
                , style: TextStyle(color: lightGray,fontSize: 16, fontWeight: FontWeight.w500),),
              Text('Cash', style: TextStyle(color: lightGray, fontSize: 16, fontWeight: FontWeight.w500),),
            ],
          )
        ],
      ),
    );
    }

    Widget locationPoints(){
    return Container(
      alignment: Alignment.topLeft,
      margin: EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        
        children: [
        Container(
          // color: Colors.yellow,
           width: MediaQuery.of(context).size.width,
           child:  Text(
            'From:\n '+tripHistory[0].pickup_address??
            'From:\n Shop 56 Al Arab Center Street no 4, sector 94, Sharjah Dubai',
            
             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: DarkGray),),
        ),
         Container(
          // color: Colors.yellow,
           width: MediaQuery.of(context).size.width,
           child:  Text(
            
            '\n\nTo:\n ' + tripHistory[0].destination_address??
            '\n\nTo:\n Shop 56 Al Arab Center Street no 4, sector 94, Sharjah Dubai',
            textAlign: TextAlign.start,
             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: DarkGray),),
),
          Container(
            margin: EdgeInsets.only(top: 15, bottom: 15),
            padding: EdgeInsets.only(top: 15, bottom: 15),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(width: 1, color: lightGray), bottom: BorderSide(width: 1, color: lightGray))
            ),
            child: Row(
              children: [
                                   CachedNetworkImage(
  imageUrl:  driver_img,
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
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
),
               

             /*   Container(
                  margin: EdgeInsets.only(right: 10),
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    image: DecorationImage(
                      image: AssetImage('assets/man.jpeg')
                    )
                  ),
                ),
             */   Expanded(child: Text(
                constant_role == 0
                ?
                 tripHistory[0].driver_name??'Aftaab Ahmed'
                :
                 tripHistory[0].rider_name??'Aftaab Ahmed'
                , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: DarkGray),),),
                SizedBox(width: 10,),
                Row(
                  children: [
                    Text( 
                      constant_role == 0
                ?
                'You Rated '+ (tripHistory[0].feedback_to_driver).toString()??'0.0'
                :
                'You Rated '+ (tripHistory[0].feedback_to_customer).toString()??'0.0',
                      style: TextStyle(color: Colors.yellow),
                      ),
                    Icon(Icons.star, size: 15,color: Colors.yellow,),
                    
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
    }



void complaintPress(){
    AppRoutes.replace(context, CustomerComplaintClass());
}


}
