import 'package:flutter/material.dart';
import 'package:flutter_app/utilities/utilities.dart';



class TextFieldClass extends StatefulWidget {
  TextInputType classkeyboardType;
  Widget icon;
  String hint;
  TextEditingController classcontroller;
  bool isPass;
  TextFieldClass({
    TextInputType keyboardType,
    Widget iconn,
    TextEditingController controller,
    String hintt,
    bool isPasss,
}){
    keyboardType==null? this.classkeyboardType = TextInputType.text: this.classkeyboardType = keyboardType;
    if(iconn==null){this.icon = Icon(Icons.person_outline, color: lightGray,);} else{this.icon = iconn;}
    if(hintt==null){this.hint = 'Email';} else{this.hint = hintt;}
    if(isPasss==null){this.isPass = false;} else{this.isPass = isPasss;}
    
  }

  @override
  _TextFieldClassState createState() => _TextFieldClassState();
}

class _TextFieldClassState extends State<TextFieldClass> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width*.8,
      child: Row(
        children: [
          widget.icon,
          //Icon(Icons.person_outline, color: lightGray,),
          Expanded(
            child: TextFormField(
              controller: widget.classcontroller,
              keyboardType: widget.classkeyboardType,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(color: lightGray),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10, bottom: 0)
              ),
              style: TextStyle(fontSize: 18, color: lightGray),

            ),
          ),

          widget.isPass?Icon(Icons.visibility, color: lightGray,):Container()

        ],
      ),
    );
  }
}




