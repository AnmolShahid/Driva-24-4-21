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

class CustomerHomeClass extends StatefulWidget {
  @override
  _CustomerHomeClassState createState() => _CustomerHomeClassState();

  
}

class _CustomerHomeClassState extends State<CustomerHomeClass> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<ExpandableBottomSheetState> key = new GlobalKey();
  bool onlineStatus = false;
      PushNotificationService p = PushNotificationService();
  bool gotLocation = false;
  Position position; 
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
 var currentLocation;
  double searchSheetHeight = (Platform.isIOS) ? 300:275 ;
// map veriables and controller
  GoogleMapController _controller ;
  String home,work,other;
   double latt =31.476101;
 // static var latt =32.1009479;
   double longg = 74.280672;
 // static var longg = 74.190527;
   LatLng currentlocation ;
  LatLng _lastMapPosition ;
  Set<Marker>markers =  new Set<Marker>();
  Set<Marker> _Markers = {};
  Set<Circle> _Circle = {};
  bool starter = true ;
Address pickupPlace = Address();
Address workpickupPlace = Address();
Address otherpickupPlace = Address();
  var mapBottomPadding = 0.0;
// firebase 
int rideStatus = 0;
  DatabaseReference rideReference;

// direction
 var cost;
String driver_token;

  bool nearbyDriverkeysLoaded = false;
double driver_lat;
double driver_lng;
 //
 BitmapDescriptor nearbyIcon;

  String trip_id;

  bool isLoading=true;

  var driver_feed;

