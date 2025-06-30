import 'package:flutter/material.dart';

Future<bool> showCodePopup(BuildContext context, String correctCode) async {
  TextEditingController _codeController = TextEditingController();
  bool isValid = false;

  return await showDialog<bool>(
    context: context,
    barrierDismissible: false, // prevent dismissing by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Enter 4-digit Code'),
        content: TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: InputDecoration(
            hintText: 'Enter code',
            counterText: '',
          ),
          obscureText: true, // optional: hide input like password
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false); // user cancelled
            },
          ),
          ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              if (_codeController.text == correctCode) {
                isValid = true;
              } else {
                isValid = false;
              }
              Navigator.of(context).pop(isValid);
            },
          ),
        ],
      );
    },
  ).then((value) => value ?? false); // return false if dialog is dismissed
}
