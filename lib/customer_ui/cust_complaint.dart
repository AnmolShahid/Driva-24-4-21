import 'package:flutter/material.dart';
import 'package:flutter_app/utilities/customer_buttons.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'bar_drawer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'dart:async';
import 'package:flutter_app/customer_ui/cust_trip_history.dart';
class CustomerComplaintClass extends StatefulWidget {
  @override
  _CustomerComplaintClassState createState() => _CustomerComplaintClassState();
}

class _CustomerComplaintClassState extends State<CustomerComplaintClass> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
void showSnackBar(String title){
  final snackBar = SnackBar(content: Text(title,textAlign: TextAlign.center,style: TextStyle(fontSize: 15),),);
  _scaffoldKey.currentState.showSnackBar(snackBar);
}
  // Drop Down Item Value
  int _value = 1;

  String fromComplaint;

  String toComplaint;

  var detail = TextEditingController() ;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      //drawer: CusDrawerPage(context),
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight), // here the desired height
          child: CusAppBarClass( context, 'Trip Detail', false,_scaffoldKey) ),

      body:SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
           //  mapImage(),
              Container(
                margin: EdgeInsets.only(top: 20, bottom: 20),
                child: Text('Complaint/Report', style: TextStyle(color: DarkGray, fontSize: 22, fontWeight: FontWeight.bold),),
              ),
              complaintWidget()
            ],
          ),
        ),
      ),

    );
  }


  Widget mapImage(){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height*.25,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/map.png',),fit: BoxFit.fill
          )
      ),
    );
  }


  Widget complaintWidget(){
    return Container(
      width: MediaQuery.of(context).size.width*.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width*.8,
            height: 50,
            child: DropdownButton(
                style: TextStyle(fontWeight: FontWeight.w500, color: DarkGray, fontSize: 18),
                elevation: 15,
                isExpanded: true,

                value: _value,
                items: [
                  DropdownMenuItem(
                    child: Text(constant_role==0?"Complaint Type":"Accident"),
                    value: 1,
                  ),
                  DropdownMenuItem(
                    child: Text(constant_role==0?"Lost Mobile":"Payment"),
                    value: 2,
                  ),
                  DropdownMenuItem(
                      child: Text(constant_role==0?"Lost Wollet":"Customer"),
                      value: 3
                  ),
                  DropdownMenuItem(
                      child: Text("Other"),
                      value: 4
                  )
                ],
                onChanged: (value) {
                  setState(() {
                    _value = value;
                  });
                }),
          ),
          SizedBox(height: 30,),
          Text('Message',textAlign: TextAlign.start, style: TextStyle(fontWeight: FontWeight.w500, color: DarkGray, fontSize: 18),),
    Container(
    margin: EdgeInsets.only(top: 15, bottom: 5),
    padding: EdgeInsets.only(left: 5, right: 5),
    decoration: BoxDecoration(
    border: Border(bottom: BorderSide(width: 1, color: lightGray))
    ),
    width: MediaQuery.of(context).size.width*.8,
    child:TextFormField(
      controller: detail,
      decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(left: 10, bottom: 0)
      ),
      style: TextStyle(fontSize: 18, color: DarkGray),
      maxLines: 5,
         ),
     ),
          SizedBox(height: 20,),
          PrimaryButton(Heading: 'Submit',onTap: (){
            if(constant_role==0){
              fromComplaint = tripHistory[0].rider_id;
              toComplaint =   tripHistory[0].driver_id;
              
            }else if(constant_role==1){
              toComplaint = tripHistory[0].rider_id;
              fromComplaint =   tripHistory[0].driver_id;
            }

             DatabaseReference feedbackReference = FirebaseDatabase.instance.reference().child('complaint').push();
               feedbackReference.child("title").set(_value);
              feedbackReference.child("detail").set(detail.text);
              feedbackReference.child("date").set(DateTime.now().toString());
              feedbackReference.child("status").set(0);
              feedbackReference.child("refund").set(0);
              feedbackReference.child("tag").set(0);
              feedbackReference.child("fromComplaint").set(fromComplaint);
              feedbackReference.child("toComplaint").set(toComplaint);
              feedbackReference.child("trip").set(tripHistory[0]);

             

          showSnackBar('Complaint created. We will notify you soon.');
           var _duration = Duration(seconds: 2);
           Timer(_duration, navigate);
         
          },)
        ],
      ),
    );
  }

navigate(){
    DatabaseReference rideRef = FirebaseDatabase.instance.reference().child('rideRequest/${tripHistory[0].tripID}');
   
            if(constant_role==0){
             rideRef.child("complaintByCustomer").set(1);
            }else if(constant_role==1){
              rideRef.child("complaintByDriver").set(1);
            }
 AppRoutes.replace(context, CustomerTripHistoryClass());

}
}