void showSnackBar(String title){
  final snackBar = SnackBar(content: Text(title,textAlign: TextAlign.center,style: TextStyle(fontSize: 15),),);
  _scaffoldKey.currentState.showSnackBar(snackBar);
}
 void createMarker(){
   if(nearbyIcon == null){
     ImageConfiguration imageConfiguration = createLocalImageConfiguration(context,size:Size(1,1));
     BitmapDescriptor.fromAssetImage(imageConfiguration,'assets/d.png' ).then((icon) {
        nearbyIcon = icon;
     } );
   }

 }

  @override
  Widget build(BuildContext context) {
    createMarker();
    return  WillPopScope(child:
    
    Scaffold(
      resizeToAvoidBottomInset: true,
     // resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
      
      drawer: CusDrawerPage(context),
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight), // here the desired height
          child: CusAppBarClass( context, 'Add Route', true,_scaffoldKey) ),
      body: isLoading==true?Center(child: CircularProgressIndicator(),):Container(
        //height: MediaQuery.of(context).size.height,
        //width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
           mapWidget(),
           upperMapWidget(),
          ],
        ),
      ),
    )
  ,onWillPop: (){
      
      if(rideStatus!=0){
      setState(() {
        rideStatus=0;
        markers.clear();
        _polylines.clear();
        _Markers.clear();
        polylineCoordinates.clear();
      });
      }
  },);
  
  }


  Widget mapWidget(){
    return latt == null || longg == null
  ? Container()
  :  GoogleMap(
      padding: EdgeInsets.only(bottom:mapBottomPadding),
      initialCameraPosition:CameraPosition(
          target: currentlocation,
          zoom: 15.0
      ),
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

getLocations(){
  try{
    DatabaseReference updateRef = FirebaseDatabase.instance.reference().child('users/${currentUserInfo.id}/place/0');
           updateRef.once().then(( DataSnapshot event) async {
           setState(() {
               home = event.value["placeName"];
               pickupPlace.placeId = event.value["placeID"];
               pickupPlace.placeName = event.value["placeName"];
               pickupPlace.latitude = event.value["lat"];
               pickupPlace.longitude = event.value["lng"];
           });

           });
    DatabaseReference updateRef1 = FirebaseDatabase.instance.reference().child('users/${currentUserInfo.id}/place/1');
           updateRef1.once().then(( DataSnapshot event) async {
             setState(() {
               work = event.value["placeName"];
                workpickupPlace.placeId = event.value["placeID"];
               workpickupPlace.placeName = event.value["placeName"];
               workpickupPlace.latitude = event.value["lat"];
               workpickupPlace.longitude = event.value["lng"];
             });

           });     
    DatabaseReference updateRef2 = FirebaseDatabase.instance.reference().child('users/${currentUserInfo.id}/place/2');
           updateRef2.once().then(( DataSnapshot event) async {
            setState(() {
               other = event.value["placeName"];
                 otherpickupPlace.placeId = event.value["placeID"];
               otherpickupPlace.placeName = event.value["placeName"];
               otherpickupPlace.latitude = event.value["lat"];
               otherpickupPlace.longitude = event.value["lng"];
            });

           }); 

  }catch(e){

  } 
}

  Widget upperMapWidget(){
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
       rideStatus==1? searchBar():Container(),
        gotLocation?Container():CircularProgressIndicator(),
        bottomWidgetChanger
      ],
    );
  }





  Widget searchBar(){
    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
           GestureDetector(
             onTap: () async {
                var response = await  Navigator.push(context, MaterialPageRoute(
                  builder:(context)=>MapPagePickup()
                  ));
                  if (response == 'getDirection'&& Provider.of<AppData>(context,listen: false).destinationAddress !=null){
                    

                    await getDirection();
                   
                    
                  }
                 
             },child:
          searchField((Provider.of<AppData>(context).pickupAddress !=null)
          ? Provider.of<AppData>(context).pickupAddress.placeName
          :'Pick up location'),
           ),
          GestureDetector(
            onTap: () async {
             
               var response = await  Navigator.push(context, MaterialPageRoute(
                  builder:(context)=>MapPage()
                  ));
                  if (response == 'getDirection' ){
                    

                    await getDirection();
                   
                    
                  }
               
            },
            child: searchField((Provider.of<AppData>(context).destinationAddress !=null)
          ? Provider.of<AppData>(context).destinationAddress.placeName
          :'Drop off location'),
          )
        ],
      )
    );
  }


  Widget searchField(String hint, ){
    return Container(
      padding: EdgeInsets.only(left: 0, right: 5),
      margin: EdgeInsets.only(top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: whtColor,
          border: Border.all(width: 1, color: lightGray),
          borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.add_location, color: lightGray,),

          Expanded(
              child: TextFormField(
                enabled: false,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,

                  contentPadding: EdgeInsets.only(bottom: 0)
                ),
              )
          ),
          Icon(Icons.send,color: lightGray),
        ],
      ),
    );
  }


  Widget get bottomWidgetChanger{
    return   rideStatus==6?waiting():rideStatus==0? whereWantToGo():rideStatus==1?rideStatusSelect(): rideStatus==2||rideStatus==9||rideStatus==4||rideStatus==3?driverOnTheWay() : Text('Ride status $rideStatus ');
  }

  Widget waiting(){
     return Container(
      width: MediaQuery.of(context).size.width,
      height: 200,
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: whtColor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
        boxShadow:[ 
          BoxShadow(
            color: Colors.black26,
            blurRadius:15.0,
            spreadRadius: 0.5,
            offset: Offset(
                0.7,
                0.7,
            )
          )
        ]
      ),
      margin: EdgeInsets.only(bottom: 0),
      child:Padding(padding:EdgeInsets.symmetric(horizontal: 24,vertical: 18 ) ,
      child:   Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 5,),
          
          Text('Requesting...', style: TextStyle(fontSize: 20, backgroundColor: whtColor, fontWeight: FontWeight.bold),),
          SizedBox(height: 20,),
          GestureDetector(
            onTap:()async{
              cancelRideRequest();
                setState(() {
                  rideStatus = 0;
                  
                });
            if(rideStatus==0){
               await getDirection();
            }

             
            },
            child: Container(
              alignment: Alignment.center,
              width: 100,
              height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5.0,
                  spreadRadius: 0.5,
                  offset: Offset(
                    0.7,
                    0.7,
                  ) )
              ]),
            child: Icon(Icons.cancel_rounded)
          ),
         
          ),
          
          ],
      ),
   )
      );
  

  }

 // void expand() => key.currentState.expand();
  Widget whereWantToGo(){
    return Container(
        child:ExpandableBottomSheet(
         
  background: Container(
   
    child: Center(
      child: Text(''),
    ),
  ),
  persistentHeader: Container(
    height:100,
    padding: EdgeInsets.all(10),
    alignment: Alignment.topLeft,
    color: Colors.white,
    child:GestureDetector(
            onTap:()async{
                // setState(() {
                //   rideStatus = 1;
                // });
                showSnackBar('Processing');
              var response = await  Navigator.push(context, MaterialPageRoute(
                  builder:(context)=>MapPage()
                  ));
                  if (response == 'getDirection'){
                    await getDirection();
                      setState(() {
                   rideStatus = 1;
                 });
                  }
            },
            child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
      children: [
           SizedBox(height: 5,),
          Text('Nice to see you!', style: TextStyle(fontSize: 10,),),
          SizedBox(height: 5,),
         Container(
           child: Text('Where are you going?', style: TextStyle(fontSize: 20,  fontWeight: FontWeight.bold),),
            padding: EdgeInsets.all(10),
            color: Colors.grey[100],
            width: MediaQuery.of(context).size.width,
         ), 
          SizedBox(height: 10,),
          
    ],))
    
  ),
  expandableContent:  Container(
      width: MediaQuery.of(context).size.width,
      height: 300,
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: whtColor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
        boxShadow:[ 
          BoxShadow(
            color: Colors.black26,
            blurRadius:15.0,
            spreadRadius: 0.5,
            offset: Offset(
                0.7,
                0.7,
            )
          )
        ]
      ),
      margin: EdgeInsets.only(bottom: 0),
      child:Padding(padding:EdgeInsets.symmetric(horizontal: 24,vertical: 18 ) ,
      child:   Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5,),
        GestureDetector(
          child: 
         Row(
            children: [
              Icon(Icons.home_outlined,color: Colors.black54,),
              SizedBox(width: 12,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(home==null?'Add Home':home),
                  SizedBox(height: 3,),
                  Text('Your residential address',
                    style:TextStyle(fontSize: 11,color:Colors.black38))
                ],)
            ],),
            
            onTap: () async {
              showSnackBar('Processing');
              if(home==null){
                var response = await  Navigator.push(context, MaterialPageRoute(
                  builder:(context)=>AddFvtLocation(0)
                  ));
                   getLocations();
                   setState(() {
                     
                    });
                  if (response == 'set pickup'&& Provider.of<AppData>(context,listen:false).destinationAddress !=null){
                    setState(() {
                      rideStatus = 1;
                    });
                  await  getDirection();
                 
                  }
              }else{
                
 Provider.of<AppData>(context,listen: false).updateDestinationAddress(pickupPlace);
                
               getLocations();
                await  getDirection();
               setState(() {
                 
               });
              }
            },
          
        ),
        
           SizedBox(height: 10,),
           BrandDivider(),
           SizedBox(height: 16,),

        GestureDetector(
          onTap:()async{
            showSnackBar('Processing');
            if(work==null){
               var response = await  Navigator.push(context, MaterialPageRoute(
                  builder:(context)=>AddFvtLocation(1)
                  ));
                   getLocations();
                  setState(() {
                     
                    });
                  if (response == 'set pickup'&& Provider.of<AppData>(context,listen:false).destinationAddress !=null){
                    setState(() {
                      rideStatus = 1;
                    });
                     await  getDirection();
                  }
            }else{
              
 Provider.of<AppData>(context,listen: false).updateDestinationAddress(workpickupPlace);
            
           await  getLocations();
           await  getDirection();
           setState(() {
                 
               });      
            }
          
          },
        child:
          Row(
            children: [
              Icon(Icons.work_outline,color: Colors.black54,),
              SizedBox(width: 12,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(work==null?'Add Work':work),
                  SizedBox(height: 3,),
                  Text('Your office address',
                    style:TextStyle(fontSize: 11,color:Colors.black38))
                ],)
            ],),
         ), SizedBox(height: 10,),
           BrandDivider(),
           SizedBox(height: 16,),
         
         GestureDetector(child: 
          Row(
            children: [
              Icon(Icons.star,color: Colors.black54,),
              SizedBox(width: 12,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(other==null?'Saved Places':other),
                 
                ],)
            ],),onTap: ()async{
              showSnackBar('Processing');
                 if(other==null){
               var response = await  Navigator.push(context, MaterialPageRoute(
                  builder:(context)=>AddFvtLocation(2)
                  ));
                   getLocations();
                  setState(() {
                     
                    });
                  if (response == 'set pickup'&& Provider.of<AppData>(context,listen:false).destinationAddress !=null){
                    setState(() {
                      rideStatus = 1;
                    });
                     await  getDirection();
                  }
            }else{
              
 Provider.of<AppData>(context,listen: false).updateDestinationAddress(otherpickupPlace);
            
           await  getLocations();
           await  getDirection();
           setState(() {
                 
               });      
            }
                        },
         )
          ],
      ),
      )
  )
),

   height: 400,
    
    
    );
    
   
    
   }

  Widget rideStatusSelect(){
  
    return Container(

      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: whtColor,
        borderRadius: BorderRadius.circular(10)
      ),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
         // Text(cost.toString()),
          
          Text(
            (tripDirectionDetails != null)
            ?
            
            'Estimated QAR '+((tripDirectionDetails.distanceValue)/1005).truncate().toString()
             :
            'Estimated QAR ' +(1).toString(),
             style: TextStyle(fontSize: 20, backgroundColor: whtColor, fontWeight: FontWeight.bold),),
          Text((tripDirectionDetails != null)
            ?tripDirectionDetails.distanceText:'--km',),
          
          PrimaryButton(FillColor: green,Heading: 'Continue',onTap: continuePressed,)
        ],
      ),
    );
  }

  Widget driverOnTheWay(){
    return Container(
      padding: EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 10),
      color: whtColor,
      child: Column(
        children: [
          // Driver name and Time Row
         Container(
           padding: EdgeInsets.only(left: 20, right: 20),
           child: Column(
             children: [
               rideStatus==3?   Row(
                 mainAxisAlignment: MainAxisAlignment.start,
                 children: [
                 
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         children: [
                           Text('Dropoff Location', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                         ],
                       ),
                       ],
                   ),
                 
                 ],
               ):SizedBox(),
           
              rideStatus==3?  Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   Container(child:  Column(
                       children: [
                          SizedBox(height: 12,),
                          Image.asset('assets/pickicon.png',height: 16,width: 16,),
                   Padding(padding: EdgeInsets.only(left:0),child:Dash(
                      direction: Axis.vertical,
                      length: 35,
                      dashLength: 4,
                      dashColor: Colors.grey),),
                  Image.asset('assets/desticon.png',height: 16,width: 16,),
                    
                       ],),
                   
                    ),
                    SizedBox(width:10),
                     Container(
                     height: 100,
                     width: MediaQuery.of(context).size.width-85,
                     child:  Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           SizedBox(height: 12,),
                          Expanded(child: Text(Provider.of<AppData>(context, listen: false).pickupAddress==null
                          ?
                           'Barkat wala gala, Bismillah Colony, Gujranwala'
                           :
                           Provider.of<AppData>(context, listen: false).pickupAddress.placeName
                           ,overflow: TextOverflow.clip,maxLines: 2, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),),
                           SizedBox(height: 12,),
                         Expanded(child: Text(Provider.of<AppData>(context, listen: false).destinationAddress==null
                         ?
                         'Appt. no 32, Phase IV, Street 59, Ring Road Lahore':Provider.of<AppData>(context, listen: false).destinationAddress.placeName,overflow: TextOverflow.clip,maxLines: 2, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),),
                   
                   
                         ],),
                           // Massega and calling row
                 
                   
                   ),
                  
                  
                       
                   
                  ],
                ):
               
               Row(
                 children: [

                   Expanded(child: Text(rideStatus==4?'Ride Completed':rideStatus==3?'Heading to Dropoff Location':rideStatus==9?'Driver Arrived':rideStatus==2?'Meet at the pickup point':allDrivers.length==1?'Driver Name':allDrivers[0].username ,overflow: TextOverflow.visible, style: TextStyle(color: DarkGray, fontSize: 16, fontWeight: FontWeight.bold),),),
                   Container(
                     margin: EdgeInsets.only(left: 10,),
                     padding: EdgeInsets.all(10),
                     color: blueColor,
                     child: Text(tripDirectionDetails==null?'':tripDirectionDetails.durationText, style: TextStyle(color: whtColor, fontSize: 16, fontWeight: FontWeight.bold)),
                   )
                 ],
               ),
               SizedBox(height: 10,),
               // image and detail Row
               Row(
                 mainAxisAlignment: MainAxisAlignment.start,
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
               
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         children: [
                           Text('Feedback: '+driver_feed.toString()??'0.0', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                           Icon(Icons.star, size: 15,)
                         ],
                       ),
                       Text(rideStatus==2?allDrivers[0].username:'Top Driver', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                     ],
                   )
                 ],
               ),
             ],
           ),
         ),

           SizedBox(height: 20,),
          // Massega and calling row
          Row(
            children: [
             Expanded(child: 
             GestureDetector(
               onTap: (){
                  showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                elevation: 16,
                child: Container(
                  height: 200.0,
                  width: 360.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Center(
                      child: Text(allDrivers[0].phone),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      RaisedButton(child: Text('Call'),
                      onPressed: (){
                        launch("tel:${allDrivers[0].phone}");
                      },),
                      SizedBox(width: 5,),
                      RaisedButton(child: Text('Cancel'),
                      onPressed: (){
                        Navigator.of(context).pop();
                      },),
                    ],)
                  ],)
                 ),
              );
            },
          );
                  
               },child:   Container(
               height: 50,
               alignment: Alignment.center,
               decoration: BoxDecoration(
                   border: Border(top: BorderSide(width: 1, color: lightGray), right: BorderSide(width: 1, color: lightGray))
               ),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.phone, color: lightGray,),
                   SizedBox(width: 10,),
                   Text('Call', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                 ],
               ),
             )),
            
             ),
             
              Expanded(child:

              GestureDetector(
                onTap: massegePress,
                child:  Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border(top: BorderSide(width: 1, color: lightGray),)
                  ),
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10,),
                      Icon(Icons.sms_sharp, color: lightGray,),
                      SizedBox(width: 10,),
                      Text('Massage', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                    ],
                  ),
                ),
              ))
            ],
          ),
           SizedBox(height: 10,),
           rideStatus==2?FlatButton(child: Text('Decline',style:TextStyle(color: Colors.red)),onPressed: cancelRideRequest,):SizedBox(),
         

         /* Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: EdgeInsets.only(left: 15, right: 15),
                decoration: BoxDecoration(
                    color: lightGray,
                    borderRadius: BorderRadius.circular(15)
                ),
                 height: 35,
                width: MediaQuery.of(context).size.width*.6,
                child: Row(
                  children: [
                    Expanded(child: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Pickup Note?',
                        hintStyle: TextStyle(color: whtColor),
                      ),

                      style: TextStyle(color: whtColor),
                    )
                    ),
                    Icon(Icons.send, color: whtColor,size: 20,)

                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: lightGray,
                  borderRadius: BorderRadius.circular(15)
                ),
                padding: EdgeInsets.all(5),
                child: Icon(Icons.phone, color: whtColor,),
              )
            ],
          )*/
        ],
      ),
    );
  }





  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _Markers.clear();


   currentlocation = LatLng(latt, longg);
     _lastMapPosition = currentlocation;
      HelperMethods.getCurrentUSerInfo();
   startTime();
   getLocations();
  setState(() {
    
  });
    //checkRideRequestStatus();
  }



  startTime() async {
    var _duration = Duration(seconds: 2);
    return Timer(_duration, getUserLocation);
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
    //position.target = _lastMapPosition;
  }
  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    setState(() {
      if(rideStatus==0){
        mapBottomPadding =(Platform.isAndroid) ?260:250;
      }else{
        mapBottomPadding = 0.0;
      }
    });

  }

