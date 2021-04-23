
import 'package:flutter/material.dart';
import 'package:flutter_app/utilities/routes.dart';


Widget loading(){
 return Container(
    width: 100,
    height: 100,
          child: CircularProgressIndicator(),
        );
}


closeLoading(context){
   AppRoutes.pop(context);
}