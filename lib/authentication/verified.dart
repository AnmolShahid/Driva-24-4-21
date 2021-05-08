import 'dart:async';

import 'package:flutter_app/core/helper/helperMethod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/customer_ui/vehicle_registration.dart';
import 'package:flutter_app/customer_ui/bar_drawer.dart';
import 'package:flutter_app/utilities/customer_buttons.dart';
import 'package:flutter_app/utilities/header_footer.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'package:flutter_app/driver_ui/driver_home.dart';
import 'package:flutter_app/customer_ui/cust_home.dart';

class VerifiedScreenClass extends StatefulWidget {
  @override
  _VerifiedScreenClassState createState() => _VerifiedScreenClassState();
}

class _VerifiedScreenClassState extends State<VerifiedScreenClass> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whtColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight), // here the desired height
          child: CusAppBarClass( context,'Successfully Verified', false, _scaffoldKey) ),
      bottomNavigationBar: Container(
        height: 70,
        child: TermFooterClass(),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height-100,
        width: MediaQuery.of(context).size.width,
        child: bodyWidget(),


      ),
    );
  }


  Widget bodyWidget(){
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          CircleAvatar(
            backgroundColor: green,
            radius: 50,
            child: CircleAvatar(
              backgroundColor: whtColor,
              radius: 40,
              child: Icon(Icons.check, size: 70,color: green,),
            ),
          ),


          Text('\nVerified!\n', style: TextStyle(color: DarkGray, fontSize: 20, fontWeight: FontWeight.bold),),
           Text('You have successfully verified.',overflow: TextOverflow.visible,textAlign: TextAlign.center, style: TextStyle(color: DarkGray, fontSize: 15),),
          SizedBox(height: 10,),
      //    PrimaryButton(Heading: 'LOGIN NOW',onTap: buttonPress,),

        ],
      ),
    );
  }


  Future<void> buttonPress() async {
    await HelperMethods.getCurrentUSerInfo();
    if(constant_role==0){
     
        AppRoutes.replace(context, CareRegistrationClass());
      
         
    }else if(constant_role==1){
       AppRoutes.replace(context, DriverHomeClass());
    }
   
  }

@override
  void initState() {
     var _duration = Duration(seconds: 3);
     Timer(_duration, buttonPress);
    // TODO: implement initState
    super.initState();
  }

}