driverLocation(int varible){

      DatabaseReference checkDriverLocation = FirebaseDatabase.instance.reference().child('users/${driver_id}/position');
         

   checkDriverLocation.onChildChanged.listen((event) async {
      print('Triggered Listener on -- CHANGED -- friend info');
      print('info that changed: ${event.snapshot.key}: ${event.snapshot.value}');
     //  await  getDirectiontoCustomer();

     var pickup =  'On the way';
    var destination =tripList[0].pickup_address;
                
                driver_lat =   FireHepler.getDriverLatitude(driver_id);
                driver_lng =   FireHepler.getDriverLongitude(driver_id);
    var pickupLatLng = LatLng(driver_lat,driver_lng);
    var destinationLatLng = LatLng(tripList[0].pickup_latitude,tripList[0].pickup_longitude);

if(varible == 1){
   var pickup =  tripList[0].pickup_address;
  var destination = tripList[0].destination_address;
    
   // var pickupLatLng = LatLng(_trip[0].pickup_latitude,_trip[0].pickup_longitude);
    var destinationLatLng = LatLng(tripList[0].destination_latitude,tripList[0].destination_longitude);

}
   

   
      var thisDetails = await HelperMethods.getDirectionDetails(pickupLatLng,destinationLatLng);
    
    setState(() {
      tripDirectionDetails = thisDetails;
     
     
    });
setState(() {
    polylineCoordinates.clear();
});
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(thisDetails.encodedPoints);
      if(results.isNotEmpty){
      results.forEach((PointLatLng point){
         polylineCoordinates.add(
            LatLng(point.latitude,point.longitude)
         );
      });     setState(() {
        _polylines.clear();
    
      _polylines.add(Polyline(
       polylineId: PolylineId('polyid'),
      color:Colors.black54,
      points: polylineCoordinates,
      jointType: JointType.round,
      width: 4,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
        
        ));
    });
    
  Marker pickupMarker = Marker(
    markerId: MarkerId('pickup'),
    position: pickupLatLng,
    icon: nearbyIcon,
    infoWindow: InfoWindow(title: 'On the way',snippet: 'Driver location'),
  );
  
  Marker destinationMarker = Marker(
    markerId: MarkerId('destination'),
    position: destinationLatLng,
    icon:  await BitmapDescriptor.fromAssetImage(
                    ImageConfiguration(
                      devicePixelRatio: 2.5,
                    ),
                    'assets/posimarker.png',
                  ),
    infoWindow: InfoWindow(title: tripList[0].pickup_address,snippet: 'Rider Pickup location'),
  );
  
  setState(() {
    _Markers.clear();
    _Markers.add(pickupMarker);
    _Markers.add(destinationMarker);

  });
  
  }

        
   });

}
Future<void> getDirectiontoCustomer() async {
 await driverLocation(0);
     setState(() {
    
    _Markers.clear();
  });
    var pickup =  Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =Provider.of<AppData>(context, listen: false).pickupAddress;
    
                driver_lat =   FireHepler.getDriverLatitude(driver_id);
                driver_lng =   FireHepler.getDriverLongitude(driver_id);

    var pickupLatLng = LatLng(driver_lat,driver_lng);
    var destinationLatLng = LatLng(destination.latitude,destination.longitude);

   
    var thisDetails = await HelperMethods.getDirectionDetails(pickupLatLng,destinationLatLng);
    
    setState(() {
      tripDirectionDetails = thisDetails;
      rideStatus = 2;
     
    });

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(thisDetails.encodedPoints);
    
    polylineCoordinates.clear();
    
    if(results.isNotEmpty){
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));

      });

    }
  _polylines.clear();
  setState(() {
     Polyline polyline = Polyline(
      polylineId: PolylineId('polyid'),
      color:Colors.black54,
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

  _controller.animateCamera(CameraUpdate.newLatLngBounds(bounds,70));
  
  Marker pickupMarker = Marker(
    markerId: MarkerId('pickup'),
    position: pickupLatLng,
    icon: await BitmapDescriptor.fromAssetImage(
                    ImageConfiguration(
                      devicePixelRatio: 2.5,
                    ),
                    'assets/posimarker.png',
                  ),
    infoWindow: InfoWindow(title: 'On the way',snippet: 'Driver location'),
  );
  
  Marker destinationMarkers = Marker(
    markerId: MarkerId('destination'),
    position: destinationLatLng,
    icon:  await BitmapDescriptor.fromAssetImage(
                    ImageConfiguration(
                      devicePixelRatio: 2.5,
                    ),
                    'assets/pickup_ico.png',
                  ),
    infoWindow: InfoWindow(title: destination.placeName,snippet: 'Rider Pickup location'),
  );
  
  setState(() {
    _Markers.add(pickupMarker);
    _Markers.add(destinationMarkers);

  });
  
  Circle pickupCircle = Circle(
    circleId: CircleId('Current Location'),
    strokeColor: Colors.black45,
    strokeWidth: 3,
    center: pickupLatLng,
    fillColor: Colors.black38
  );

  Circle destinationCircle = Circle(
    circleId: CircleId('Customer Pickup'),
    strokeColor: Colors.black45,
    strokeWidth: 3,
    center: destinationLatLng,
    fillColor: Colors.black38
  );
  
 setState(() {
    _Circle.add(pickupCircle);
  _Circle.add(destinationCircle);

 });

  }
Future<void> getDirectiontoCustomerResume() async {
    // await driverLocation(0);
    var pickup =  'On the way';
    var destination =tripList[0].pickup_address;
                
                driver_lat =   FireHepler.getDriverLatitude(driver_id);
                driver_lng =   FireHepler.getDriverLongitude(driver_id);

    var pickupLatLng = LatLng(driver_lat,driver_lng);
    var destinationLatLng = LatLng(tripList[0].pickup_latitude,tripList[0].pickup_longitude);


   
      var thisDetails = await HelperMethods.getDirectionDetails(pickupLatLng,destinationLatLng);
    
    setState(() {
      tripDirectionDetails = thisDetails;
     
     
    });

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(thisDetails.encodedPoints);
    
    polylineCoordinates.clear();
    
    if(results.isNotEmpty){
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));

      });

    }
  _polylines.clear();
  setState(() {
     Polyline polyline = Polyline(
      polylineId: PolylineId('polyid'),
      color:Colors.black54,
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

  _controller.animateCamera(CameraUpdate.newLatLngBounds(bounds,70));
  
  Marker pickupMarker = Marker(
    markerId: MarkerId('pickup'),
    position: pickupLatLng,
    icon: nearbyIcon,
    infoWindow: InfoWindow(title: 'On the way',snippet: 'Driver location'),
  );
  
  Marker destinationMarker = Marker(
    markerId: MarkerId('destination'),
    position: destinationLatLng,
    icon:  await BitmapDescriptor.fromAssetImage(
                    ImageConfiguration(
                      devicePixelRatio: 2.5,
                    ),
                    'assets/posimarker.png',
                  ),
    infoWindow: InfoWindow(title: tripList[0].pickup_address,snippet: 'Rider Pickup location'),
  );
  
  setState(() {
    _Markers.clear();
    _Markers.add(pickupMarker);
    _Markers.add(destinationMarker);

  });
  
  Circle pickupCircle = Circle(
    circleId: CircleId('Current Location'),
    strokeColor: Colors.black45,
    strokeWidth: 3,
    center: pickupLatLng,
    fillColor: Colors.black38
  );

  Circle destinationCircle = Circle(
    circleId: CircleId('Customer Pickup'),
    strokeColor: Colors.black45,
    strokeWidth: 3,
    center: destinationLatLng,
    fillColor: Colors.black38
  );
  
 setState(() {
    _Circle.add(pickupCircle);
  _Circle.add(destinationCircle);

 });

  }

 Future<void> getDirection() async {
    await driverLocation(1);
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination = Provider.of<AppData>(context,listen: false).destinationAddress;
    
    var pickupLatLng = LatLng(pickup.latitude,pickup.longitude);
    var destinationLatLng = LatLng(destination.latitude,destination.longitude);

   
      var thisDetails = await HelperMethods.getDirectionDetails(pickupLatLng,destinationLatLng);
   // cost = await HelperMethods.estimatedFares(thisDetails);
   
    setState(() {
      rideStatus = 1;
      tripDirectionDetails = thisDetails;
    });
    HelperMethods.estimatedFares(tripDirectionDetails);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(thisDetails.encodedPoints);
    
    polylineCoordinates.clear();
    
    if(results.isNotEmpty){
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));

      });

    }
  _polylines.clear();
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

    _polylines.add(polyline);
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

  _controller.animateCamera(CameraUpdate.newLatLngBounds(bounds,70));
  
  Marker pickupMarker = Marker(
    markerId: MarkerId('pickup'),
    position: pickupLatLng,
     icon: await BitmapDescriptor.fromAssetImage(
                    ImageConfiguration(
                      devicePixelRatio: 2.5,
                    ),
                    'assets/pickup_ico.png',
                  ),
    infoWindow: InfoWindow(title: pickup.placeName,snippet: 'My Location'),
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
    infoWindow: InfoWindow(title: destination.placeName,snippet: 'Destination'),
  );
  
  setState(() {
    _Markers.clear();
    _Markers.add(pickupMarker);
    _Markers.add(destinationMarker);

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
    _Circle.add(pickupCircle);
  _Circle.add(destinationCircle);

 });

  }

 
  Future<void> getDirectionResume() async {
    await driverLocation(1);
    var pickup = tripList[0].pickup_address;
    var destination = tripList[0].destination_address;
    
    var pickupLatLng = LatLng(tripList[0].pickup_latitude,tripList[0].pickup_longitude);
    var destinationLatLng = LatLng(tripList[0].destination_latitude,tripList[0].destination_longitude);

   
      var thisDetails = await HelperMethods.getDirectionDetails(pickupLatLng,destinationLatLng);
    
    setState(() {
     
      tripDirectionDetails = thisDetails;
    });
    HelperMethods.estimatedFares(tripDirectionDetails);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(thisDetails.encodedPoints);
    
    polylineCoordinates.clear();
    
    if(results.isNotEmpty){
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));

      });

    }
  _polylines.clear();
  setState(() {
     Polyline polyline = Polyline(
      polylineId: PolylineId('polyid'),
      color:Colors.black54,
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

  _controller.animateCamera(CameraUpdate.newLatLngBounds(bounds,70));
  
 
  Marker pickupMarker = Marker(
    markerId: MarkerId('pickup'),
    position: pickupLatLng,
     icon: await BitmapDescriptor.fromAssetImage(
                    ImageConfiguration(
                      devicePixelRatio: 2.5,
                    ),
                    'assets/pickup_ico.png',
                  ),
    infoWindow: InfoWindow(title: tripList[0].pickup_address,snippet: 'My Location'),
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
    infoWindow: InfoWindow(title: tripList[0].destination_address,snippet: 'Destination'),
  );
  
  setState(() {
    _Markers.clear();
    _Markers.add(pickupMarker);
    _Markers.add(destinationMarker);

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
    _Circle.add(pickupCircle);
  _Circle.add(destinationCircle);

 });

  }

  void getUserLocation() async {
    setState(() {
       isLoading = false;
    });
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
       gotLocation=true;
      
     });
       User user = FirebaseAuth.instance.currentUser;
   
        DatabaseReference teRef = FirebaseDatabase.instance.reference().child('users/${user.uid}');
              
              Map currentPosition = {
                'lat':lat,
                'lng':lng
              };
              teRef.child('position').set(currentPosition); 

              
   
      PushNotificationService p = PushNotificationService();
  var token = await p.getToken();

      print('Your Latitude is: $latt, Longitude is: $longg');
      await _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target:LatLng(latt, longg),zoom: 15,)));
     
      String address = await HelperMethods.findCordinateAddress(position,context);
