import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:flutter_app/driver_ui/driver_home.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';


class CustomerBillCalculationClass extends StatefulWidget {
  final trip_id, driver_id;
  CustomerBillCalculationClass(String trip_id,String driver_id):this.trip_id = trip_id,this.driver_id = driver_id;

  @override
  _CustomerBillCalculationClassState createState() => _CustomerBillCalculationClassState();
  
}

class _CustomerBillCalculationClassState extends State<CustomerBillCalculationClass> {
  TextEditingController ammountController = TextEditingController();
  bool other = false;

  int displayDetails=0;

  double feedback = 3.0;

  var trip_id;
  var driver_id;

  var driver_feed;
@override
  void initState() {
    // TODO: implement initState
    super.initState();

    trip_id = widget.trip_id;
    driver_id = widget.driver_id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              billShowBox(),
            GestureDetector(
            onTap:submitPress,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              margin: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                color: primaryColor,
                  border: Border.all(width: 1, color: primaryColor),
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Text( 'Add Trip Review', style: TextStyle(color: whtColor, fontWeight: FontWeight.w500),),
            ),
          )

            ],
          ),
        ),
      )
    );
  }

Widget billShowBox(){
    return Container(
      width: MediaQuery.of(context).size.width,
      height:MediaQuery.of(context).size.height*.5,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*.12,),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: lightGray, blurRadius: 5, spreadRadius: 5)],
        color: primaryColor,
        borderRadius: BorderRadius.circular(5)
      ),
      child:
      
       Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(child:Text('')),
          Expanded(
           
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               Container(
              alignment: Alignment.center,
              child: Text('${allDrivers[0].username} \n\n QAR ${estimatedFare[0].total_EstimatedFare}',overflow: TextOverflow.visible, style: TextStyle(color: whtColor, fontSize: 25, fontWeight: FontWeight.w600),),
            ),
            displayDetails==1? Container(
              alignment: Alignment.center,
              
              child: Text('\n\n    Estimated Time: ${tripDirectionDetails.durationText}\n    Estimated Distance: ${tripDirectionDetails.distanceText}\n     Estimated Base Fare: QAR ${estimatedFare[0].base_EstimatedFare}\n     Estimated Time Fare: QAR ${estimatedFare[0].time_EstimatedFare}\n     Estimated Distance Fare: QAR ${estimatedFare[0].distance_EstimatedFare.truncate()}\n\n     Total Estimated Fare: QAR ${estimatedFare[0].total_EstimatedFare}',overflow: TextOverflow.visible,textAlign: TextAlign.left, style: TextStyle(color: whtColor, fontSize: 16, ),),
            ) 
            :
            Container(child: Text(''),) 


            ],)),
           displayDetails==0? 
           Container(
             padding: EdgeInsets.all(10),
            alignment: Alignment.bottomRight,
            child: FlatButton(
              child:Text('Complete Detail',
              style: TextStyle(
                color: whtColor,
                 fontSize: 16,
                 ),),onPressed: (){
                     setState(() {
                        displayDetails=1;
                     });
          },),
       )
       :
       Container(child: Text(''),) 
         
      ],
      )
      );
  }

  Widget paymentButtons(){
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(child: GestureDetector(
            onTap: collectAccurate,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              margin: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: primaryColor),
                borderRadius: BorderRadius.circular(5)
              ),
              child: Text('QR 40.00', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500),),
            ),
          )),

          Expanded(child: GestureDetector(
            onTap:other?submitPress : otherPress,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              margin: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                color: primaryColor,
                  border: Border.all(width: 1, color: primaryColor),
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Text( other? 'Submit':'OTHER', style: TextStyle(color: whtColor, fontWeight: FontWeight.w500),),
            ),
          ))
        ],
      ),
    );
  }


  Widget otherInputField(){
    return Container(
      height: 50,
      padding: EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: primaryColor),
        borderRadius: BorderRadius.circular(5)
      ),
      child: TextFormField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Please enter ammount',
          hintStyle: TextStyle(color: lightGray),
          counter: SizedBox()
        ),
        maxLength: 5,
        keyboardType: TextInputType.phone,
        controller: ammountController,
      ),
    );
  }


  void dialogBoxratting(){
    showDialog(context: context,
        //barrierDismissible: false,
        builder: (BuildContext context){
          return
            AlertDialog(
              backgroundColor: whtColor,
              titlePadding: EdgeInsets.all(10),
              title: CachedNetworkImage(
  imageUrl:  driver_img,
  imageBuilder: (context, imageProvider) => Container(
    height: 90,
                          width: 90,
                        // color: Colors.white

                     
                     decoration: new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      
      
      image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
         ),
    ),
  ),
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
),
                    
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('How was the trip with ${allDrivers[0].username}?', textAlign: TextAlign.center,),
                  SizedBox(height: 10,),
                  RatingBar.builder(
                    initialRating: 3,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemSize: 30.0,
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      print(rating);
                     setState(() {
                        feedback = rating;
                     });
                    },
                  ),

                ],
              ),
              actions: [
            GestureDetector(
            onTap:(){
              setState(() {
                Navigator.pop(context);
                dialogeSubmitPress();
              });
            },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                    color: primaryColor,
                    border: Border.all(width: 1, color: primaryColor),
                    borderRadius: BorderRadius.circular(5)
                ),
                child: Text('Submit', style: TextStyle(color: whtColor, fontWeight: FontWeight.w500),),
              ),
            )
              ],
            );
        }


    );
  }



  void collectAccurate(){
    dialogBoxratting();
  }

  void otherPress(){
    setState(() {
      other = true;
    });
  }

  void submitPress(){

    dialogBoxratting();
    
  }

  void dialogeSubmitPress(){
   // customer feedback to driver
    DatabaseReference feedbackReference = FirebaseDatabase.instance.reference().child('rideRequest/$trip_id/feedback_to_driver');
              feedbackReference.set(feedback);
              try{
  DatabaseReference updat = FirebaseDatabase.instance.reference().child('users/${driver_id}');
           updat.once().then(( DataSnapshot event) async {
           setState(() {
               driver_feed = event.value["feedback"];
              
           });

           });  
     feedback  =   ( driver_feed + feedback ) / 2;
              }catch(e){

              }
    DatabaseReference updateRefo = FirebaseDatabase.instance.reference().child('users/${driver_id}/feedback');
       DatabaseReference updateRe = FirebaseDatabase.instance.reference().child('users/${currentUserInfo.id}');
              updateRe.child("newTrip").set("");
              updateRefo.set(feedback);
   DatabaseReference tripHistory = FirebaseDatabase.instance.reference().child('tripHistory/${trip_id}/feedback_to_driver');
      tripHistory.set(feedback);
    AppRoutes.pop(context);
    // AppRoutes.makeFirst(context, DriverHomeClass());

  }

}
