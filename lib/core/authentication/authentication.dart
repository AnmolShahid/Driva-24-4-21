import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/core/authentication/authFuction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utilities/alert.dart';



   DBAuth _dbAuth;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(context,String email, String password) async {
    try{
    UserCredential user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
   if(user!=null){
     print('login');
   }else{
      print('error');
   }
    return user.toString();
    }catch(e){
       if(e.code.toString()=="ERROR_INVALID_EMAIL"){
   
   }else if(e.code.toString()=="ERROR_NETWORK_REQUEST_FAILED"){
     
   }else if(e.code.toString()=="ERROR_EMAIL_ALREADY_IN_USE"){
     
   }
   else{
    
   }
   Navigator.pop(context);
    }
  }

  Future<String> signUp(context,String email, String password,String name,String phone) async {
  try{
    UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
       if(user!=null){
          print('signup');
            _dbAuth.registration(name, email, password, phone);
        }else{
          print('error');
        }
    return user.toString();
    }catch(e){
       if(e.code.toString()=="ERROR_INVALID_EMAIL"){
     await alert(context:context,title: "Error", description: 'Email IS Invalid');
   }else if(e.code.toString()=="ERROR_NETWORK_REQUEST_FAILED"){
      await alert(context:context,title: "Error!", description: 'Internet Connection Error.');
   }else if(e.code.toString()=="ERROR_EMAIL_ALREADY_IN_USE"){
      await alert(context:context,title: "Error", description: 'This Email Already In Use.');
   }
   else{
      await alert(context:context,title: "Error", description: e.code.toString());
   }
   Navigator.pop(context);
    }
    
  }

  Future<User> getCurrentUser() async {
    User user = FirebaseAuth.instance.currentUser;
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

//-------------------------------------------------------- Forget Password----------------------------
@override
Future<void> resetPassword(context,String email) async {
   showDialog(
          context: context,
          builder: (BuildContext context) {
            return new Column(
              mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
         // Container(margin: EdgeInsets.only(left: 7),child:Text("Loading..." )),
        ]);
          });
  if(email==""){
 await alert(context:context,title: "Error", description: "Please add valid Email");
   Navigator.pop(context);
  }else{
    try{
     await alert(context:context,title: "Confirmation", description: "Reset password link as been sent to your email: "+email);
    await _firebaseAuth.sendPasswordResetEmail(email: email);
       Navigator.pop(context);
  } catch(e){
      await alert(title: "Error", description: e.message);
        Navigator.pop(context);
   
  }}
}
