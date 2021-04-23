import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_app/core/model/prediction.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'package:flutter_app/core/helper/requesthelper.dart';
import 'package:flutter_app/core/model/address.dart';
import 'package:flutter_app/core/dataprovider/appData.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/utilities/progressDialog.dart';


class PredictionTile extends StatelessWidget {
  final Prediction prediction;
  PredictionTile({this.prediction});


  void getPlaceDetails(String placeID, context) async {
    
    // showDialog(
    //   barrierDismissible: false,
    //   context: context,
    //   builder: (BuildContext context) => ProgressDialog(context,status: 'Please wait...',) 
    //   );
    String url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$apiKey';
    var response = await RequestHelper.getRequest(url);
    
  //  Navigator.pop(context);

    if(response == 'failed'){
      return;
    }
    if(response['status'] == 'OK'){
      
      Address  thisPlace = Address();
      thisPlace.placeId = placeID;
      thisPlace.placeName = response['result']['name'];
      thisPlace.latitude = response['result']['geometry']['location']['lat'];
      thisPlace.longitude = response['result']['geometry']['location']['lng'];

      Provider.of<AppData>(context,listen: false).updateDestinationAddress(thisPlace);
        Navigator.pop(context, 'getDirection');
    }
  }
  @override
  Widget build(BuildContext context) {
      return   FlatButton(
       
            onPressed: ()async{
             await getPlaceDetails(prediction.placeId, context);
            },
            child:
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey),
                  SizedBox(width: 12,),
                  Expanded(
                    child:  Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       SizedBox(height: 10,),
                      Text(
                        prediction.mainText.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                        ),),
                        SizedBox(height: 2,),
                        Text(prediction.secondaryText.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color:Colors.grey,

                        ),),
                         SizedBox(height: 5,),

                    ],)
                )
                 ],)
         );
 
  }
}


class PredictionTilePick extends StatelessWidget {
  final Prediction prediction;
  PredictionTilePick({this.prediction});


  void getPlaceDetails(String placeID, context) async {
    
    // showDialog(
    //   barrierDismissible: false,
    //   context: context,
    //   builder: (BuildContext context) => ProgressDialog(context,status: 'Please wait...',) 
    //   );
    String url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$apiKey';
    var response = await RequestHelper.getRequest(url);
    
  //  Navigator.pop(context);

    if(response == 'failed'){
      return;
    }
    if(response['status'] == 'OK'){
      
      Address  thisPlace = Address();
      thisPlace.placeId = placeID;
      thisPlace.placeName = response['result']['name'];
      thisPlace.latitude = response['result']['geometry']['location']['lat'];
      thisPlace.longitude = response['result']['geometry']['location']['lng'];

      Provider.of<AppData>(context,listen: false).updatePickupAddress(thisPlace);
        Navigator.pop(context, 'getDirection');
    }
  }
  @override
  Widget build(BuildContext context) {
      return   FlatButton(
       
            onPressed: ()async{
             await getPlaceDetails(prediction.placeId, context);
            },
            child:
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey),
                  SizedBox(width: 12,),
                  Expanded(
                    child:  Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       SizedBox(height: 10,),
                      Text(
                        prediction.mainText.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                        ),),
                        SizedBox(height: 2,),
                        Text(prediction.secondaryText.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color:Colors.grey,

                        ),),
                         SizedBox(height: 5,),

                    ],)
                )
                 ],)
         );
 
  }
}