await startGeofireListener();

await  resumeState();

  rideReference = FirebaseDatabase.instance.reference().child('rideRequest').push();
await checkRideRequestStatus();

await startGeofireListener();
     location.onLocationChanged().listen((event) { 
       currentLocation = event;
           DatabaseReference teRef = FirebaseDatabase.instance.reference().child('users/${user.uid}');
              
              Map currentPosition = {
                'lat':currentLocation["latitude"],
                'lng':currentLocation["longitude"]
              };
              teRef.child('position').set(currentPosition); 
     });


    } on Exception {
      currentLocation = null;
      return null;
    }
  }

void massegePress(){
    AppRoutes.push(context, MassageScreen());
}

Future<void> continuePressed() async {
setState(() {
  rideStatus=6;
});
await createRideRequest();
 var _duration = Duration(seconds: 2);
    return Timer(_duration, checkRideRequestStatus);

}
 String driver_id ;


Future<void> createRideRequest() async {
  
  rideReference = FirebaseDatabase.instance.reference().child('rideRequest').push();
  var pickup ;
  var destination ;
  
  // ANCHOR LOCATION METHODS
  // 
  
  // driver_id = '50nH73TCKhTCvlNhcy1a8rtEKk62';
  try{
      pickup = Provider.of<AppData>(context, listen:false ).pickupAddress;
   destination = Provider.of<AppData>(context, listen: false).destinationAddress;
   //  driver_id = FireHepler.getNearbyDriver();

     // get list of all drivers. and add 20 km distance limit 
     // check each  driver location from customer
  NearbyDrivers driver;   
  for(NearbyDrivers driver in FireHepler.nearbyDriverList){
    LatLng driverPosition = LatLng(driver.latitude, driver.longitude);
    driver = driver;
  
    double distance = await Geolocator.distanceBetween(
       pickup.latitude,
       pickup.longitude,
      driver.latitude,
       driver.longitude);
   
    if (distance <= 20000) {
      driver_id = driver.key;

      
 Map pickupMap = {
    'latitude':pickup==null?'':pickup.latitude,
    'longitude':pickup==null?'':pickup.longitude,
  };

  Map destinationMap = {
    'latitude':destination==null?'':destination.latitude,
    'longitude':destination==null?'':destination.longitude,
  };
  var ss =  DateTime.now().toString();
var parts = ss.split(' ');
var date = parts[0].trim().toString();                 // prefix: "date"
var d = parts[1].split('.');
var time = d[0].trim().toString();
var thisInstant = new DateTime.now().toString();
  Map rideMap = {
    'created_at':thisInstant,
    'timestamp': ServerValue.timestamp,
    'date':date,
    'time':time,
    'ride_start':DateTime.now().toString(),
    'rider_name': currentUserInfo.username,
    'rider_phone': currentUserInfo.phone,
    'rider_id':currentUserInfo.id,
    'pickup_address': pickup==null?'':pickup.placeName,
    'destination_address': destination==null?'':destination.placeName,
    'location':pickupMap,
    'destination':destinationMap,
    'payment_method': 'cash',
    'driver_id':'waiting',
    'request_to':driver_id,
    'request_to_status':0,
    'status':0,
    'tag':0,
  //  'rider_token': currentUserInfo.token,
 //   'driver_token':driver_token
  };

  rideReference.set(rideMap);
  rideReference.child('trip_id').set(rideReference.key);
  
  trip_id = rideReference.key;

   DatabaseReference updateRef = FirebaseDatabase.instance.reference().child('users/${driver_id}');
              updateRef.child("newReq").set(trip_id);
   DatabaseReference updateRefo = FirebaseDatabase.instance.reference().child('users/${currentUserInfo.id}');
              updateRefo.child("newTrip").set(trip_id);

tripDirectionDetails.distanceText = "--";


            var _duration = Duration(seconds: 20);
            
             Timer(_duration, requestTime);
            
      return;
      
    }  if(driver_id==null){
        showSnackBar("Currently No Driver Available Nearby");
        cancelRideRequest();
        return;
      }
   
  } 
     
  }catch(e){

  //    showSnackBar("Currently No Driver Available Nearby");
      
    
  }

   


             
           
        
}

