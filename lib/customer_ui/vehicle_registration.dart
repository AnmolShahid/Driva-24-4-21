import 'package:flutter/material.dart';
import 'package:flutter_app/core/vehicle.dart';
import 'package:flutter_app/customer_ui/bar_drawer.dart';
import 'package:flutter_app/customer_ui/cust_home.dart';
import 'package:flutter_app/utilities/customer_buttons.dart';
import 'package:flutter_app/utilities/input_field.dart';
import 'package:flutter_app/utilities/routes.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_database/firebase_database.dart';
class CareRegistrationClass extends StatefulWidget {
  @override
  _CareRegistrationClassState createState() => _CareRegistrationClassState();
}

class _CareRegistrationClassState extends State<CareRegistrationClass> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<VehicleImage> _vehicleImage =  List<VehicleImage>();
  var vehicleRegController = TextEditingController();

  var vehicleModelController = TextEditingController();

  var vehicleModelNoController = TextEditingController();

  var vehicleManuController = TextEditingController();

  var vehicleInssuranceCompanyController = TextEditingController();

  var vehicleInssuranceNoController = TextEditingController();

  var vehicleInssuranceDateController = TextEditingController();

void showSnackBar(String title){
  final snackBar = SnackBar(content: Text(title,textAlign: TextAlign.center,style: TextStyle(fontSize: 15),),);
  _scaffoldKey.currentState.showSnackBar(snackBar);
}



Future<void> selectImages() async {
    List<Media> _listImagePaths = await ImagePickers.pickerPaths(
              galleryMode: GalleryMode.image,
              selectCount: 5,
              showGif: false,
              showCamera: true,
              compressSize: 500,
              uiConfig: UIConfig(uiThemeColor: Color(0xff000000)),
              cropConfig: CropConfig(enableCrop: false, width: 2, height: 1)
              ).then((value) {
                for(int i=0;i<value.length;i++){
                     _vehicleImage.add(VehicleImage(image: value[i].path));
                }

               
              });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: whtColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight), // here the desired height
          child: AppBar(
                backgroundColor: primaryColor,
                elevation: 0,
                automaticallyImplyLeading: false,
                title:  Text('Vehicle Registration', style: TextStyle(fontSize:15, color: whtColor),),
                centerTitle: true,
              ),  ),
      //bottomNavigationBar: Container(height: 70, child: TermFooterClass(),),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 20,  right: 20),
        physics: BouncingScrollPhysics(),
        child: vehicleRegistrationFields(),
      ),
    );
  }

  Widget vehicleRegistrationFields(){
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
         // HeaderClass(),
          SizedBox(height: 25,),
          Text('Vehicle Registration & insurance details',textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),),
                     Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width*.8,
      child: Row(
        children: [
         
          Icon(Icons.directions_car, color: lightGray,),
          Expanded(
            child: TextFormField(
              controller: vehicleRegController,
              keyboardType:TextInputType.text,
              
              decoration: InputDecoration(
                hintText: 'Registration No',
                hintStyle: TextStyle(color: lightGray),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10, bottom: 0)
              ),
              style: TextStyle(fontSize: 18, color: lightGray),

            ),
          ),

          

        ],
      ),
    ),
           Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width*.8,
      child: Row(
        children: [
         
          Icon(Icons.directions_car, color: lightGray,),
          Expanded(
            child: TextFormField(
              controller: vehicleModelNoController,
              keyboardType:TextInputType.text,
              
              decoration: InputDecoration(
                hintText: 'Model',
                hintStyle: TextStyle(color: lightGray),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10, bottom: 0)
              ),
              style: TextStyle(fontSize: 18, color: lightGray),

            ),
          ),

          

        ],
      ),
    ),
           Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width*.8,
      child: Row(
        children: [
         
          Icon(Icons.directions_car, color: lightGray,),
          Expanded(
            child: TextFormField(
              controller: vehicleManuController,
              keyboardType:TextInputType.text,
              
              decoration: InputDecoration(
                hintText: 'Manufacturer',
                hintStyle: TextStyle(color: lightGray),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10, bottom: 0)
              ),
              style: TextStyle(fontSize: 18, color: lightGray),

            ),
          ),

          

        ],
      ),
    ),
           Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width*.8,
      child: Row(
        children: [
         
           Image.asset('assets/carin.png', height: 25, color: lightGray,),
          Expanded(
            child: TextFormField(
              controller: vehicleInssuranceCompanyController,
              keyboardType:TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Insurance Company',
                hintStyle: TextStyle(color: lightGray),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10, bottom: 0)
              ),
              style: TextStyle(fontSize: 18, color: lightGray),

            ),
          ),

          

        ],
      ),
    ),
           Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width*.8,
      child: Row(
        children: [
         
          Image.asset('assets/carin.png', height: 25, color: lightGray,),
          Expanded(
            child: TextFormField(
              controller: vehicleInssuranceNoController,
              keyboardType:TextInputType.text,
             
              decoration: InputDecoration(
                hintText: 'Insurance No',
                hintStyle: TextStyle(color: lightGray),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10, bottom: 0)
              ),
              style: TextStyle(fontSize: 18, color: lightGray),

            ),
          ),

          

        ],
      ),
    ),
           Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width*.8,
      child: Row(
        children: [
         
          Image.asset('assets/carin.png', height: 25, color: lightGray,),
         GestureDetector(
           child:  Container(
             width: 200,
             height: 50,
            child: TextFormField(
              controller: vehicleInssuranceDateController,
              keyboardType:TextInputType.datetime,
               enabled: false,
              onTap: (){
                _selectDate(context);
              },
              decoration: InputDecoration(
                hintText: 'Insurance Expiry Date',
                hintStyle: TextStyle(color: lightGray),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10, bottom: 0)
              ),
              style: TextStyle(fontSize: 18, color: lightGray),

            ),
          ),

           onTap: (){
                _selectDate(context);
              } ,
         ),
         
          

        ],
      ),
    ),
   
         imageUploadd(),
       /*  _vehicleImage.length == null
         ?
         Container()
         :
          Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 80,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _vehicleImage.length,
                                        itemBuilder: (BuildContext context, int index) => Card(
                                            
                                                child: Column(children: [
                                                 for(int index = 0; index < _vehicleImage.length; index++)
                                                      Image.network(_vehicleImage.elementAt(index).image.toString(),fit: BoxFit.fill,width: 80,),
                                                     
                                              ],),
                                             
                                              
                                              
                                            ),
                                      ),
                                  
                                    ),
        */
          PrimaryButton(Heading: 'Update and Continue',onTap: updatePress,),
          FlatButton(child:Text( 'Skip'),onPressed: (){
            AppRoutes.replace(context, CustomerHomeClass());
          },),
        ],
      ),
    );
  }
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
        builder: (BuildContext context, Widget child) {
      return Theme(
        data: ThemeData.dark().copyWith(
          backgroundColor:Colors.white ,
          primaryColor: Colors.black,
         colorScheme: ColorScheme.dark().copyWith(
             primary: Colors.black,
             background:Colors.white ,
             onPrimary: Colors.black,
            onBackground: Colors.white,
      ),
           
          ),
       
    
      child: child,
   );
        };
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        vehicleInssuranceDateController.text = selectedDate.day.toString()+"-"+selectedDate.month.toString()+"-"+selectedDate.year.toString();
      });
  }

  Widget imageUploadd(){
    return Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5, bottom: 0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width*.8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                Image.asset('assets/gallery.png', height: 25,color: lightGray,),
                SizedBox(width: 12,),
                 Text(_vehicleImage.length!=null?'Pictures Selected':'Vehicle Gallery', style: TextStyle(fontSize: 18, color: lightGray),)
              ],
            ),
          ),
           GestureDetector(onTap: (){
             selectImages();
              setState(() {
                
              });
           },
           child: Icon(_vehicleImage.length!=null?Icons.done:Icons.add_circle_rounded, color: primaryColor,size: 35,),) 
          
        ],
      ),
    );
  }


