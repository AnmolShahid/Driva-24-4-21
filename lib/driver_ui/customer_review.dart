import 'package:flutter/material.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:flutter_app/driver_ui/bar_drawer.dart';

import 'package:flutter_app/utilities/constant.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_app/core/dbmodels/trip.dart';
import 'package:firebase_database/firebase_database.dart';


class CustomerReviews extends StatefulWidget {
  @override
  _CustomerReviewsState createState() => _CustomerReviewsState();
}

class _CustomerReviewsState extends State<CustomerReviews> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
        key: _scaffoldKey,
      //drawer: CusDrawerPage(context),
    //  drawer: DriverDrawerPage(context),
     appBar: AppBar(
       backgroundColor: Colors.black,
       title:Text ('Reviews'),
       centerTitle: true,
     ),

      body:  Container(
      child:  StreamBuilder(
              stream: constant_role==0?FirebaseDatabase.instance
                  .reference()
                  .child('rideRequest')
                  
                  .orderByChild('rider_id')
                  .equalTo(currentUserInfo.id)
                  .onValue
                  :FirebaseDatabase.instance
                  .reference()
                  .child('rideRequest')
                  
                  .orderByChild('driver_id')
                  .equalTo(currentUserInfo.id)
                  .onValue,
              builder: (BuildContext context, AsyncSnapshot<Event> snap) {
       if (snap.hasError)
          return Text('Error: ${snap.error}');
    if (!snap.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Loading..."),
                  SizedBox(
                    height: 50.0,
                  ),
                  CircularProgressIndicator()
                ],
              ),
            );
    }else
    if(snap.data.snapshot.value!=null){
            if(snap.data.snapshot.value.length==0){
               return  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                   SizedBox(
                    height: 50.0,
                  ),
                  Text("NO REVIEW HISTORY"),
                  SizedBox(
                    height: 50.0,
                  ),
                 
                ],
              ),
            );

           }else{
            Map<dynamic, dynamic> map = snap.data.snapshot.value;
                    List<dynamic> list = map.values.toList();


                  return Container(
                
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index ){
                 return  Card(
        margin: EdgeInsets.all(10),

      //  padding: EdgeInsets.all(20),
        // decoration: BoxDecoration(
        //     color: whtColor,
        //     border: Border(bottom: BorderSide(width: 1, color: lightGray))

        // ),
        child: Padding(padding: EdgeInsets.all(20),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // time and cash row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   Text(constant_role==0?list[0]["rider_name"]??'Customer Name':'Customer Name', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),),

                   Text(list[0]["created_at"]??'${(index+1)*3}/${(index+1)*2}/2020,  ${(index+1)*2}:55 ${index.isOdd?'AM':'PM'}', style: TextStyle(fontSize: 14, ),),
                
                ],),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                 Text('Trip ID: 049583785', style: TextStyle(fontSize: 14, )),
                  Text(list[0]["total_EstimatedFare"]??'QAR ${(index+1)*6
                }', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                 Text('Cash', style: TextStyle(color: lightGray,fontSize: 13, fontWeight: FontWeight.w500),),

              ],) ,


              
                
              ],
            ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Text('Review:', style: TextStyle(fontSize: 16, )),
                   RatingBar.builder(
                    initialRating: constant_role==0?list[0]["feedback_to_driver"]??3:list[0]["feedback_to_customer"]??3,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemSize: 30.0,
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    
                  ),
                  Text('Great experiance and safe traveling with him.', style: TextStyle(color: lightGray,fontSize: 13, fontWeight: FontWeight.w500),),

              ],) ,

          ],
        ),
     
        ),
    );
          })
          );
             
           }
                 
            }else{
               return  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                   SizedBox(
                    height: 50.0,
                  ),
                  Text("NO REVIEW HISTORY"),
                  SizedBox(
                    height: 50.0,
                  ),
                 
                ],
              ),
            );
       
            }
       
    
  
  }
)
   
    )
  ,);
    
    
   }
    Widget reviewTile(int index){
    return  Card(
        margin: EdgeInsets.all(10),

      //  padding: EdgeInsets.all(20),
        // decoration: BoxDecoration(
        //     color: whtColor,
        //     border: Border(bottom: BorderSide(width: 1, color: lightGray))

        // ),
        child: Padding(padding: EdgeInsets.all(20),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // time and cash row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   Text(constant_role==0?'Customer Name':'Customer Name', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),),

                   Text('${(index+1)*3}/${(index+1)*2}/2020,  ${(index+1)*2}:55 ${index.isOdd?'AM':'PM'}', style: TextStyle(fontSize: 14, ),),
                
                ],),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                 Text('Trip ID: 049583785', style: TextStyle(fontSize: 14, )),
                  Text('QAR ${(index+1)*6
                }', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                 Text('Cash', style: TextStyle(color: lightGray,fontSize: 13, fontWeight: FontWeight.w500),),

              ],) ,


              
                
              ],
            ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Text('Review:', style: TextStyle(fontSize: 16, )),
                   Row(
                  children: [
                    Icon(Icons.star, size: 15,),
                    Icon(Icons.star, size: 15,),
                    Icon(Icons.star, size: 15,),
                    Icon(Icons.star, size: 15,),
                  ],
                ),
                  Text('Great experiance and safe traveling with him.', style: TextStyle(color: lightGray,fontSize: 13, fontWeight: FontWeight.w500),),

              ],) ,

          ],
        ),
     
        ),
    );
  }
 
}