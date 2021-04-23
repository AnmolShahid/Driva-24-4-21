import 'package:flutter/material.dart';
import 'package:flutter_beautiful_popup/main.dart';

Future<void> showDialogBox({ context, String description, String title}){
 final popup = BeautifulPopup(
  context: context,
  template:TemplateFail,
); 
return popup.show(
  title: title,
  content: description,
  actions: [
    popup.button(
      label: 'Close',
      onPressed: Navigator.of(context).pop,
    ),
  ],
  // bool barrierDismissible = false,
  // Widget close,
);
 
 }