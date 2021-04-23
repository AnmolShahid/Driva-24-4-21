
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/utilities/constant.dart';



 getTripHistory(){

   DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('rideRequest/');
      databaseReference.orderByChild("rider_id").equalTo(currentUserInfo.id).once().then((DataSnapshot dataSnapshot) {
          if(dataSnapshot.value!=null){
          return dataSnapshot;
          }
      });
   
}