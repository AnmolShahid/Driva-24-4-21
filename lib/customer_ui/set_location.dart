import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_app/core/dataprovider/appData.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/model/prediction.dart';
import 'package:flutter_app/core/helper/requesthelper.dart';
import 'package:flutter_app/core/setLocation_db.dart';
import 'package:flutter_app/utilities/brandDivider.dart';
import 'package:flutter_app/utilities/constant.dart';

class SetLocation extends StatefulWidget {
  final int variable;//if you have multiple values add here
SetLocation(this.variable, {Key key}): super(key: key);//add also..example this.abc,this...



  @override
  _SetLocationState createState() => _SetLocationState();
}

class _SetLocationState extends State<SetLocation> {


  var pickupController = TextEditingController();

    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


void showSnackBar(String title){
  final snackBar = SnackBar(content: Text(title,textAlign: TextAlign.center,style: TextStyle(fontSize: 15),),);
  _scaffoldKey.currentState.showSnackBar(snackBar);
}
  bool onlineStatus = false;
  int rideStatus = 0;
  bool gotLocation = false;


  var mapBottomPadding = 0.0;

  var focusDestination = FocusNode();
   var focusPickup = FocusNode();
  bool focused = false;

  void setFocusDes() {
    if(!focused){
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
    
  }
   void setFocusPick() {
    if(!focused){
      FocusScope.of(context).requestFocus(focusPickup);
      focused = true;
    }
    
  }

  List<Prediction> destinationPredictionList = [];
    List<Prediction> pickupPredictionList = [];

  void searchPlacePick(String placeName) async {
    if(placeName.length > 1){
     showSnackBar('please wait'); 
    String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=AIzaSyAUqoje9DfiCojdYrICiT0643jh7N6stLc&sessiontoken=1234567890';
    var response = await RequestHelper.getRequest(url);
    if(response == 'failed'){
      return;
    }
    if(response['status'] == 'OK'){
      var predictionJson = response['predictions'];
      var thisList = (predictionJson as List).map((e) => Prediction.fromJson(e)).toList();

     setState(() {
        pickupPredictionList = thisList;
    
     });
    }
    }
  }


  @override
  Widget build(BuildContext context) {
   
      setFocusPick();
    
   
   
    return Scaffold(
      key: _scaffoldKey,
      body:Container(
        height: MediaQuery.of(context).size.height,
     child: ListView(
        children: [
     

          Container(
            height: 230,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5.0,
                  spreadRadius: 0.5,
                  offset: Offset(
                    0.7,
                    0.7,
                  ) )
              ]),
            child:Padding(
              padding: EdgeInsets.only(left:24,top:48,right: 24,bottom: 20),
              child:    Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5,),
                Stack(
                  children: [

                    GestureDetector(child: Icon(Icons.arrow_back),onTap: (){
                      Navigator.of(context).pop();
                    },),
                    Center(
                      child:Text('Set Location',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),) ,)
                  ],),
                  SizedBox(height: 18,),
                 
                    Row(
                     
                    children: [
                   
                      
                   Container(
                     height: 100,
                     width: MediaQuery.of(context).size.width-75,
                     child:  Column(
                        
                         children: [
                              Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                       
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child:    TextField(
                          onChanged: (value){
                              searchPlacePick(value);
                          },
                          focusNode: focusPickup,
                         
                        controller: pickupController,
                        decoration: InputDecoration(
                          hintText: 'Location',
                          suffixIcon: IconButton(
                            onPressed: pickupController.clear,
                            icon: Icon(Icons.clear),
                          ),
                          fillColor: Colors.black12,
                          filled: true,
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.only(left: 10, top: 8, bottom: 8)
                        ),
                        )
                   
                      
                       )
                        )
                       ,),
                       SizedBox(height: 18,),
                       
                         ],)
                   
                   )
                    ],),
                  
                 //  SizedBox(height: 18,),
/*                    Row(
                    children: [
                      Image.asset('assets/desticon.png',height: 16,width: 16,),
                      SizedBox(width: 18,),
                      Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color:Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child:    TextField(
                        decoration: InputDecoration(
                          hintText: 'Pickup Destination',
                          fillColor: Colors.black12,
                          filled: true,
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.only(left: 10, top: 8, bottom: 8)
                        ),
                        )
                   
                      
                       )
                        )
                       ,)
                    ],),
*/
                  
             
              ],)
         ),

           ),
          SizedBox(height: 10,),
          

          (pickupPredictionList.length > 0)
          ?
          Container(
            height: MediaQuery.of(context).size.height-250,
            padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
            child:ListView.separated(
            padding: EdgeInsets.all(0.0),
            itemBuilder: (context,index){
              return SetLocationDB(
                prediction: pickupPredictionList[index],
              );
            },
            separatorBuilder: (BuildContext context, int index) => BrandDivider() ,
            itemCount: pickupPredictionList.length,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            ),
          )
            :
            Container()

        ],)
      
    ));
  }

  
}