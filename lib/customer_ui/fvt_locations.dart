import 'package:flutter/material.dart';
import 'package:flutter_app/utilities/utilities.dart';

import 'package:flutter_app/utilities/constant.dart';
import 'package:flutter_app/core/dataprovider/appData.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/model/address.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'bar_drawer.dart';
import 'package:flutter_app/customer_ui/searchpage.dart';
import 'package:flutter_app/utilities/brandDivider.dart';
import 'set_location.dart';
import 'package:flutter_app/utilities/constant.dart';

class FvtLocation extends StatefulWidget {
  @override
  _FvtLocationState createState() => _FvtLocationState();
}

class _FvtLocationState extends State<FvtLocation> {
   final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String home,work,other;
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight), // here the desired height
          child: CusAppBarClass( context, 'Select Locations', false,_scaffoldKey) ),

      body: whereWantToGo(context),);
  }


    Widget whereWantToGo(context){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
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
          SizedBox(height: 20,),
          
          Text('Saved Places', style: TextStyle(fontSize: 20, backgroundColor:  Colors.white, fontWeight: FontWeight.bold),),
          SizedBox(height: 20,),
          SizedBox(height: 22,),

          Container(
            height: 400,
            child:  StreamBuilder(
  stream: FirebaseDatabase().reference().child('users/${currentUserInfo.id}/place').onValue,
  builder: (context,  snap) {
    if (!snap.hasData)  
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
        if(snap.data.snapshot.value!=null){
            if(snap.data.snapshot.value.length==0){
               return  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                   SizedBox(
                    height: 50.0,
                  ),
                  Text("Please add Saved Places"),
                  SizedBox(
                    height: 50.0,
                  ),
                 
                ],
              ),
            );
           
           }else{
           
                  return Container(
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
          itemCount: snap.data.snapshot.value.length,
          itemBuilder: (BuildContext context, int index ){
               return  GestureDetector(child: 
               
               Column(children: [
                 Row(
            children: [
              Icon(Icons.location_on_outlined,color: Colors.black54,),
              SizedBox(width: 12,),
              Flexible(child:  Text(snap.data.snapshot.value[index]["placeName"]),)
              
            ],),
            SizedBox(height: 20,)
               ],),
          onTap: (){
           Address  thisPlace = Address();
                    thisPlace.placeName = snap.data.snapshot.value[index]["placeName"];
                    thisPlace.placeId= snap.data.snapshot.value[index]["placeID"];
                    thisPlace.placeFormattedAddress = snap.data.snapshot.value[index]["placeName"];
                    thisPlace.latitude = snap.data.snapshot.value[index]["lat"];
                    thisPlace.longitude = snap.data.snapshot.value[index]["lng"];
                  
 Provider.of<AppData>(context,listen: false).updateDestinationAddress(thisPlace);
  Navigator.pop(context, 'set pickup');
         },);
         
           
          }),
    );

             } 
              
                 
            }else{
              return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("No Saved Places"),
                 
                ],
              ),
            );
            }
       
    
  
  }
)
   
         ),
         
          ],
      ),
   )
      );
  }
}