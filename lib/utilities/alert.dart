import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/authentication/verified.dart';
import 'package:flutter_app/utilities/routes.dart';

void alert( {BuildContext context, String title, String description}){
  AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.BOTTOMSLIDE,
            title: title,
            desc: description,
            btnCancelOnPress: () {
               AppRoutes.pop(context);
            },
            btnOkOnPress: () {
               AppRoutes.pop(context);
            },
            )..show();
}