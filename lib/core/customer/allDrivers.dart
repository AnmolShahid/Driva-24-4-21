

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/utilities/constant.dart';

void update_location(role){
  if(role==0){
    User user = FirebaseAuth.instance.currentUser;
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users/${user.uid}');
  Map userMap = {
    'username':constant_name,
    'email':constant_email,
    'phone':constant_phone,
    'role':0,
    'tag':0,
    'status':0,
    'uid':user.uid,
    'token':'',
    'phonelink':0,
    'emaillink':0,
    'displayImage':''
  };
  }else {
    User user = FirebaseAuth.instance.currentUser;
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users/${user.uid}');
  Map userMap = {
    'username':constant_name,
    'email':constant_email,
    'phone':constant_phone,
    'role':0,
    'tag':0,
    'status':0,
    'uid':user.uid,
    'token':'',
    'phonelink':0,
    'emaillink':0,
    'displayImage':''
  };
  }


}


void allDrivers(){

   DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users/');
      databaseReference.orderByChild("role").equalTo("1").once().then((DataSnapshot dataSnapshot) {
          if(dataSnapshot.value!=null){
          return dataSnapshot.value;
          }else{
          return false;
          }
      });
   
}

void getNearDriver(){
   DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users/');
      databaseReference.orderByChild("role").equalTo("1").once().then((DataSnapshot dataSnapshot) {
          if(dataSnapshot.value!=null){
          return dataSnapshot.value;
          }else{
          return false;
          }
      });
}