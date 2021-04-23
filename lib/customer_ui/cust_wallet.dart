import 'package:flutter/material.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'bar_drawer.dart';

import 'package:flutter_app/utilities/constant.dart';
import 'package:flutter_app/utilities/customer_buttons.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';



class CustomerWalletClass extends StatefulWidget {
  @override
  _CustomerWalletClassState createState() => _CustomerWalletClassState();
}

class _CustomerWalletClassState extends State<CustomerWalletClass> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Drop Down Item Value
  int _value = 1;
  bool addNewCard = false;
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: whtColor,
      //drawer: CusDrawerPage(context),
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight), // here the desired height
          child: CusAppBarClass( context, 'Wallet', false,_scaffoldKey) ),

      body: Container(
          width: 500,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BalanceCardWidget(),
              
              addNewCard==true?
              CreditCardWidget(
                cardBgColor: const Color(0xff000000),
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                showBackView: isCvvFocused,
                obscureCardNumber: true,
                obscureCardCvv: true,
              )
              :
              ATMCardWidget(),
              addNewCard==true?
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      CreditCardForm(
                        formKey: formKey,
                        obscureCvv: true,
                        obscureNumber: true,
                        cardNumber: cardNumber,
                        cvvCode: cvvCode,
                        cardHolderName: cardHolderName,
                        expiryDate: expiryDate,
                        themeColor: Colors.black,
                        cardNumberDecoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Number',
                          hintText: 'XXXX XXXX XXXX XXXX',
                        ),
                        expiryDateDecoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Expired Date',
                          hintText: 'XX/XX',
                        ),
                        cvvCodeDecoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'CVV',
                          hintText: 'XXX',
                        ),
                        cardHolderDecoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Card Holder',
                        ),
                        onCreditCardModelChange: onCreditCardModelChange,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          primary: const Color(0xff000000),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          child: const Text(
                            'Validate',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'halter',
                              fontSize: 14,
                              package: 'flutter_credit_card',
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (formKey.currentState.validate()) {
                            print('valid!');
                              DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users/${currentUserInfo.id}/paymentCards/').push();



                              databaseReference.child('cardNumber').set(cardNumber);
                              databaseReference.child('expiryDate').set(expiryDate);
                              databaseReference.child('cardHolderName').set(cardHolderName);   
                              databaseReference.child('cvvCode').set(cvvCode); 
                              databaseReference.child('cardID').set(databaseReference.key);
                              setState(() {
                                addNewCard = false;
                              });


                          } else {
                            print('invalid!');
                          }
                        },
                      )
                    ],
                  ),
                ),
              ):PrimaryButton( Heading: 'Add Payment Method',onTap: () async {
                  setState(() {
                    addNewCard = true;
                  });
                 
          },),

           //   ATMCardWidget(),
          //    addATMCardWidget(),
            ],
          ),
        ),
    

    );
  }


       
   

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }



  Widget BalanceCardWidget(){
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: whtColor,
       border: Border(bottom: BorderSide(width: 1, color: lightGray))
      ),
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available balance', style: TextStyle(color: DarkGray, fontSize: 16, fontWeight: FontWeight.bold),),
          SizedBox(
            height: 10,
          ),
          Text('QAR --', style: TextStyle(color: DarkGray, fontSize: 20, fontWeight: FontWeight.bold),),
          SizedBox(
            height: 10,
          ),
          Text('Auto-refill is off', style: TextStyle(color: DarkGray, fontSize: 16, fontWeight: FontWeight.bold),),
        ],
      ),
    );
  }


  Widget ATMCardWidget(){
    return  StreamBuilder(
              stream: FirebaseDatabase.instance
                  .reference()
                  .child('users/${currentUserInfo.id}/paymentCards')
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
                  Text("No Payment Cards"),
                  SizedBox(
                    height: 50.0,
                  ),
                 
                ],
              ),
            );

           }else{


               Map<dynamic, dynamic> map = snap.data.snapshot.value;
                    List<dynamic> list = map.values.toList();


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
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index ){
             return 
      
      Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Row(
           crossAxisAlignment: CrossAxisAlignment.start,
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
            Container(
              margin: EdgeInsets.only(bottom: 15, left: 15,top:15),
              alignment: Alignment.centerLeft,
            child: Text('Card Details', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
          ),
           IconButton(icon:Icon(Icons.delete) ,onPressed: (){

             DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users/${currentUserInfo.id}/paymentCards/${list[index]["cardID"]}');
              databaseReference.remove();
              setState(() {
                
              });
          },),
         ],),
         /* Container(
            margin: EdgeInsets.only(bottom: 15),
            alignment: Alignment.topRight,
            child: Text('Master Card', textAlign: TextAlign.end, style: TextStyle(color: lightGray, fontSize: 16, fontWeight: FontWeight.bold),),
          ),
          */
          Container(
              margin: EdgeInsets.only(bottom: 15, left: 15),
              alignment: Alignment.centerLeft,
            child: Text(list[index]["cardNumber"]??'5646 6587 3493 5723', style: TextStyle(color: lightGray, fontSize: 20, fontWeight: FontWeight.bold),),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 20,top: 15, left: 15),
            alignment: Alignment.centerLeft,
            child: Text(list[index]["expiryDate"]??'Exp: 20/24      '+list[index]["cvvCode"]??'CVV: 045', style: TextStyle(color: lightGray, fontSize: 20, fontWeight: FontWeight.bold),),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 15, left: 15),
            alignment: Alignment.centerLeft,
            child: Text(list[index]["cardHolderName"]??'Akram Ullah', style: TextStyle(color: lightGray, fontSize: 20, fontWeight: FontWeight.bold),),
          ),
          Divider(
            height: 2,
          ),
         
        ],
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
                  Text("No Payment Cards"),
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


  Widget addATMCardWidget(){
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 20, bottom: 5, left: 15),
          alignment: Alignment.centerLeft,
          child: Text('Add Debit/Credit Card', textAlign: TextAlign.end, style: TextStyle(color: DarkGray, fontSize: 16, fontWeight: FontWeight.bold),),
        ),

        Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(15),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: whtColor,
             border: Border(bottom: BorderSide(width: 1, color: lightGray))
          ),
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 15),
                alignment: Alignment.topRight,
                child: cardType()
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15, left: 15),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    cardNOInput(4, '0000'),
                    cardNOInput(4,'0000'),
                    cardNOInput(4,'0000'),
                    cardNOInput(4,'0000'),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 20,top: 15, left: 15),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Row(
                      children: [
                        Text('Exp:  ', style: TextStyle(color: lightGray, fontSize: 20, fontWeight: FontWeight.bold),),
                        cardNOInput(2, 'MM'),
                        Text('/', style: TextStyle(color: lightGray, fontSize: 20, fontWeight: FontWeight.bold),),
                        cardNOInput(2, 'YY'),
                      ],
                    ),
                    Row(
                      children: [
                        Text('CVV:  ', style: TextStyle(color: lightGray, fontSize: 20, fontWeight: FontWeight.bold),),
                        cardNOInput(3, '000'),
                      ],
                    )
                  ],
                )
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15, left: 15),
                alignment: Alignment.centerLeft,
                child: cardNameInput(),
              ),
            ],
          ),
        )
      ],
    );
  }



  Widget cardNOInput(int length, String hint,){
    return Container(
      padding: EdgeInsets.only(left: 5, right: 5,),
      margin: EdgeInsets.only(left: 3, right: 3,),
      width: 17+(10*length).toDouble(),
      height: 25,
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: lightGray)
      ),
      child: TextFormField(
        decoration: InputDecoration(
          border: InputBorder.none,
          counter: Container(height: 0.00001,),
          contentPadding: EdgeInsets.only(bottom: 8),
          hintText: hint,
          hintStyle: TextStyle(color: lightGray,fontSize: 15, fontWeight: FontWeight.bold),

        ),
        keyboardType: TextInputType.phone,
        style: TextStyle(color: lightGray, fontWeight: FontWeight.bold),
        maxLength: length,
        onFieldSubmitted: (e){
           e =  cardNumber;
        },
      ),
    );
  }

  Widget cardNameInput(){
    return Container(
      padding: EdgeInsets.only(left: 5, right: 5,),
      margin: EdgeInsets.only(left: 3, right: 3,),
      width: MediaQuery.of(context).size.width*.4,
      height: 25,
      decoration: BoxDecoration(
          border: Border.all(width: 2, color: lightGray)
      ),
      child: TextFormField(
        decoration: InputDecoration(
          border: InputBorder.none,
          counter: Container(height: 0.00001,),
          contentPadding: EdgeInsets.only(bottom: 8),
          hintText: 'Name on card',
          hintStyle: TextStyle(color: lightGray,fontSize: 15, fontWeight: FontWeight.bold),

        ),
        keyboardType: TextInputType.name,
        style: TextStyle(color: lightGray, fontWeight: FontWeight.bold),
        maxLength: 30,
      ),
    );
  }

  Widget cardType(){
    return  Container(
      color: whtColor,
      width: MediaQuery.of(context).size.width*.3,
      height: 30,
      child: DropdownButton(
          style: TextStyle( fontWeight: FontWeight.w500, color: lightGray, fontSize: 15),
          elevation: 15,
          isExpanded: false,
          icon: Container(),

          value: _value,
          items: [
            DropdownMenuItem(
              child: Text("Select Card Type"),
              value: 1,
            ),
            DropdownMenuItem(
              child: Text("Master Card"),
              value: 2,
            ),
            DropdownMenuItem(
                child: Text("Visa Card"),
                value: 3
            ),

          ],
          onChanged: (value) {
            setState(() {
              _value = value;
            });
          }),
    );
  }


}
