import 'package:firebase_database/firebase_database.dart';

class Drivers{
  String id;
  String username;
  String email;
  String displayImage;
  String phone;
  int role;
  int status;
  int tag;
  String newtrip;


  Drivers({
    this.id,
    this.username,
    this.email,
    this.displayImage,
    this.phone,
    this.role,
    this.status,
    this.tag,
    this.newtrip

  });

  Drivers.fromSnapshot(DataSnapshot snapshot){
    id = snapshot.key;
    phone = snapshot.value['phone'];
    email = snapshot.value['email'];
    username = snapshot.value['username'];
    displayImage = snapshot.value['displayImage'];
    role = snapshot.value['role'];
    status = snapshot.value['status'];
    tag = snapshot.value['tag'];
    newtrip = snapshot.value['newtrip'];
  }
}