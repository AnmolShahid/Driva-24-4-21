import 'package:firebase_database/firebase_database.dart';

class Fare{
  String id;
  double base_fare;
  double time_fare;
  double distance_fare;


  Fare({
    this.id,
    this.base_fare,
    this.time_fare,
    this.distance_fare

  });

   Fare.fromSnapshot(DataSnapshot snapshot){
    id = snapshot.key;
    base_fare = snapshot.value['base_fare'];
    time_fare = snapshot.value['time_fare'];
    distance_fare = snapshot.value['distance_fare'];
    }
}