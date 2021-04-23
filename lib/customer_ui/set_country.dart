import 'package:flutter/material.dart';
import 'package:flutter_app/utilities/utilities.dart';

import 'bar_drawer.dart';
class SetCountry extends StatelessWidget {
   final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight), // here the desired height
          child: CusAppBarClass( context, 'Country & Currency', false,_scaffoldKey) ),

      body: Center(child: Text('Under Development'),));
  }
}
