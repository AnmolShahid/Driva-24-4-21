import 'package:flutter/material.dart';
import 'package:flutter_app/authentication/otp_screen.dart';
import 'package:flutter_app/customer_ui/bar_drawer.dart';
import 'package:flutter_app/utilities/header_footer.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:country_code_picker/country_code_picker.dart';



class MobileNoFieldClass extends StatefulWidget {
  @override
  _MobileNoFieldClassState createState() => _MobileNoFieldClassState();
}

class _MobileNoFieldClassState extends State<MobileNoFieldClass> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whtColor,
      resizeToAvoidBottomPadding: false,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight), // here the desired height
          child: CusAppBarClass( context,'Sign Up', false, _scaffoldKey) ),
      bottomNavigationBar: Container(
        height: 70,
        child: TermFooterClass(),
      ),
      body: Container(
        child: Column(
          children: [
            HeaderClass(true),
            bodyWidget(),
          ],
        ),
      ),
    );
  }


  Widget bodyWidget(){
    return Container(
      width: MediaQuery.of(context).size.width*.8,
      child: Column(
        children: [
          numberInputField(),
          InkWell(
              onTap: (){
                AppRoutes.push(context, OTPScreenClass());
              },
              child: Container(
                margin: EdgeInsets.only(top: 20),
                height: authButtonHeight,
                width: MediaQuery.of(context).size.width*.8,
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(5)
                ),
                alignment: Alignment.center,
                child: Text('Continue', style: TextStyle(color: DarkGray, fontSize: 18),),
              )
          ),
          Text('\nYou should receive an SMS for verification. Message and data rate may apply',overflow: TextOverflow.visible,textAlign: TextAlign.center, style: TextStyle(color: DarkGray, fontSize: 13),),
        ],
      ),
    );
  }


  Widget numberInputField(){
    return Container(
      width: MediaQuery.of(context).size.width*.8,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: lightGray),
        borderRadius: BorderRadius.circular(5)
      ),
      child: Row(
        children: [
          CountryCodePicker(
            initialSelection: 'Pakistan',

          ),
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.phone,
              
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '(201) 555-5555',
                hintStyle: TextStyle(color: lightGray)
              ),
            ),
          )
        ],
      ),
    );
  }

}