void requestTime(){
  rideReference.onValue.listen((event) async {

 if(event.snapshot.value["request_to_status"] == 0){
          
            
         cancelRideRequest();
         if(rideStatus==0){
            await getDirection();
         }
 }
});
}

Future<void> cancelRideRequest() async {
 
  rideReference.remove();
    DatabaseReference teRef = FirebaseDatabase.instance.reference().child('rideRequest/${trip_id}/status');
              teRef.set(2);  
     DatabaseReference teReft = FirebaseDatabase.instance.reference().child('rideRequest/${trip_id}/request_to_status');
              teReft.set(2); 
       DatabaseReference teRefti = FirebaseDatabase.instance.reference().child('rideRequest/${trip_id}/request_to');
              teRefti.set("");  
               DatabaseReference teReftix = FirebaseDatabase.instance.reference().child('rideRequest/${trip_id}/driver_id');
              teReftix.set("");   
    rideReference = FirebaseDatabase.instance.reference().child('users/${driver_id}/newReq');
    rideReference.remove();
        DatabaseReference teRefs = FirebaseDatabase.instance.reference().child('users/${driver_id}');
              teRefs.child("newReq").set("");  
              teRefs.child("newTrip").set(""); 
                 DatabaseReference updateRefo = FirebaseDatabase.instance.reference().child('users/${currentUserInfo.id}');
              updateRefo.child("newTrip").set(""); 
  setState(() {
    rideStatus=1;
    _polylines.clear();
    polylineCoordinates.clear();
    _Markers.clear();
    tripDirectionDetails.distanceText = "--";
  });
  
  await getDirection();
}
//status
//1 = accepted
//0 = pending
//2 = cancel
//3 = on the way
//4 = complated
//5 = calculate fare
//10 = close
//9= arrived
void resumeState() async{
  try{
    
  rideReference = FirebaseDatabase.instance.reference().child('rideRequest').push();
DatabaseReference statusResume = FirebaseDatabase.instance.reference().child('users/${currentUserInfo.id}/newTrip');
   statusResume.once().then((DataSnapshot v) async {
     if(v.value!=null){
       trip_id= await v.value;
         DatabaseReference  driverReference = FirebaseDatabase.instance.reference().child('rideRequest/${trip_id}');
              driverReference.once().then((DataSnapshot id) async {
               
              if(id.value!=null){
               var trip = Trip(
                        tripID: trip_id,
                        destination_address: id.value["destination_address"],
                        destination_latitude: id.value["destination"]["latitude"],
                        destination_longitude: id.value["destination"]["longitude"],
                        driver_id: id.value["driver_id"],
                        pickup_address: id.value["pickup_address"],
                        pickup_latitude: id.value["location"]["latitude"],
                        pickup_longitude: id.value["location"]["longitude"],
                        payment_method: id.value["payment_method"],
                        request_to: id.value["request_to"],
                        request_to_status: id.value["request_to_status"],
                        rider_id: id.value["rider_id"],
                        rider_name: id.value["rider_name"],
                        rider_phone: id.value["rider_phone"],
                        status: id.value["status"],
                        tag: id.value["tag"]
                    );
                      setState(() {
                         tripList.clear();
                      });
                     tripList.add(trip);
                          print(tripList.length);
                   
                 driver_id = id.value["request_to"];
                 DatabaseReference  driverReference1 = FirebaseDatabase.instance.reference().child('users/${driver_id}');
              driverReference1.once().then((DataSnapshot dataSnapshot) async {
                  if(dataSnapshot.value!=null){
                        var driverDetail = Drivers(
                  id: driver_id,
                  username: dataSnapshot.value["username"],
                  email: dataSnapshot.value["email"],
                  displayImage: dataSnapshot.value["displayImage"],
                  phone: dataSnapshot.value["phone"],
                  newtrip: dataSnapshot.value["newtrip"],
                  role: dataSnapshot.value["role"],
                  status: dataSnapshot.value["status"],
                  tag: dataSnapshot.value["tag"],
                );
                driver_feed = dataSnapshot.value["feedback"];
                driver_img =  dataSnapshot.value["displayImage"];
                allDrivers.clear();
                allDrivers.add(driverDetail);
                 getStatus();
                setState(() {
                driver_lat =   FireHepler.getDriverLatitude(driver_id);
                driver_lng =   FireHepler.getDriverLongitude(driver_id);
                });
                if(driver_lat!=null||driver_lng!=null){
                    getStatus();
                }else {
                  setState(() {
                driver_lat =   FireHepler.getDriverLatitude(driver_id);
                driver_lng =   FireHepler.getDriverLongitude(driver_id);
                });
                if(driver_lat!=null||driver_lng!=null){
                    getStatus();
                }
                }
           
          
                  }
             });
           
             
           
     
              }
              });
            
    } });
          
      getStatus();
  
  }catch(e){
     getStatus();
  }
}

