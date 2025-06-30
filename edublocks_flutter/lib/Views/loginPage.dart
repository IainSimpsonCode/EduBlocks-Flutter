import 'package:edublocks_flutter/Classes/Participant.dart';
import 'package:edublocks_flutter/Services/firestore.dart';
import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/Views/PIDScreen.dart';
import 'package:edublocks_flutter/Views/codeScreen.dart';
import 'package:edublocks_flutter/Widgets/buttonWithIcon.dart';
import 'package:edublocks_flutter/features.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  
  // Controller to access the username input
  final TextEditingController _usernameController = TextEditingController();

  void _onLoginPressed() async {
    String username = _usernameController.text;
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your 4 digit ID Number')),
      );
      return;
    }
    else if (username.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 4 digit ID Number')),
      );
      return;
    }
    else {
      // Valid(?) 4 digit participant ID has been input

      String classID = username.substring(0, 2); // First 2 digits = class ID
      String participantID = username.substring(2); // Last 2 digits = participant ID

      if (await doesParticipantExist(classID, participantID)) {

        Participant? user = await getParticipantInfo(classID, participantID);

        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('There was a problem logging you in. Please try again')),
          );
          return;
        }
        else {
          Provider.of<ParticipantInformation>(context, listen: false).login(user);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Material( child: showPIDonLogin ? PIDScreen() : CodeScreen()),
            ),
          );
        }

        //Provider.of<ParticipantInformation>(context, listen: false).login();
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Your 4 digit ID Number was not correct. Please double check and try again')),
        );
        return;
      }
    }    
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return Center(
      child: Container(
        padding: EdgeInsets.all(50),
        width: 300,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          color: loginPageColour
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'ID Number'),
                style: codeTextStyle,
                autofocus: true,
                autocorrect: false
              ),
              //buttonWithIcon(backgroundColor: runButtonColour, text: "Login", onTap: _onLoginPressed),
              ElevatedButton(onPressed: _onLoginPressed, child: Text("Login")),
            ]
          ),
        ),
      
    );
  }
}