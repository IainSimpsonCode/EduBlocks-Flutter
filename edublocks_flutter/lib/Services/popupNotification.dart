import 'package:flutter/material.dart';

void showPopup(BuildContext context, String title, String message, List<Widget>? differentButtons) {
  // Show popup to display task
    WidgetsBinding.instance.addPostFrameCallback((_) {

      List<Widget>? buttons = differentButtons;
      buttons ??= [
        TextButton(
          child: Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ]; // Assign an OK button, unless a non-null value was supplied for differentButtons
      
      showDialog(
        barrierDismissible: false, // User must click a button to proceed
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: buttons,
          );
        },
      );
    });
}