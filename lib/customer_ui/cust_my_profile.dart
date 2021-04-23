import 'dart:io';
import 'package:flutter_app/core/helper/helperMethod.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'package:flutter_app/utilities/customer_buttons.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_core/firebase_core.dart';
import 'bar_drawer.dart';



class CustomerPrfileClass extends StatefulWidget {
  @override
  _CustomerPrfileClassState createState() => _CustomerPrfileClassState();
}

class _CustomerPrfileClassState extends State<CustomerPrfileClass> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
    var username = TextEditingController();
    var email = TextEditingController();
    var contact = TextEditingController();
    var dob = TextEditingController();
var dowUrl;

   void showSnackBar(String title){
  final snackBar = SnackBar(content: Text(title,textAlign: TextAlign.center,style: TextStyle(fontSize: 15),),);
  _scaffoldKey.currentState.showSnackBar(snackBar);
}

  bool editProfile = false;
  /// Image Picker
  File _image;
  final picker = ImagePicker();
 

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
     
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    username.text=currentUserInfo.username;
    email.text = currentUserInfo.email;
    contact.text = currentUserInfo.phone;
    dob.text = currentUserInfo.dob;

  
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      //drawer: CusDrawerPage(context),
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight), // here the desired height
          child: CusAppBarClass( context, 'My Profile', false,_scaffoldKey) ),

      body: SingleChildScrollView(

        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            personalDetailWidget(),
            constant_role==0
            ?
            Container(
              margin: EdgeInsets.only(left:15,right: 15),
              padding: EdgeInsets.only(left:10,right: 10),
              alignment: Alignment.topLeft,
              child: Text('Vehicle Detail',
            textAlign: TextAlign.start,
            style: TextStyle(color: DarkGray, fontWeight: FontWeight.w600, fontSize: 25),)
            ,)
            :SizedBox(),
          SizedBox(height: 20,),
          
            constant_role==0?carDetail():SizedBox()
          ],
        ),
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
        dob.text = selectedDate.day.toString()+"-"+selectedDate.month.toString()+"-"+selectedDate.year.toString();
      });
  }

  Widget personalDetailWidget(){
    return Container(
      padding: EdgeInsets.only(top: 0, left: 20,right: 20, bottom: 30),
      margin: EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      child:  Column(
        children: [
          SizedBox(
                height: 10,
              ),
              _image == null ?

              CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.2),
                radius: 50,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.black.withOpacity(0),
                      backgroundImage: NetworkImage(currentUserInfo.displayImage)
                    ),
                   /* Center(
                        child: Icon(
                      (constant_role == 0)
                          ? Icons.person
                          : Icons.verified_user_outlined,
                      color: Colors.white,
                      size: 50,
                    )),
                    */
                    Positioned(
                        bottom: 4,
                        right: 8,
                        child: GestureDetector(
                            onTap: () {
                               getImage();
                              if (constant_role == 0) {
                               
                                print("upload user pic");
                              } else {
                                print("upload restaurant pic");
                              }
                            },
                            child: Icon(
                              Icons.photo_camera,
                              size: 30,
                              color: Colors.black,
                            )))
                  ],
                ),
              ): 
               Stack(
                    children: <Widget>[
                       CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.2),
                radius: 50,
                backgroundImage: FileImage(_image)
                
              ),
               Positioned(
                        bottom: 4,
                        right: 8,
                        child: GestureDetector(
                            onTap: () {
                              getImage();
                             
                            },
                            child: Icon(
                              Icons.photo_camera,
                              size: 30,
                              color: Colors.black,
                            )))
                    ],
              )  ,
            
              SizedBox(
                height: 20,
              ),
          Row(
            children: [
              // image Container
            
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5, bottom: 0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
               Icon(Icons.verified_user,color: lightGray,),
                 Container(
                    width: MediaQuery.of(context).size.width-100,
            child: TextFormField(
             
              keyboardType:TextInputType.text,
              controller: username,
              enabled: true,
              decoration: InputDecoration(
                hintText: constant_role==0?'Customer Name':'Driver Name',
                hintStyle: TextStyle(color: lightGray),
                border: InputBorder.none,
                alignLabelWithHint: true,
                labelText: constant_role==0?'Customer Name':'Driver Name',
                contentPadding: EdgeInsets.only(left: 10, bottom: 0)
              ),
              style: TextStyle(fontSize: 18, color: Colors.black,

            ),
          ),)
              ],
            ),
          ),
           GestureDetector(onTap: (){
            
           },
           child: Icon(Icons.arrow_forward_ios, color: lightGray,),) 
          
        ],
      ),
    ),
 Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5, bottom: 0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
               Icon(Icons.verified_user,color: lightGray,),
                 Container(
                    width: MediaQuery.of(context).size.width-100,
            child: TextFormField(
             
              keyboardType:TextInputType.text,
              controller: email,
              enabled: true,
              decoration: InputDecoration(
                hintText: constant_role==0?'Customer Name':'Driver Name',
                hintStyle: TextStyle(color: lightGray),
                border: InputBorder.none,
                alignLabelWithHint: true,
                labelText: 'Email ID',
                contentPadding: EdgeInsets.only(left: 10, bottom: 0)
              ),
              style: TextStyle(fontSize: 18, color: Colors.grey,

            ),
          ),)
              ],
            ),
          ),
           GestureDetector(onTap: (){
            
           },
           child: Icon(Icons.arrow_forward_ios, color: lightGray,),) 
          
        ],
      ),
    ),
 Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5, bottom: 0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
               Icon(Icons.verified_user,color: lightGray,),
                 Container(
                    width: MediaQuery.of(context).size.width-100,
            child: TextFormField(
             
              keyboardType:TextInputType.text,
              controller: contact,
              enabled: false,
              decoration: InputDecoration(
                hintText: constant_role==0?'Customer Name':'Driver Name',
                hintStyle: TextStyle(color: lightGray),
                border: InputBorder.none,
                alignLabelWithHint: true,
                labelText: 'Contact Details',
                contentPadding: EdgeInsets.only(left: 10, bottom: 0)
              ),
              style: TextStyle(fontSize: 18, color: Colors.grey,

            ),
          ),)
              ],
            ),
          ),
           GestureDetector(onTap: (){
            
           },
           child: Icon(Icons.arrow_forward_ios, color: lightGray,),) 
          
        ],
      ),
    ),
 Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      padding: EdgeInsets.only(left: 5, right: 5, bottom: 0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
               Icon(Icons.verified_user,color: lightGray,),
                 Container(
                    width: MediaQuery.of(context).size.width-100,
           
           
          
            child: TextFormField(
             
              keyboardType:TextInputType.text,
              controller: dob,
              enabled: true,
              onTap: (){
                 _selectDate(context);
              },
              decoration: InputDecoration(
                hintText: constant_role==0?'Customer Name':'Driver Name',
                hintStyle: TextStyle(color: lightGray),
                border: InputBorder.none,
                alignLabelWithHint: true,
                labelText: 'Date of birth',
                contentPadding: EdgeInsets.only(left: 10, bottom: 0)
              ),
              style: TextStyle(fontSize: 18, color: Colors.black,

            ),
          ),)
              ],
            ),
          ),
           GestureDetector(onTap: (){
            
           },
           child: Icon(Icons.arrow_forward_ios, color: lightGray,),) 
          
        ],
      ),
    ),
    PrimaryButton( Heading: 'Update',onTap: () async {
      showSnackBar('Processing');
         if(_image!=null){
           firebase_storage.UploadTask uploadTask;

    // Create a Reference to the file


          firebase_storage.Reference reference =
    firebase_storage.FirebaseStorage.instance.ref().child("users").child(currentUserInfo.id);

    firebase_storage.TaskSnapshot storageTaskSnapshot =await reference.putFile(_image);

    print(storageTaskSnapshot.ref.getDownloadURL());

    dowUrl = await storageTaskSnapshot.ref.getDownloadURL();


         }   
                DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users/${currentUserInfo.id}/');

  databaseReference.child('username').set(username.text);
  databaseReference.child('dob').set(dob.text);
  if(_image!=null){
databaseReference.child('displayImage').set(dowUrl);
  
  }
   await  HelperMethods.getCurrentUSerInfo();
             
          showSnackBar('Updated');
           await  HelperMethods.getCurrentUSerInfo();
           setState(() {
             
           });

          },),
                ],
              )),

            ],
          )
        ],
      ),
    );
  }


  Widget carDetail(){


     return  StreamBuilder(
              stream: FirebaseDatabase.instance
                  .reference()
                  .child('users/${currentUserInfo.id}/vehicle')
                  .onValue
                  ,
              builder: (BuildContext context, AsyncSnapshot<Event> snap) {
       if (snap.hasError)
          return Text('Error: ${snap.error}');
    if (!snap.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Loading..."),
                  SizedBox(
                    height: 50.0,
                  ),
                  CircularProgressIndicator()
                ],
              ),
            );
    }else
    if(snap.data.snapshot.value!=null){
            if(snap.data.snapshot.value.length==0){
               return  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                   SizedBox(
                    height: 50.0,
                  ),
                  Text("No Vehicle details added"),
                  SizedBox(
                    height: 50.0,
                  ),
                 
                ],
              ),
            );

           }else{

             
         //      Map<dynamic, dynamic> map = snap.data.snapshot.value;
         //           List<dynamic> list = map.values.toList();


          return  Container(
      width: MediaQuery.of(context).size.width,
      height: 350,
      margin: EdgeInsets.only(left:15,right: 15),
      padding: EdgeInsets.only(left:10,right: 10),
      decoration: BoxDecoration(
        color: whtColor,
        border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      child: Container(
                  
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
          itemCount: 1,
          itemBuilder: (BuildContext context, int index ){
              return Container(
      padding: EdgeInsets.only(left: 20,right: 20, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text('Manufacturer: '+snap.data.snapshot.value["manu"]??'Manufacture#: 574854758934',style: TextStyle(color: DarkGray, fontWeight: FontWeight.w400, fontSize: 20),),
SizedBox(height: 10,),
Text('Model: '+snap.data.snapshot.value["model"]??'Dubai A-3748457',style: TextStyle(color: DarkGray, fontWeight: FontWeight.w400, fontSize: 20),),
 SizedBox(height: 10,),
         Text('Reg No: '+snap.data.snapshot.value["registration"]??'Honda civic 2000',style: TextStyle(color: DarkGray, fontWeight: FontWeight.w400, fontSize: 20),),
         
          
          SizedBox(height: 10,),
   Text('Insurance: '+snap.data.snapshot.value["company"]??'Insurance Expiry: 25 Dec 2022',style: TextStyle(color: DarkGray, fontWeight: FontWeight.w400, fontSize: 20),),
          SizedBox(height: 10,),
         
          Text('Insurance No:'+snap.data.snapshot.value["insuranceNo"]??'AXA Car Insurance',style: TextStyle(color: DarkGray, fontWeight: FontWeight.w400, fontSize: 20),),
          SizedBox(height: 10,),
          Text('Expiry: '+snap.data.snapshot.value["insuranceDate"]??'Insurance Expiry: 25 Dec 2022',style: TextStyle(color: DarkGray, fontWeight: FontWeight.w400, fontSize: 20),),
          


          Container(
            margin: EdgeInsets.only(top: 30,),
            child: Wrap(
              children: [
                carImage()
             //   carImage('assets/car1.jpg'),
             //   carImage('assets/car2.jpg'),
             //   carImage('assets/car3.jpg'),
             //   carImage('assets/car4.jpg'),
             //   carImage('assets/car2.jpg'),
              ],
            ),
          ),
        ],
      ),
    );
  
          }),
    )
      
    );
 
               
             
           }
                 
            }else{
               return  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                   SizedBox(
                    height: 50.0,
                  ),
                  Text("No Vehicle details added"),
                  SizedBox(
                    height: 50.0,
                  ),
                 
                ],
              ),
            );
       
            }
       
    
  
  }
);
  
  }



  Widget carImage(){
     return  StreamBuilder(
              stream: FirebaseDatabase.instance
                  .reference()
                  .child('users/${currentUserInfo.id}/vehicleImage')
                  .onValue
                  ,
              builder: (BuildContext context, AsyncSnapshot<Event> snap) {
       if (snap.hasError)
          return Text('Error: ${snap.error}');
    if (!snap.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Loading..."),
                  SizedBox(
                    height: 50.0,
                  ),
                  CircularProgressIndicator()
                ],
              ),
            );
    }else
    if(snap.data.snapshot.value!=null){
            if(snap.data.snapshot.value.length==0){
               return  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                   SizedBox(
                    height: 50.0,
                  ),
                  Text("No Vehicle Images added"),
                  SizedBox(
                    height: 50.0,
                  ),
                 
                ],
              ),
            );

           }else{

             
         //      Map<dynamic, dynamic> map = snap.data.snapshot.value;
         //           List<dynamic> list = map.values.toList();


          return  Container(
      width: MediaQuery.of(context).size.width,
      height: 100,
      decoration: BoxDecoration(
        color: whtColor,
        border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      child: Container(
                  
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
          itemCount: snap.data.snapshot.value.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index ){
            print(snap.data.snapshot.value[index]);
             return Container(
                      margin: EdgeInsets.all(5),
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(snap.data.snapshot.value[index].toString()),
                          fit: BoxFit.fill
                        )
                      ),
                    );
  

          }),
    )
      
    );
 
               
             
           }
                 
            }else{
               return  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                   SizedBox(
                    height: 50.0,
                  ),
                  Text("No Vehicle images added"),
                  SizedBox(
                    height: 50.0,
                  ),
                 
                ],
              ),
            );
       
            }
       
    
  
  }
);
  
   }

}