void getStatus(){
     DatabaseReference updateRef = FirebaseDatabase.instance.reference().child('rideRequest/${trip_id}/status');
           updateRef.once().then(( DataSnapshot event) async {
             if(event.value==1){
              DatabaseReference updateRef = FirebaseDatabase.instance.reference().child('users/${driver_id}/newtrip');
              updateRef.set(trip_id);
              DatabaseReference teRef = FirebaseDatabase.instance.reference().child('rideRequest/${trip_id}/driver_id');
              teRef.set(driver_id);
 
           DatabaseReference updat = FirebaseDatabase.instance.reference().child('users/${driver_id}');
           updat.once().then(( DataSnapshot event) async {
           setState(() {
               driver_img = event.value["displayImage"];
               driver_feed = event.value["feedback"];
              
           });

           });  
          setState(() {
          rideStatus=2;
        
          //ride request accepted
        });
                    
          await  getDirectiontoCustomerResume();
        }if(event.value == 9){
            Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      title:"Driver Arrived",
      duration: Duration(seconds: 3),
    
    );
          // driver arrived
        
             setState(() {
          rideStatus=9;
          //arrived
        
        });     
 await  getDirectiontoCustomerResume();
        }if(event.value == 3){
          // driver start ride
     
         Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      title:"Ride Started",
      duration: Duration(seconds: 3),
    
    );
             setState(() {
          rideStatus=3;
          //arrived
         
        });     
 await   getDirectionResume();
        }if(event.value == 4){
         //  Ringtone.play();
           setState(() {
          rideStatus=4;
          //ride  complete
         //  Ringtone.stop();
        });
         await   getDirectionResume();
           Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      title:"Ride Completed",
      duration: Duration(seconds: 3),
    
    );
          
        }if(event.value == 5){
      //     Ringtone.play();
          setState(() {
                          rideStatus=0;
                      //     Ringtone.stop();
                           Provider.of<AppData>(context).destinationAddress=null;
                           

                        });
          //cash
            
            Map data = {
                'total_EstimatedFare': estimatedFare[0].total_EstimatedFare,
                'base_EstimatedFare':estimatedFare[0].base_EstimatedFare,
                'distance_EstimatedFare':estimatedFare[0].distance_EstimatedFare,
                'time_EstimatedFare':estimatedFare[0].time_EstimatedFare,
                'distance':tripDirectionDetails.distanceText,
  };
     Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      title:"Please pay estimated cash ${estimatedFare[0].total_EstimatedFare}" ,
      duration: Duration(seconds: 3),
    
    );
    DatabaseReference feedbackReference = FirebaseDatabase.instance.reference().child('rideRequest/$trip_id');
               feedbackReference.child("total_EstimatedFare").set(estimatedFare[0].total_EstimatedFare);
              feedbackReference.child("base_EstimatedFare").set(estimatedFare[0].base_EstimatedFare);
              feedbackReference.child("distance_EstimatedFare").set(estimatedFare[0].distance_EstimatedFare);
              feedbackReference.child("time_EstimatedFare").set(estimatedFare[0].time_EstimatedFare);
              feedbackReference.child("distance").set(tripDirectionDetails.distanceText);
              feedbackReference.child("ride_end").set(DateTime.now().toString());
              feedbackReference.child('complaintByDriver').set(0); 
              feedbackReference.child('complaintByCustomer').set(0);  

    DatabaseReference updateRefo = FirebaseDatabase.instance.reference().child('users/${currentUserInfo.id}');
              
              updateRefo.child("total_EstimatedFare").set(estimatedFare[0].total_EstimatedFare);
              updateRefo.child("distance").set(tripDirectionDetails.distanceText);
              updateRefo.child("ride_end").set(DateTime.now().toString());

  
     
      //  showSnackBar("Please pay estimated cash ${estimatedFare[0].total_EstimatedFare}" );
         DatabaseReference teRef = FirebaseDatabase.instance.reference().child('rideRequest/${trip_id}/status');
              teRef.set(10);
   AppRoutes.push(context, CustomerBillCalculationClass(trip_id,driver_id));
        

        }
        
         if(event.value == 2){
          cancelRideRequest();
           showSnackBar('Request Cancelled');
           return;
        }
         if(event.value == 1){
         
                  DatabaseReference updat = FirebaseDatabase.instance.reference().child('users/${driver_id}');
           updat.once().then(( DataSnapshot event) async {
           setState(() {
               driver_img = event.value["displayImage"];
               driver_feed = event.value["feedback"];
              
           });

           });
            setState(() {
            rideStatus=2;
          });
        }
        if(event.value == 10){
          setState(() {
            rideStatus=0;
          });
        }
           }
           )  ;

}
void checkRideRequestStatus(){
  try{
   rideReference.onChildChanged.listen((event) async {
     resumeState();
        print('Triggered Listener on -- CHANGED -- friend info');
        print('info that changed: ${event.snapshot.key}: ${event.snapshot.value}');
        if(event.snapshot.value==1){
              DatabaseReference updateRef = FirebaseDatabase.instance.reference().child('users/${driver_id}');
              updateRef.child("newtrip").set(trip_id);
              DatabaseReference teRef = FirebaseDatabase.instance.reference().child('rideRequest/${trip_id}');
              teRef.child("driver_id").set(driver_id);

             DatabaseReference  driverReference = FirebaseDatabase.instance.reference().child('users/${driver_id}');
              driverReference.once().then((DataSnapshot dataSnapshot) async {
             
                var driverDetail = Drivers(
                  id: driver_id,
                  username: dataSnapshot.value["username"],
                  email: dataSnapshot.value["email"],
                  displayImage: dataSnapshot.value["displayImage"],
                  phone: dataSnapshot.value["phone"],
                  newtrip: dataSnapshot.value["newtrip"],
                  role: dataSnapshot.value["role"],
                  status: dataSnapshot.value["status"],
                  tag: dataSnapshot.value["tag"],
                );
                allDrivers.clear();
                allDrivers.add(driverDetail);
                setState(() {
                driver_lat =   FireHepler.getDriverLatitude(driver_id);
                driver_lng =   FireHepler.getDriverLongitude(driver_id);
                });
                   
               await  getDirectiontoCustomer();
           });
        
             
        
                DatabaseReference updat = FirebaseDatabase.instance.reference().child('users/${driver_id}');
           updat.once().then(( DataSnapshot event) async {
           setState(() {
               driver_img = event.value["displayImage"];
               driver_feed = event.value["feedback"];
              
           });

           });
             setState(() {
          rideStatus=2;
         
          //ride request accepted
        });
        
        }if(event.snapshot.value == 9){
             Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      title:"Driver Arrived",
      duration: Duration(seconds: 3),
    
    );
          // driver arrived
             setState(() {
          rideStatus=9;
          //arrived
        });     

        }if(event.snapshot.value == 3){
          // driver start ride
       await   getDirection();
         Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      title:"Ride Started",
      duration: Duration(seconds: 3),
    
    );
             setState(() {
          rideStatus=3;
          //arrived
        });     

        }if(event.snapshot.value == 4){
           setState(() {
          rideStatus=4;
          //ride  complete
        });
          Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      title:"Ride Completed",
      duration: Duration(seconds: 3),
    
    );
          
        }if(event.snapshot.value == 5){
          setState(() {
                          rideStatus=0;
                          _Markers.clear();
                          _polylines.clear();
                          polylineCoordinates.clear();
                          
                        });
          //cash
          //

            Map data = {
                'total_EstimatedFare': estimatedFare[0].total_EstimatedFare,
                'base_EstimatedFare':estimatedFare[0].base_EstimatedFare,
                'distance_EstimatedFare':estimatedFare[0].distance_EstimatedFare,
                'time_EstimatedFare':estimatedFare[0].time_EstimatedFare,
                'distance':tripDirectionDetails.distanceText,
  };
     Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      title:"Please pay estimated cash ${estimatedFare[0].total_EstimatedFare}" ,
      duration: Duration(seconds: 3),
    
    );
    DatabaseReference feedbackReference = FirebaseDatabase.instance.reference().child('rideRequest/$trip_id');
              feedbackReference.child("total_EstimatedFare").set(estimatedFare[0].total_EstimatedFare);
              feedbackReference.child("base_EstimatedFare").set(estimatedFare[0].base_EstimatedFare);
              feedbackReference.child("distance_EstimatedFare").set(estimatedFare[0].distance_EstimatedFare);
              feedbackReference.child("time_EstimatedFare").set(estimatedFare[0].time_EstimatedFare);
              feedbackReference.child("distance").set(tripDirectionDetails.distanceText);
              feedbackReference.child("ride_end").set(DateTime.now().toString());
               feedbackReference.child('complaintByDriver').set(0); 
              feedbackReference.child('complaintByCustomer').set(0);  
    DatabaseReference updateRefo = FirebaseDatabase.instance.reference().child('users/${currentUserInfo.id}');
             
              updateRefo.child("total_EstimatedFare").set(estimatedFare[0].total_EstimatedFare);
              updateRefo.child("distance").set(tripDirectionDetails.distanceText);

  

            AppRoutes.push(context, CustomerBillCalculationClass(trip_id,driver_id));
           
      
         DatabaseReference teRef = FirebaseDatabase.instance.reference().child('rideRequest/${trip_id}/status');
              teRef.set(10);

        }
        
        if(event.snapshot.value == 2){
          cancelRideRequest();
         
        }
        if(event.snapshot.value == 1){
          
                  DatabaseReference updat = FirebaseDatabase.instance.reference().child('users/${driver_id}');
           updat.once().then(( DataSnapshot event) async {
           setState(() {
               driver_img = event.value["displayImage"];
               driver_feed = event.value["feedback"];
              
           });

           });

           setState(() {
            rideStatus=2;
          });
        }
        if(event.snapshot.value == 10){
          setState(() {
            rideStatus=0;
          });
        }
      
   });
  }catch(e){

  }
  

}
void startGeofireListener()async{
  //  User user = FirebaseAuth.instance.currentUser;
  Geofire.initialize('driversAvailable');
  
     
  Geofire.queryAtLocation(currentLocation["latitude"], currentLocation["longitude"], 5).listen((map) {
        print(map);
        if (map != null) {
          var callBack = map['callBack'];

          //latitude will be retrieved from map['latitude']
          //longitude will be retrieved from map['longitude']

          switch (callBack) {
            case Geofire.onKeyEntered:

              NearbyDrivers nearbyDriver  = NearbyDrivers();
              nearbyDriver.key = map["key"];
              nearbyDriver.latitude = map["latitude"];
              nearbyDriver.longitude = map["longitude"];
               
              FireHepler.nearbyDriverList.add(nearbyDriver);
              if(nearbyDriverkeysLoaded){
                  updateDriveronMap();
                }
              break;

            case Geofire.onKeyExited:
              FireHepler.removeFromList(map["key"]);
              updateDriveronMap();
              break;

            case Geofire.onKeyMoved:
              NearbyDrivers nearbyDriver  = NearbyDrivers();
              nearbyDriver.key = map["key"];
              nearbyDriver.latitude = map["latitude"];
              nearbyDriver.longitude = map["longitude"];

              FireHepler.updateNearbyLocation(nearbyDriver);
              updateDriveronMap();
            // Update your key's location
              break;

            case Geofire.onGeoQueryReady:
            // All Intial Data is loaded
              nearbyDriverkeysLoaded = true;
              updateDriveronMap();
              break;
          
        }
        }
  });
  }
void updateDriveronMap(){
  setState(() {
    
    _Markers.clear();
  });

  Set<Marker> tempMarker = Set<Marker>();
  for(NearbyDrivers driver in FireHepler.nearbyDriverList){
    LatLng driverPosition = LatLng(driver.latitude, driver.longitude);

    Marker thisMarker = Marker(
      markerId: MarkerId('driver${driver.key}'),
      position: driverPosition,
      icon: nearbyIcon,
      rotation: HelperMethods.generateRandomNumber(360),
    );

    tempMarker.add(thisMarker);
  }
  setState(() {
    _Markers = tempMarker;
  });
}

}