Future<void> updatePress() async {
   //checkConnectivity();
    if(vehicleRegController.text==null||vehicleRegController.text==""){
      showSnackBar('Please Enter Vehicle Registration No.');
    }else if ( vehicleModelNoController.text==null||vehicleModelNoController.text==""){
      showSnackBar('Please Enter vehicle Model No.');
    }else if(vehicleManuController.text==null||vehicleManuController.text==""){
      showSnackBar('Please Enter Manufacturar.');
    }else if(vehicleInssuranceCompanyController.text==null||vehicleInssuranceCompanyController.text==""){
      showSnackBar('Please Enter Company Name.');
    }else if(vehicleInssuranceNoController.text==null||vehicleInssuranceNoController.text==""){
      showSnackBar('Please Enter Insurance No.');
    }else if(vehicleInssuranceDateController.text==null||vehicleInssuranceDateController.text==""){
      showSnackBar('Please Enter Date.');
    }else{
    showSnackBar('Please wait...!');
     User user = FirebaseAuth.instance.currentUser;
     DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users/${user.uid}/vehicle/');
     DatabaseReference databaseImage = FirebaseDatabase.instance.reference().child('users/${user.uid}/vehicleImage');
 
 
  Map vehicleMap = {
    'registration':vehicleRegController.text,
    'manu':vehicleManuController.text,
    'insuranceNo':vehicleInssuranceNoController.text,
    'company':vehicleInssuranceCompanyController.text,
    'insuranceDate':vehicleInssuranceDateController.text,
    'status':0,
    'uid':user.uid,
    'tag':0,
    'model':vehicleModelNoController.text,
    
    
  };
 var index =  _vehicleImage.length;

 for(int i=0; i<index;i++){
      firebase_storage.UploadTask uploadTask;
    
showSnackBar('Wait! We are uploading photos');
    // Create a Reference to the file


          firebase_storage.Reference reference =
    firebase_storage.FirebaseStorage.instance.ref().child("users").child(user.uid).child("vehicle/${i}");
  File im = File(_vehicleImage[i].image);
    firebase_storage.TaskSnapshot storageTaskSnapshot =await reference.putFile(im);

    print(storageTaskSnapshot.ref.getDownloadURL());

   var dowUrl = await storageTaskSnapshot.ref.getDownloadURL();
databaseImage.child("$i").set(dowUrl);
 }
  databaseReference.set(vehicleMap).whenComplete(() {
    
showSnackBar('Registered!');
  AppRoutes.replace(context, CustomerHomeClass());
  });
  
    }

}

}
