import 'package:flutter/material.dart';
import 'package:flutter_app/utilities/utilities.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'bar_drawer.dart';
import 'package:flutter_app/customer_ui/searchpage.dart';
import 'package:flutter_app/utilities/brandDivider.dart';
import 'set_location.dart';
import 'package:flutter_app/utilities/constant.dart';

import 'package:flutter_app/customer_ui/cust_home.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/customer_ui/settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'add_locations.dart';

import 'package:flutter_app/core/helper/helperMethod.dart';
class AddLocation extends StatefulWidget {
  @override
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
   final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String home,work,other;
  @override
  Widget build(BuildContext context) {
    getLocations();
    return Scaffold(
      appBar:  AppBar(
                backgroundColor: primaryColor,
                elevation: 0,
                //actions: [Icon(Icons.menu, color: lightGray,)],
               // actions: [drawer?Icon(Icons.menu, color: DarkGray,):Container(), SizedBox(width: 10,)],
                leading: GestureDetector(onTap: () async{
                   await  HelperMethods.getCurrentUSerInfo();
         
                 AppRoutes.makeFirst(context, CustomerHomeClass());
                           
                  },
                        child: Icon(Icons.arrow_back,color: whtColor, ),),
                title:  Text('Add Locations', style: TextStyle(fontSize:15, color: whtColor),),
                centerTitle: true,
              ),
          
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
          
          Text('Set Locations', style: TextStyle(fontSize: 20, backgroundColor:  Colors.white, fontWeight: FontWeight.bold),),
          SizedBox(height: 20,),
          SizedBox(height: 22,),
         GestureDetector(child: Row(
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
          onTap: (){
            setLocation = 0;
              AppRoutes.push(context, SetLocation(0));
        
         },),
           SizedBox(height: 10,),
           BrandDivider(),
           SizedBox(height: 16,),
         GestureDetector(onTap:(){
            setLocation = 1;
             AppRoutes.push(context, SetLocation(1));
         } ,child: 
         
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
            ],)
         ),
          SizedBox(height: 10,),
          BrandDivider(),
           SizedBox(height: 16,),
         GestureDetector(onTap:(){
            setLocation = 2;
             AppRoutes.push(context, SetLocation(2));
         } ,child: 
         
          Row(
            children: [
              Icon(Icons.add,color: Colors.black54,),
              SizedBox(width: 12,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(other==null?'Add Other':other),
                  SizedBox(height: 3,),
                  Text('Your custom address',
                    style:TextStyle(fontSize: 11,color:Colors.black38))
                ],)
            ],),

         ),
          SizedBox(height: 10,),
          BrandDivider(),
          ],
      ),
   )
      );
  }
getLocations(){
    DatabaseReference updateRef = FirebaseDatabase.instance.reference().child('users/${currentUserInfo.id}/place/0');
           updateRef.once().then(( DataSnapshot event) async {
           setState(() {
               home = event.value["placeName"];
           });

           });
    DatabaseReference updateRef1 = FirebaseDatabase.instance.reference().child('users/${currentUserInfo.id}/place/1');
           updateRef1.once().then(( DataSnapshot event) async {
             setState(() {
               work = event.value["placeName"];
             });

           });     
    DatabaseReference updateRef2 = FirebaseDatabase.instance.reference().child('users/${currentUserInfo.id}/place/2');
           updateRef2.once().then(( DataSnapshot event) async {
            setState(() {
               other = event.value["placeName"];
            });

           });  
}

}