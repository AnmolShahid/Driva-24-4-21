import 'package:connectivity/connectivity.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/authentication/login_otp.dart';
import 'package:flutter_app/authentication/otp_screen.dart';
import 'package:flutter_app/core/authentication/authentication.dart';
import 'package:flutter_app/driver_ui/driver_home.dart';
import 'package:flutter_app/utilities/alert.dart';
import 'package:flutter_app/utilities/customer_buttons.dart';
import 'package:flutter_app/utilities/header_footer.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'package:flutter_app/customer_ui/cust_home.dart';

class LogingClass extends StatefulWidget {
  @override
  _LogingClassState createState() => _LogingClassState();
}

class _LogingClassState extends State<LogingClass> {

final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();


  bool login = true;

  var usernameController = TextEditingController();

  var passwordController = TextEditingController();

  var emailController = TextEditingController();

  var phoneController = TextEditingController();

  var confirmPasswordController = TextEditingController();

  String countryCode;

void showSnackBar(String title){
  final snackBar = SnackBar(content: Text(title,textAlign: TextAlign.center,style: TextStyle(fontSize: 15),),);
  scaffoldKey.currentState.showSnackBar(snackBar);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
    resizeToAvoidBottomInset: true,
        bottomNavigationBar: Container(
          height: 70,
          child: TermFooterClass(),
        ),
    body: SingleChildScrollView(
      physics: BouncingScrollPhysics(),

      child: Container(
       // height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,

        child: Column(
          children: [
            HeaderClass(login),
           //loggingButton(),
           login? logInWidget():signUpWidget(),
          ],
        ),
      ),
    )

    );
  }



  Widget loggingChange(){
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(login?"Don't have an account ":"Have an account ", style: TextStyle(fontSize: 15, color: lightGray),),
          GestureDetector(
            child: Container(

              decoration: BoxDecoration(
              ),
              child: Text(login?"SignUP":"LogIn", style: TextStyle(fontSize: 15, color: primaryColor),),
            ),
            onTap:(){
              setState(() {
                login=!login;
              });
            } ,
          )
        ],
      ),
    );
  }

  Widget logInWidget(){
    return Container(
      //color: lightGray,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
               Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width*.8,
      child: Row(
       
        children: [
         
          Icon(Icons.phone, color: lightGray,),
          CountryCodePicker(
         onChanged:(e){
           countryCode=e.dialCode;
         },
         showFlag: false,
         // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
         initialSelection: 'QA',
         favorite: ['+974','QA'],
         // optional. Shows only country name and flag
         showCountryOnly: false,
         // optional. Shows only country name and flag when popup is closed.
         showOnlyCountryWhenClosed: false,
        
       ),
          Expanded(
            child: TextFormField(
              controller: phoneController,
              
              keyboardType:TextInputType.numberWithOptions(),
              decoration: InputDecoration(
                hintText: 'Phone',
                hintStyle: TextStyle(color: lightGray),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10, bottom: 0)
              ),
              style: TextStyle(fontSize: 18, color: lightGray),

            ),
          ),

          

        ],
      ),
    ),
         
   /*         Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width*.8,
      child: Row(
        children: [
         
          Icon(Icons.mail_outline, color: lightGray,),
          Expanded(
            child: TextFormField(
              controller: emailController,
              keyboardType:TextInputType.emailAddress,
              
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(color: lightGray),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10, bottom: 0)
              ),
              style: TextStyle(fontSize: 18, color: lightGray),

            ),
          ),

          

        ],
      ),
    ),
          Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width*.8,
      child: Row(
        children: [
         
          Icon(Icons.lock_outline, color: lightGray,),
          Expanded(
            child: TextFormField(
              controller: passwordController,
              keyboardType:TextInputType.text,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(color: lightGray),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10, bottom: 0)
              ),
              style: TextStyle(fontSize: 18, color: lightGray),

            ),
          ),

          

        ],
      ),
    ),
   */
   // forgotPassword(),
          PrimaryButton(Heading: 'LOG IN', onTap:()
          {

           validationPhone(countryCode+phoneController.text);
          } ,),
          loggingChange()
        ],
      ),
    );
  }

  Widget forgotPassword(){
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*.1,),
      margin: EdgeInsets.only(top: 10, bottom: 0),
      child: GestureDetector(
        onTap: (){
       //   AppRoutes.replace(context, DriverHomeClass());
        },
        child: Text('Forgot Password?', style: TextStyle(fontSize: 13, color: lightGray),),
      ),
    );
  }




  Widget socialButtons(){
    return Container(
      child: Column(
        children: [
          // FACEBOOK BUTTON
        InkWell(
        onTap:(){

        },
        child: Container(
          margin: EdgeInsets.only(top: 10),
          height: appBarHeight,
          width: MediaQuery.of(context).size.width*.8,
          decoration: BoxDecoration(
              color: blueColor,
              borderRadius: BorderRadius.circular(5)
          ),
          alignment: Alignment.center,
          child: Text('CONTINUE WITH FACEBOOK', style: TextStyle(color: whtColor, fontSize: 18),),
        ),
      ),
          // GOOGLE BUTTON
          InkWell(
            onTap:(){

            },
            child: Container(
              margin: EdgeInsets.only(top: 10),
              height: authButtonHeight,
              width: MediaQuery.of(context).size.width*.8,
              decoration: BoxDecoration(
                  color: whtColor,
                  borderRadius: BorderRadius.circular(5),
                border: Border.all(width: 1, color: lightGray)
              ),
              alignment: Alignment.center,
              child: Text('CONTINUE WITH GOOGLE', style: TextStyle(color: lightGray, fontSize: 18),),
            ),
          ),
        ],
      ),
    );
  }

  Widget signUpWidget(){
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width*.8,
      child: Row(
        children: [
         
          Icon(Icons.person_outline, color: lightGray,),
          Expanded(
            child: TextFormField(
              controller: usernameController,
              keyboardType:TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Enter First and Last Name',
                hintStyle: TextStyle(color: lightGray),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10, bottom: 0)
              ),
              style: TextStyle(fontSize: 18, color: lightGray),

            ),
          ),

          

        ],
      ),
    ),
         Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width*.8,
      child: Row(
        children: [
         
          Icon(Icons.mail_outline, color: lightGray,),
          Expanded(
            child: TextFormField(
              controller: emailController,
              keyboardType:TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(color: lightGray),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10, bottom: 0)
              ),
              style: TextStyle(fontSize: 18, color: lightGray),

            ),
          ),

          

        ],
      ),
    ),
              Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width*.8,
      child: Row(
       
        children: [
         
          Icon(Icons.phone, color: lightGray,),
          CountryCodePicker(
         onChanged:(e){
           countryCode=e.dialCode;
         },
         showFlag: false,
         // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
         initialSelection: 'QA',
         favorite: ['+974','QA'],
         // optional. Shows only country name and flag
         showCountryOnly: false,
         // optional. Shows only country name and flag when popup is closed.
         showOnlyCountryWhenClosed: false,
        
       ),
          Expanded(
            child: TextFormField(
              controller: phoneController,
              keyboardType:TextInputType.numberWithOptions(),
              decoration: InputDecoration(
                hintText: 'Phone',
                hintStyle: TextStyle(color: lightGray),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10, bottom: 0)
              ),
              style: TextStyle(fontSize: 18, color: lightGray),

            ),
          ),

          

        ],
      ),
    ),
         Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width*.8,
      child: Row(
        children: [
         
          Icon(Icons.lock_outline, color: lightGray,),
          Expanded(
            child: TextFormField(
              controller: passwordController,
              keyboardType:TextInputType.text,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(color: lightGray),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10, bottom: 0)
              ),
              style: TextStyle(fontSize: 18, color: lightGray),

            ),
          ),

          

        ],
      ),
    ),
             Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width*.8,
      child: Row(
        children: [
         
          Icon(Icons.lock_outline, color: lightGray,),
          Expanded(
            child: TextFormField(
              controller: confirmPasswordController,
              keyboardType:TextInputType.text,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Confirm Password',
                hintStyle: TextStyle(color: lightGray),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10, bottom: 0)
              ),
              style: TextStyle(fontSize: 18, color: lightGray),

            ),
          ),

          

        ],
      ),
    ),
