import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/authentication/loging.dart';
import 'package:flutter_app/customer_ui/cust_my_profile.dart';
import 'package:flutter_app/utilities/brandDivider.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'package:flutter_app/utilities/customer_buttons.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'add_locations.dart';
import 'bar_drawer.dart';

import 'set_country.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool editProfile = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      //drawer: CusDrawerPage(context),
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight), // here the desired height
          child: CusAppBarClass( context, 'Settings', false,_scaffoldKey) ),

      body: SingleChildScrollView(

        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            GestureDetector(
              child: Container(
      margin: EdgeInsets.only(top: 15, bottom: 15),
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 0),
     
      width: MediaQuery.of(context).size.width,
      child: Row(
      
        children: [
                Icon(Icons.verified_user_outlined,color: lightGray,),
                SizedBox(width: 12,),
                Text('Profile', style: TextStyle(fontSize: 18, color: lightGray),)
              
          
        ],
      ),
    ),
  onTap: (){
   
       AppRoutes.push(context, CustomerPrfileClass());
    
  },
            ),
   constant_role==0?          BrandDivider():SizedBox(),
  constant_role==0? GestureDetector(
     child:Container(
      margin: EdgeInsets.only(top: 15, bottom: 15),
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 0),
     
      width: MediaQuery.of(context).size.width,
      child: Row(
      
        children: [
                Icon(Icons.payment_outlined,color: lightGray,),
                SizedBox(width: 12,),
                Text('Select Country and Currency', style: TextStyle(fontSize: 18, color: lightGray),)
              
          
        ],
      ),
    ),
   onTap: (){
     AppRoutes.makeFirst(context, SetCountry());
                         
                         
    
   },
   ):SizedBox(),
   constant_role==0? BrandDivider():SizedBox(),
   constant_role==0?GestureDetector(
     child:Container(
      margin: EdgeInsets.only(top: 15, bottom: 15),
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 0),
     
      width: MediaQuery.of(context).size.width,
      child: Row(
      
        children: [
                Icon(Icons.location_history,color: lightGray,),
                SizedBox(width: 12,),
                Text('Add Locations', style: TextStyle(fontSize: 18, color: lightGray),)
              
          
        ],
      ),
    ),
   onTap: (){
     
     AppRoutes.makeFirst(context, AddLocation());                    
    
   },
   ):SizedBox(),
   
  
           BrandDivider(),
    Container(
      margin: EdgeInsets.only(top: 15, bottom: 15),
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 0),
     
      width: MediaQuery.of(context).size.width,
      child: Row(
      
        children: [
                Icon(Icons.call_to_action_outlined,color: lightGray,),
                SizedBox(width: 12,),
                Text('Emergency Contacts', style: TextStyle(fontSize: 18, color: lightGray),)
              
          
        ],
      ),
    ),
    BrandDivider(),
   GestureDetector(
     child:Container(
      margin: EdgeInsets.only(top: 15, bottom: 15),
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 0),
     
      width: MediaQuery.of(context).size.width,
      child: Row(
      
        children: [
                Icon(Icons.login_outlined,color: lightGray,),
                SizedBox(width: 12,),
                Text('Logout', style: TextStyle(fontSize: 18, color: lightGray),)
              
          
        ],
      ),
    ),
   onTap: (){
      FirebaseAuth.instance.signOut().whenComplete((){
                            login=false;
                             AppRoutes.makeFirst(context, LogingClass());
                          });
                         
    
   },
   )


          ],
        ),
      ),

    );
  }


}
