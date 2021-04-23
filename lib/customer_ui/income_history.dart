import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/customer_ui/cust_sigle_tripdetail.dart';
import 'package:flutter_app/utilities/brandDivider.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'package:flutter_app/utilities/bar_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'bar_drawer.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/utilities/constant.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_app/core/dbmodels/trip.dart';
import 'package:firebase_database/firebase_database.dart';


import 'package:cached_network_image/cached_network_image.dart';


class IncomeHistory extends StatefulWidget {
  @override
  _IncomeHistoryState createState() => _IncomeHistoryState();
}

class _IncomeHistoryState extends State<IncomeHistory> {
   final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

getUserData(){
  
             DatabaseReference  driverReference = FirebaseDatabase.instance.reference().child('users/${currentUserInfo.id}');
              driverReference.once().then((DataSnapshot dataSnapshot) async {

                  total_km = dataSnapshot.value["distance"];
                 
                  total_earn = dataSnapshot.value["total_EstimatedFare"];

              /* 
                 
                DatabaseReference  driverR = FirebaseDatabase.instance.reference()
                          .child('rideRequest')
                          .orderByChild('driver_id')
                          .equalTo(currentUserInfo.id);
                    driverR.once().then((DataSnapshot dataSnapsh) async {
                        totol_ride = dataSnapsh.value.length;
                });

              */

              });

        
             
}

  @override
  Widget build(BuildContext context) {

    getUserData();
    return Scaffold(
      key: _scaffoldKey,
      //drawer: CusDrawerPage(context),
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight), // here the desired height
          child: CusAppBarClass( context, 'Earning History', false,_scaffoldKey) ),

      body: Historylist(),

    );
  }
  Widget Historylist(){
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView(
        children: [
          Card(
        margin: EdgeInsets.all(10),

      //  padding: EdgeInsets.all(20),
        // decoration: BoxDecoration(
        //     color: whtColor,
        //     border: Border(bottom: BorderSide(width: 1, color: lightGray))

        // ),
        child: Padding(padding: EdgeInsets.all(20),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // time and cash row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   Text(constant_role==0?'QAR --':'QAR '+total_earn.toString()!=null?total_earn.toString():'00'??'QAR 00', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),),

                   Text(constant_role==0?'Total Spend':'Total Earning', style: TextStyle(fontSize: 14, ),),
                
                ],),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
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
               
              ],) 
              
                
              ],
            ),
            SizedBox(height: 10,),
           

          ],
        ),
     )
        ),
  BarChartSample1(), 
   SizedBox(height: 10,), 
  BrandDivider(),
   Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FlatButton(onPressed: (){

                    }, 
                    child: Column(
                      children: [
                           Text('Total Trips'),
                          SizedBox(height:4),
                          Text(totol_ride??'--',style: TextStyle(fontSize: 18),)

                    ],)),
                     FlatButton(onPressed: (){
                       
                    }, 
                    child: Column(
                      children: [
                          Text('Total Earn'),
                          SizedBox(height:4),
                          Text(total_earn!=null?total_earn.toString()??'0':'0',style: TextStyle(fontSize:18),)


                    ],)),
                     FlatButton(onPressed: (){
                      
                     }, 
                    child: Column(
                      children: [
                          Text('Total Distance'),
                          SizedBox(height:4),
                          Text(total_km!=null?total_km.toString()??'140 km':'2 KM',style: TextStyle(fontSize: 18),)


                    ],))
                
                
                ],)
       , BrandDivider(), ],
      ),
    );
  }
}