//SizedBox(height: 20,),
          PrimaryButton( Heading: 'SIGN UP',onTap: () async {
            

           await signUpValidation(usernameController.text,emailController.text,countryCode+phoneController.text,passwordController.text,confirmPasswordController.text);
           
          },),
          loggingChange()
        ],
      ),
    );
  }
void checkConnectivity()async{

  var connectivityResult = await (Connectivity().checkConnectivity());
if (connectivityResult != ConnectivityResult.mobile ||connectivityResult == ConnectivityResult.wifi) {
    showSnackBar('Internet is not Connected.');
}
}
void loginViaPhone(String number){


    
          DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users/');
      databaseReference.orderByChild("phone").equalTo(constant_phone).once().then((DataSnapshot dataSnapshot) {
          if(dataSnapshot.value!=null){
            Map<dynamic, dynamic> values = dataSnapshot.value;
            values.forEach((key,values) {
              constant_role=values["role"];
            });
             constant_phone = number;
             
              login=true;
            phoneVerificationLogin(number);
           
          }else{
            showSnackBar('This contact is not registered. Please signup.'); 
          }
      });
    

}
  void loginFunc(email,password) async {
     try{
    UserCredential user = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).catchError((e){
     
      showSnackBar(e.message);
    }));
   if(user!=null){
     print('login');
 showSnackBar('Please Wait...!');
       DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users/${user.user.uid}');
      databaseReference.once().then((DataSnapshot dataSnapshot) {
          if(dataSnapshot.value!=null){
            print(dataSnapshot.value.toString());
            constant_phone = dataSnapshot.value['phone'];
            constant_role =  dataSnapshot.value['role'];
            constant_uid = dataSnapshot.value['uid'];
            showSnackBar('Almost Done...!');
          //  phoneVerification(dataSnapshot.value['phone']);
           if(constant_role==0){
                   AppRoutes.makeFirst(context, CustomerHomeClass());
              }else{
                AppRoutes.replace(context, DriverHomeClass());
              }
          }
      });
    // phoneVerification(phone);
    
   }else{
      print('error');
   }
   
    }catch(e){
       showSnackBar(e.message);
     
  
    }
      

    
  }
  void signUpValidation(String username,String email,String phone,String password,String confirmPassword){
//checkConnectivity();
     if (password!=confirmPassword){
        showSnackBar('Mismatch Password');
    }else if(!email.contains('@')){
      showSnackBar('Please enter valid email.');
    }else if (phone.length<10){
        showSnackBar('Invalid phone number');
    } else
    if(username==null||username==""){
       showSnackBar('Please Enter Username');
    }else if (username.length<3){
      showSnackBar('Please Enter Valid Username');
    }else if (email==null||email==""){
       showSnackBar('Please Enter Email');
    }else if (phone==null||phone==""){
       showSnackBar('Please Enter Phone');
    }else if (password==null||password==""){
       showSnackBar('Please Enter Password');
    }else{
    showSnackBar('Please Wait...!');
     DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users/');
      databaseReference.orderByChild("phone").equalTo(phone).once().then((DataSnapshot dataSnapshot) {
          if(dataSnapshot.value!=null){
           showSnackBar('Phone number is already in use');
          }else{
            signUpFunc(email,password,username,phone);
          }
      });
   
    }

    
  }

  void validationForm(String email,String password){
   // checkConnectivity();
    if(email==null||email==""){
      showSnackBar('Please Enter Email');
    }else if (password==null||password==""){
      showSnackBar('Please Enter Password');
    }else if(!email.contains('@')){
      showSnackBar('Please enter valid email.');
    }else{
    showSnackBar('Please wait...!');
    loginFunc(email,password);


    }
}
void validationPhone(String number){
   // checkConnectivity();
    if(number==null||number==""){
      showSnackBar('Please Enter Your Contact Number');
    }else if (number.length<10){
        showSnackBar('Invalid phone number');
    }else{
    showSnackBar('Please wait...!');
    constant_phone = number;
    constant_login = true;
    loginViaPhone(number);


    }
}

  void phoneVerification(String phone) async {
   await FirebaseAuth.instance.verifyPhoneNumber(
  phoneNumber: phone,
  verificationCompleted: (PhoneAuthCredential credential) {
    print('j');
     
   
  },
  verificationFailed: (FirebaseAuthException e) {
    showSnackBar(e.message);
    print(e);
  },
  codeSent: (String verificationId, int resendToken)async {
    print('code sent');
    showSnackBar('Code Sent');
   AppRoutes.makeFirst(context, OTPScreenClass());
  },
  codeAutoRetrievalTimeout: (String verificationId) {},
);
}

  Future<void> signUpFunc(email,password,String name,String phone) async {

    try {
    showSnackBar('Please Wait');
 

 phoneVerification(phone);
constant_phone = phone;
constant_name = name;
constant_email = email;
constant_role=0;
  showSnackBar('Please Wait');
 

 
} on FirebaseAuthException catch (e) {
  showSnackBar(e.message);
 

} catch (e) {
  showSnackBar(e.maessage);
  
}
   
  }


  void phoneVerificationLogin(String phone) async {
   await FirebaseAuth.instance.verifyPhoneNumber(
  phoneNumber: phone,
  verificationCompleted: (PhoneAuthCredential credential) {
    print('j');
     
   
  },
  verificationFailed: (FirebaseAuthException e) {
    showSnackBar(e.message);
    print(e);
  },
  codeSent: (String verificationId, int resendToken) async {
    print('code sent');
    showSnackBar('Code Sent');
   AppRoutes.makeFirst(context, OTPLo());
  },
  codeAutoRetrievalTimeout: (String verificationId) {},
);
}

}
