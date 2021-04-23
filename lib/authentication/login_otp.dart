import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/authentication/verified.dart';
import 'package:flutter_app/customer_ui/bar_drawer.dart';
import 'package:flutter_app/customer_ui/cust_home.dart';
import 'package:flutter_app/driver_ui/driver_home.dart';
import 'package:flutter_app/utilities/customer_buttons.dart';
import 'package:flutter_app/utilities/header_footer.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'package:flutter_app/utilities/utilities.dart';

import 'package:flutter_app/push_notification_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/utilities/constant.dart';



class OTPLo extends StatefulWidget {
  @override
  _OTPLoState createState() => _OTPLoState();
}

class _OTPLoState extends State<OTPLo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

      PushNotificationService p = PushNotificationService();
  var codeController = TextEditingController();

void showSnackBar(String title){
  final snackBar = SnackBar(content: Text(title,textAlign: TextAlign.center,style: TextStyle(fontSize: 15),),);
  _scaffoldKey.currentState.showSnackBar(snackBar);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: whtColor,
      appBar: PreferredSize(
        
          preferredSize: Size.fromHeight(appBarHeight), // here the desired height
          child: AppBar(
                backgroundColor: primaryColor,
                elevation: 0,
                automaticallyImplyLeading: false,
                title:  Text('Code Sent', style: TextStyle(fontSize:15, color: whtColor),),
                centerTitle: true,
              ), ),
      bottomNavigationBar: Container(
        height: 70,
        child: TermFooterClass(),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          //height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              HeaderClass(true),
              headerText(),
              verificationWidget(),

              // space container only

            ],
          ),
        ),
      )
    );
  }

  Widget headerText(){
    return Container(
      child: Column(
        children: [
          Text('Verify Code', style: TextStyle(color: DarkGray, fontSize: 20, fontWeight: FontWeight.bold),),
          Text('Please check your SMS\nWe just sent a verification code on your phone\n'+constant_phone,textAlign: TextAlign.center, style: TextStyle(color: DarkGray, fontSize: 15),),
        ],
      ),
    );
  }


  Widget verificationWidget(){
    return Container(
      width: MediaQuery.of(context).size.width*.8,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only( bottom: 20),
            child: TextFormField(
              controller: codeController,
              decoration: InputDecoration(
                hintText: '--  --  --  --  --  --',
                hintStyle: TextStyle(color: lightGray, fontSize: 20),
              ),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.phone,
            ),
          ),

          GestureDetector(
            child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Didn't get a code?",style: TextStyle(color: DarkGray)),
              Text('Try Again', style: TextStyle(color: primaryColor),)
            ],
          ),onTap: () async {
            resendCode();
              
          },
          ),
          //SizedBox(height: 10,),
          PrimaryButton(Heading: 'VERIFY',onTap: verifyPress,),
        ],
      ),
    );
  }

Future<void> resendCode() async {
   await FirebaseAuth.instance.verifyPhoneNumber(
  phoneNumber: constant_phone,
  verificationCompleted: (PhoneAuthCredential credential) {},
  verificationFailed: (FirebaseAuthException e) {},
  codeSent: (String verificationId, int resendToken) {},
  codeAutoRetrievalTimeout: (String verificationId) {},
);
}

  Future<void> verifyPress() async {
    showSnackBar('Please wait');
 await FirebaseAuth.instance.verifyPhoneNumber(
  phoneNumber: constant_phone,
  verificationCompleted: (PhoneAuthCredential credential) {
    
  },
  verificationFailed: (FirebaseAuthException e) {
     showSnackBar(e.message);
  },
  codeSent: (String verificationId, int resendToken) async {
        // Update the UI - wait for the user to enter the SMS code
    String smsCode = codeController.text;

    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
 showSnackBar('Please wait');
 

try{
        final AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );
        final User user = (await FirebaseAuth.instance.signInWithCredential(credential)).user;
   constant_login=false;
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users/${user.uid}');
  
      PushNotificationService p = PushNotificationService();
              
       
  var token = await p.getToken();       


    if(constant_role==0){
     
        AppRoutes.replace(context, CustomerHomeClass());
      
         
    }else if(constant_role==1){
       AppRoutes.replace(context, DriverHomeClass());
    }
}catch (e){
      showSnackBar(e.toString());
   }
 
 
  },
   
  codeAutoRetrievalTimeout: (String verificationId) {
    // Auto-resolution timed out...
  },
);

   
  }

}
