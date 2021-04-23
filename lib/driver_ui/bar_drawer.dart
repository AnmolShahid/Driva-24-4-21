import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/authentication/loging.dart';
import 'package:flutter_app/customer_ui/cust_my_profile.dart';
import 'package:flutter_app/customer_ui/cust_trip_history.dart';
import 'package:flutter_app/customer_ui/income_history.dart';
import 'package:flutter_app/driver_ui/customer_review.dart';
import 'package:flutter_app/driver_ui/driver_home.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_app/customer_ui/settings.dart';

import 'package:flutter_app/core/helper/helperMethod.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/core/helper/helperMethod.dart';


class DrivAppBarClass extends PreferredSize {
  static var status = false;

  DrivAppBarClass(BuildContext context,title,back,keyScaf)
      : super(
            preferredSize: Size.fromHeight(0),
            child: Container(
              child: 
              AppBar(
                backgroundColor: whtColor,
                elevation: 0,
                //actions: [Icon(Icons.menu, color: lightGray,)],

                leading: back?GestureDetector(onTap: () async{
                    await  HelperMethods.getCurrentUSerInfo();
         
                  Navigator.pop(context);
                  
                  },
                        child: Icon(Icons.arrow_back,color: DarkGray, ),):GestureDetector(onTap: (){keyScaf.currentState.openDrawer();}, child: Icon(Icons.menu, color: DarkGray,),),
                title: Center(
        child: Container(
          child: FlutterSwitch(
            width: 125.0,
            height: 55.0,
            valueFontSize: 25.0,
            toggleSize: 45.0,
            value: status,
            borderRadius: 30.0,
            padding: 8.0,
            activeColor: Colors.green,
            activeText: "Online",
            inactiveText: "Offline",
            showOnOff: true,
            onToggle: (val) {
              
                status = val;
             
            },
          ),
        ),
      ), 
                centerTitle: true,
              ),
            ));
}
class DriverDrawerPage extends PreferredSize {
  DriverDrawerPage(BuildContext context)
      : super(
      preferredSize: Size.fromHeight(0),
      child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width * .7,
          child:Container(
              color: whtColor,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width * .7,
              child: Container(
                  child: Column(
                      children: <Widget>[
                        Container(
                          color: primaryColor,
                          width: MediaQuery.of(context).size.width * .7,
                          padding: EdgeInsets.only(top: 25),
                          alignment: Alignment.bottomLeft,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              size: 25,
                              color: whtColor,
                            ),
                          ),
                        ),
                          Container(
                    padding: EdgeInsets.only(bottom: 20),
                    color: primaryColor,
                    width: MediaQuery.of(context).size.width * .7,
                    child:       StreamBuilder(
              stream: FirebaseDatabase.instance
                  .reference()
                  .child('users')
                  
                  .orderByChild('uid')
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
    }else{
       Map<dynamic, dynamic> map = snap.data.snapshot.value;
                    List<dynamic> list = map.values.toList();

        return   Column(
                      children: [
                    /*     CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.2),
                radius: 50,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.black.withOpacity(0),
                      backgroundImage: NetworkImage(currentUserInfo.displayImage)
                    ),])),
                    */
                    
                    CachedNetworkImage(
  imageUrl:  list[0]["displayImage"],
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
                       /*   Container(
                          height: 90,
                          width: 90,
                        // color: Colors.white

                     
                     decoration: new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
                           child: CachedNetworkImage(

   imageUrl: currentUserInfo.displayImage,
   placeholder: (context, url) => new CircularProgressIndicator(),
   errorWidget: (context, url, error) => new Icon(Icons.error),
 )
                        ),
                      */  Text(list[0]["username"]??'Driver', style: TextStyle(color: whtColor, fontWeight: FontWeight.bold, fontSize: 20),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              list[0]["feedback"].toString()??'0.0', 
                            
                            style: TextStyle(color: whtColor, fontWeight: FontWeight.bold, fontSize: 16)),
                            Icon(Icons.star, size: 15,color: whtColor,)
                          ],
                        ),
                      ],
                   
                  );
                  

    }
   
    
  
  }
),
    
             ),
           
                    
                        Expanded(
                          child: ListView(
                            physics: BouncingScrollPhysics(),
                            children: <Widget>[
                              // Home button container
                              ListTile(
                                onTap: (){
                                  AppRoutes.makeFirst(context, DriverHomeClass());


                                },
                                title: Text('Home Page',
                                  style: TextStyle(
                                      fontSize: 15,fontWeight: FontWeight.bold),
                                ),

                              ),
                              ListTile(
                                onTap: (){
                                  Navigator.pop(context);
                                  AppRoutes.push(context, CustomerTripHistoryClass());
                                },
                                title: Text('Trip History',
                                  style: TextStyle(
                                      fontSize: 15,fontWeight: FontWeight.bold),
                                ),

                              ),
                              ListTile(
                                onTap: (){
                                  Navigator.pop(context);
                                  AppRoutes.push(context, IncomeHistory());

                                },
                                title: Text('Income History',
                                  style: TextStyle(
                                      fontSize: 15,fontWeight: FontWeight.bold),
                                ),

                              ),
                             /* ListTile(
                                onTap: (){
                                  Navigator.pop(context);
                                  AppRoutes.push(context, CustomerReviews());

                                },
                                title: Text('Customer Reviews',
                                  style: TextStyle(
                                      fontSize: 15,fontWeight: FontWeight.bold),
                                ),

                              ),
*/
                              ListTile(
                                onTap: (){
                                  Navigator.pop(context);
                                  AppRoutes.push(context, CustomerPrfileClass());
                               //  Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));

                                },
                                title: Text('My Profile',
                                  style: TextStyle(
                                      fontSize: 15,fontWeight: FontWeight.bold),
                                ),

                              ),
                              ListTile(
                                onTap: (){
                                  Navigator.pop(context);
                                   AppRoutes.push(context, SettingsPage());
                                 
                                 //  Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));

                                },
                                title: Text('Settings',
                                  style: TextStyle(
                                      fontSize: 15,fontWeight: FontWeight.bold),
                                ),

                              ),


                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border(top: BorderSide(width: 1, color: lightGray))
                          ),
                          child: ListTile(
                            onTap: () async {
                              await FirebaseAuth.instance.signOut();
                              print('user.uid');
                          //    User user = FirebaseAuth.instance.currentUser;
                              Geofire.removeLocation(currentUserInfo.id);
                              AppRoutes.makeFirst(context, LogingClass());
                            },
                            title: Text('Logout',
                              style: TextStyle(
                                  fontSize: 15,fontWeight: FontWeight.bold),
                            ),

                          ),
                        )

                      ]
                  )
              )
          )
      )
  );
}