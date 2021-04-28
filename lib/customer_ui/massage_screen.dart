import 'package:flutter/material.dart';
import 'package:flutter_app/utilities/utilities.dart';
import 'bar_drawer.dart';
import 'package:flutter_app/utilities/constant.dart';
import 'package:firebase_database/firebase_database.dart';

class MassageScreen extends StatefulWidget {
  @override
  _MassageScreenState createState() => _MassageScreenState();
}

class _MassageScreenState extends State<MassageScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var massageController = TextEditingController();

  String sendTo;
  // send message
  DatabaseReference feedbackReference =
      FirebaseDatabase.instance.reference().child('message').push();

  @override
  void initState() {
    listnerMessage();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      //drawer: CusDrawerPage(context),
      appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(appBarHeight), // here the desired height
          child: CusAppBarClass(context, 'Messages', false, _scaffoldKey)),

      body: Container(
        height: MediaQuery.of(context).size.height - appBarHeight,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(child: msgeList()),
            msgeTypinig(),
          ],
        ),
      ),
    );
  }

  Widget msgeList() {
    var tr = tripList[0].tripID;
    return StreamBuilder(
        stream: constant_role == 0
            ? FirebaseDatabase.instance
                .reference()
                .child('message')
                .orderByChild('trip_id')
                //   .equalTo(currentUserInfo.id)
                //   .orderByValue()
                .equalTo(tr)
                .onValue
            : FirebaseDatabase.instance
                .reference()
                .child('message/')
                .orderByChild('trip_id')
                // .equalTo(currentUserInfo.id)
                // .orderByValue()
                .equalTo(tr)
                .onValue,
        builder: (BuildContext context, AsyncSnapshot<Event> snap) {
          if (snap.hasError) return Text('Error: ${snap.error}');
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
          } else if (snap.data.snapshot.value != null) {
            if (snap.data.snapshot.value.length == 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 50.0,
                    ),
                    Text("NO TRIP HISTORY"),
                    SizedBox(
                      height: 50.0,
                    ),
                  ],
                ),
              );
            } else {
              Map<dynamic, dynamic> map = snap.data.snapshot.value;
              List<dynamic> list = map.values.toList();

              return Container(
                  child: ListView.builder(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      itemCount: list.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        if (list[index]["sent_from"] == currentUserInfo.id) {
                          return outgoingMsg(list[index]["massage_text"]);
                        } else {
                          return incommingMsg(list[index]["massage_text"]);
                        }
                        //   return index.isOdd?outgoingMsg():incommingMsg();
                      }));
            }
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 50.0,
                  ),
                  Text(""),
                  SizedBox(
                    height: 50.0,
                  ),
                ],
              ),
            );
          }
        });
  }

  Widget incommingMsg(msg) {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(right: 5),
          height: 50,
          width: 40,
          child: Image.network(driver_img),
        ),
        Expanded(
            child: Container(
          margin: EdgeInsets.only(
              right: MediaQuery.of(context).size.width * .2, top: 5, bottom: 5),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: lightGray,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15))),
          child: Text(
            msg ?? 'Msg received from Driver',
            style: TextStyle(color: whtColor),
          ),
        ))
      ],
    );
  }

  Widget outgoingMsg(msg) {
    return Container(
      margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * .25, top: 5, bottom: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: blueColor,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(15),
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15))),
      child: Text(
        msg ?? 'Msg sent to Driver',
        style: TextStyle(color: whtColor),
      ),
    );
  }

  Widget msgeTypinig() {
    return Container(
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: lightGray)], color: whtColor),
        child: Row(
          children: [
            Container(
              child: TextFormField(
                controller: massageController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Type your Message here.....',
                  hintStyle: TextStyle(color: lightGray),
                ),
                maxLines: 1,
                minLines: 1,
                style: TextStyle(color: lightGray),
              ),
              width: MediaQuery.of(context).size.width - 90,
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                if (constant_role == 0) {
                  sendTo = tripList[0].driver_id;
                } else {
                  sendTo = tripList[0].rider_id;
                }

                // send message

                feedbackReference.child("rider_id").set(tripList[0].rider_id);
                feedbackReference.child("driver_id").set(tripList[0].driver_id);
                feedbackReference.child("date").set(DateTime.now().toString());
                feedbackReference.child("status").set(0);
                feedbackReference.child("trip_id").set(tripList[0].tripID);
                feedbackReference.child("sent_from").set(currentUserInfo.id);
                feedbackReference
                    .child("message_id")
                    .set(feedbackReference.key);
                feedbackReference
                    .child("massage_text")
                    .set(massageController.text);
                feedbackReference.child("sent_to").set(sendTo);

                massageController.clear();
              },
            )
          ],
        ));
  }

  void listnerMessage() {
    feedbackReference.onChildAdded.listen((event) {
      print('Triggered Listener on -- ADDED -- friend info');
      print(
          'info that changed: ${event.snapshot.key}: ${event.snapshot.value}');
      if (event.snapshot.key == 'sent_to') {
        var sent_to = event.snapshot.value;
        msg = true;
        if (constant_uid == sent_to) {
          showSnackBar('New Message');
        }
      }
    });
  }

  void showSnackBar(String title) {
    final snackBar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
