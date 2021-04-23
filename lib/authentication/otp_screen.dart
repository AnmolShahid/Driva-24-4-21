import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/authentication/verified.dart';
import 'package:flutter_app/customer_ui/bar_drawer.dart';
import 'package:flutter_app/utilities/customer_buttons.dart';
import 'package:flutter_app/utilities/header_footer.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';

import 'dart:async';

import 'package:flutter_app/push_notification_service.dart';


class OTPScreenClass extends StatefulWidget {
  @override
  _OTPScreenClassState createState() => _OTPScreenClassState();
}

class _OTPScreenClassState extends State<OTPScreenClass> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var codeController = TextEditingController();
  int _otpCodeLength = 6;
  bool _isLoadingButton = false;
  bool _enableButton = false;
  String _otpCode = "";
void showSnackBar(String title){
  final snackBar = SnackBar(content: Text(title,textAlign: TextAlign.center,style: TextStyle(fontSize: 15),),);
  _scaffoldKey.currentState.showSnackBar(snackBar);
}

  /// get signature code
  _getSignatureCode() async {
    String signature = await SmsRetrieved.getAppSignature();
    print("signature $signature");
  }
  @override
  void initState() {
    super.initState();
    _getSignatureCode();
  }

   _verifyOtpCode() {
    FocusScope.of(context).requestFocus(new FocusNode());
    Timer(Duration(milliseconds: 4000), () {
      setState(() {
        _isLoadingButton = false;
        _enableButton = false;
      });

      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text("Verification OTP Code $_otpCode Success")));
    });
  }

  _onOtpCallBack(String otpCode, bool isAutofill) {
    setState(() {
      this._otpCode = otpCode;
      if (otpCode.length == _otpCodeLength && isAutofill) {
        _enableButton = false;
        _isLoadingButton = true;
        _verifyOtpCode();
        verifyPress();
      } else if (otpCode.length == _otpCodeLength && !isAutofill) {
         verifyPress();
        _enableButton = true;
        _isLoadingButton = false;
      } else {
        _enableButton = false;
      }
    });
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
              SizedBox(height: 20,),
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
      margin: EdgeInsets.only( bottom: 20),
      width: MediaQuery.of(context).size.width*.8,
      child: Column(
        children: [
          /* TextFieldPin(
                  filled: true,
                  filledColor: Colors.grey,
                  codeLength: 6,
                  boxSize: 36,
                  filledAfterTextChange: false,
                  textStyle: TextStyle(fontSize: 12),
                  borderStyle: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(24)),
                  onOtpCallback: (code, isAutofill) =>
                      _onOtpCallBack(code, isAutofill),
                ),
                */
     Container(
            margin: EdgeInsets.only( bottom: 20),
            child: TextFormField(
              controller: codeController,
              onEditingComplete: verifyPress,
             

              decoration: InputDecoration(
                hintText: '--  --  --  --  --  --',
                hintStyle: TextStyle(color: lightGray, fontSize: 20),
              ),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.phone,
            ),
          ),
SizedBox(height: 20,),
          GestureDetector(
            child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Didn't get a code?",style: TextStyle(color: DarkGray)),
              Text('Try Again', style: TextStyle(color: primaryColor),)
            ],
          ),onTap: () async {
           await resendCode();
             
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
PhoneAuthCredential phoneAuthCredential;
try{
    // Create a PhoneAuthCredential with the code
  phoneAuthCredential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
 showSnackBar('Please wait');
}catch(e){
  showSnackBar('Kindly use another number');
}

   try{
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: constant_email,
    password: constant_phone
  ).then((value) {

  }).catchError((e) {
          
  showSnackBar('Kindly use another email\n${e}');
            print(e);
       });
User user = FirebaseAuth.instance.currentUser;
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users/${user.uid}');
  
   
      PushNotificationService p = PushNotificationService();           
       
  var token = await p.getToken();       
              
  Map userMap = {
    'username':constant_name,
    'email':constant_email,
    'phone':constant_phone,
    'role':0,
    'tag':0,
    'status':0,
    'uid':user.uid,
    'phonelink':0,
    'emaillink':0,
    'displayImage':'https://cdn2.iconfinder.com/data/icons/ios-7-icons/50/user_male2-512.png',
    'feedback':0.0,
    'token':token

    
  };

  
  
    // Sign the user in (or link) with the credential
    await FirebaseAuth.instance.currentUser.linkWithCredential(phoneAuthCredential).then((value){
      if(value.user!=null){
          databaseReference.set(userMap);
          AppRoutes.makeFirst(context, VerifiedScreenClass());
      }else{
        showSnackBar('Invalid code');
      }
    });
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
