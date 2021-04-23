import 'package:flutter/material.dart';
import 'utilities.dart';


class HeaderClass extends StatelessWidget {
  bool logging;
  HeaderClass(@required Logging){
    this.logging=Logging;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
     // color: green,
      padding: EdgeInsets.only(top: 50),
      height:logging? MediaQuery.of(context).size.height*.4:MediaQuery.of(context).size.height*.20,
      width: MediaQuery.of(context).size.width,
      //margin: EdgeInsets.only(bottom: 10),
      alignment: Alignment.center,
        child: Image.asset('assets/logo.png', height: MediaQuery.of(context).size.height*.2,color: black, width: MediaQuery.of(context).size.width/2,),

    );
  }
}




class TermFooterClass extends StatefulWidget {
  @override
  _TermFooterClassState createState() => _TermFooterClassState();
}

class _TermFooterClassState extends State<TermFooterClass> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      child: Column(
        children: [
          Text('By signing up you have agreed to our', style: TextStyle(color: lightGray, fontSize: 13),),
          Text('Terms of Use & Privacy Policy', style: TextStyle(color: DarkGray, fontSize: 13)),
        ],
      ),
    );
  }
}
