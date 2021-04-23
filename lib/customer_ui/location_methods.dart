import 'package:flutter/material.dart';
import 'package:flutter_app/utilities/utilities.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'bar_drawer.dart';
import 'package:flutter_app/customer_ui/searchpage.dart';
import 'package:flutter_app/utilities/brandDivider.dart';
import 'set_location.dart';
import 'package:flutter_app/utilities/constant.dart';



get_Savedplaces(){

  DatabaseReference updateRef2 = FirebaseDatabase.instance.reference().child('users/${currentUserInfo.id}/place');
           updateRef2.once().then(( DataSnapshot event) async {

              if(event.value!=null){

                return event.value;

              }else{

                return false;

              }

            });

}