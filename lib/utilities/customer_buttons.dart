import 'package:flutter/material.dart';

import 'utilities.dart';




class PrimaryButton extends StatefulWidget {
  String headding;
  Function ontap;
  Color fillColor;
  PrimaryButton ({
   String Heading,
   Function onTap,
    Color FillColor,

 }){
    FillColor==null? this.fillColor=primaryColor:this.fillColor=FillColor;
  if(Heading==null){this.headding='LOGIN';}else{this.headding=Heading;}
  this.ontap=onTap;
  }
  @override
  _PrimaryButtonState createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.ontap,
      child: Container(
        margin: EdgeInsets.only(top: 20, bottom: 10),
        height: authButtonHeight,
        width: MediaQuery.of(context).size.width*.8,
        decoration: BoxDecoration(
          color: widget.fillColor,
            //border: Border.all(width: 1, color: lightGray),
            borderRadius: BorderRadius.circular(25)
        ),
        alignment: Alignment.center,
        child: Text(widget.headding, style: TextStyle(color: whtColor, fontSize: 18),),
      ),
    );
  }
}
