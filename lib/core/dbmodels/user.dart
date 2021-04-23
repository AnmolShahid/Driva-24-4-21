import 'package:firebase_database/firebase_database.dart';

class Users{
  
  String id;
  String username;
  String email;
  String displayImage;
  String phone;
  int role;
  int status;
  int tag;
  String feedback;
  String token;
  String dob;


  Users({

    this.id,
    this.username,
    this.email,
    this.displayImage,
    this.phone,
    this.role,
    this.status,
    this.tag,
    this.token,
    this.feedback,
    this.dob,

  });

  Users.fromSnapshot(DataSnapshot snapshot){

    id = snapshot.key;
    phone = snapshot.value['phone'];
    email = snapshot.value['email'];
    username = snapshot.value['username'];
    displayImage = snapshot.value['displayImage'];
    role = snapshot.value['role'];
    status = snapshot.value['status'];
    tag = snapshot.value['tag'];
    feedback = snapshot.value['feedback'].toString();
    token = snapshot.value['token'];
    dob = snapshot.value['dob'];

  }
}