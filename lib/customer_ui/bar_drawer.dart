import 'package:flutter/material.dart';
import 'package:flutter_app/authentication/loging.dart';
import 'package:flutter_app/customer_ui/cust_my_profile.dart';
import 'package:flutter_app/customer_ui/cust_trip_history.dart';
import 'package:flutter_app/customer_ui/cust_wallet.dart';
import 'package:flutter_app/customer_ui/cust_home.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/customer_ui/settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'add_locations.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/core/helper/helperMethod.dart';

class CusAppBarClass extends PreferredSize {
  CusAppBarClass(BuildContext context, title, drawer, keyScaf)
      : super(
            preferredSize: Size.fromHeight(0),
            child: Container(
              child: AppBar(
                backgroundColor: primaryColor,
                elevation: 0,
                //actions: [Icon(Icons.menu, color: lightGray,)],
                // actions: [drawer?Icon(Icons.menu, color: DarkGray,):Container(), SizedBox(width: 10,)],
                leading: drawer
                    ? GestureDetector(
                        onTap: () async {
                          await HelperMethods.getCurrentUSerInfo();
                          keyScaf.currentState.openDrawer();
                        },
                        child: Icon(
                          Icons.menu,
                          color: whtColor,
                        ),
                      )
                    : GestureDetector(
                        onTap: () async {
                          await HelperMethods.getCurrentUSerInfo();

                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: whtColor,
                        ),
                      ),
                title: Text(
                  '$title',
                  style: TextStyle(fontSize: 15, color: whtColor),
                ),
                centerTitle: true,
              ),
            ));
}

class CusDrawerPage extends PreferredSize {
  CusDrawerPage(BuildContext context)
      : super(
            preferredSize: Size.fromHeight(0),
            child: Container(
                color: whtColor,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width * .7,
                child: Container(
                    child: Column(children: <Widget>[
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
                  currentUserInfo != null
                      ? Container(
                          padding: EdgeInsets.only(bottom: 20),
                          color: primaryColor,
                          width: MediaQuery.of(context).size.width * .7,
                          child: StreamBuilder(
                              stream: FirebaseDatabase.instance
                                  .reference()
                                  .child('users')
                                  .orderByChild('uid')
                                  .equalTo(currentUserInfo.id)
                                  .onValue,
                              builder: (BuildContext context,
                                  AsyncSnapshot<Event> snap) {
                                if (snap.hasError)
                                  return Text('Error: ${snap.error}');
                                if (!snap.hasData) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text("Loading..."),
                                        SizedBox(
                                          height: 50.0,
                                        ),
                                        CircularProgressIndicator()
                                      ],
                                    ),
                                  );
                                } else {
                                  Map<dynamic, dynamic> map =
                                      snap.data.snapshot.value;
                                  List<dynamic> list = map.values.toList();

                                  return Column(
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
                                        imageUrl: list[0]["displayImage"],
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
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
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
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
                      */
                                      Text(
                                        list[0]["username"] ?? 'Customer',
                                        style: TextStyle(
                                            color: whtColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                              list[0]["feedback"].toString() ??
                                                  '0.0',
                                              style: TextStyle(
                                                  color: whtColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          Icon(
                                            Icons.star,
                                            size: 15,
                                            color: whtColor,
                                          )
                                        ],
                                      ),
                                    ],
                                  );
                                }
                              }),
                        )
                      : Container(
                          padding: EdgeInsets.only(bottom: 20),
                          color: primaryColor,
                          width: MediaQuery.of(context).size.width * .7,
                          child: StreamBuilder(
                              stream: FirebaseDatabase.instance
                                  .reference()
                                  .child('users')
                                  .orderByChild('uid')
                                  .equalTo("uTKN00smALQlSzI8kph7IYywCdO2")
                                  .onValue,
                              builder: (BuildContext context,
                                  AsyncSnapshot<Event> snap) {
                                if (snap.hasError)
                                  return Text('Error: ${snap.error}');
                                if (!snap.hasData) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text("Loading..."),
                                        SizedBox(
                                          height: 50.0,
                                        ),
                                        CircularProgressIndicator()
                                      ],
                                    ),
                                  );
                                } else {
                                  Map<dynamic, dynamic> map =
                                      snap.data.snapshot.value;
                                  List<dynamic> list = map.values.toList();

                                  return Column(
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
                                        imageUrl: list[0]["displayImage"],
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
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
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
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
                      */
                                      Text(
                                        list[0]["username"] ?? 'Customer',
                                        style: TextStyle(
                                            color: whtColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                              list[0]["feedback"].toString() ??
                                                  '0.0',
                                              style: TextStyle(
                                                  color: whtColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          Icon(
                                            Icons.star,
                                            size: 15,
                                            color: whtColor,
                                          )
                                        ],
                                      ),
                                    ],
                                  );
                                }
                              }),
                        ),
                  Expanded(
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      children: <Widget>[
                        // Home button container
                        ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            AppRoutes.makeFirst(context, CustomerHomeClass());
                            // Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));
                          },
                          title: Text(
                            'Home Page',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            AppRoutes.push(context, CustomerTripHistoryClass());
                          },
                          title: Text(
                            'Trip History',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            AppRoutes.push(context, CustomerWalletClass());
                          },
                          title: Text(
                            'Wallet',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // ListTile(
                        //   onTap: (){
                        //     Navigator.pop(context);
                        //     // Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));
                        //
                        //   },
                        //   title: Text('Messages',
                        //     style: TextStyle(
                        //         fontSize: 15,fontWeight: FontWeight.bold),
                        //   ),
                        //
                        // ),
                        ListTile(
                          onTap: () {
                            //  Navigator.pop(context);
                            // Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));
                            showDialog(
                                context: context,
                                //barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: whtColor,
                                    titlePadding: EdgeInsets.all(10),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Helpline: +99 333 111',
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(10),
                                          margin: EdgeInsets.only(
                                              left: 10, right: 10),
                                          decoration: BoxDecoration(
                                              color: primaryColor,
                                              border: Border.all(
                                                  width: 1,
                                                  color: primaryColor),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Text(
                                            'Okay',
                                            style: TextStyle(
                                                color: whtColor,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                });
                          },
                          title: Text(
                            'Helpline',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            AppRoutes.push(context, CustomerPrfileClass());
                            // Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));
                          },
                          title: Text(
                            'My Profile',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddLocation()));
                            //    AppRoutes.makeFirst(context, AddLocation());
                          },
                          title: Text(
                            'Add Location',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(width: 1, color: lightGray))),
                    child: ListTile(
                      onTap: () async {
                        login = false;

                        await FirebaseAuth.instance.signOut();
                        AppRoutes.makeFirst(context, LogingClass());
                      },
                      title: Text(
                        'Logout',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ]))));
}
