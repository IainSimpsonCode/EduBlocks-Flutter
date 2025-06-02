import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class outputTextPanel extends StatefulWidget {
  const outputTextPanel({super.key});

  @override
  State<outputTextPanel> createState() => _outputTextPanelState();
}

class _outputTextPanelState extends State<outputTextPanel> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Provider.of<CodeTracker>(context, listen: false).addListener(() {
      setState(() {
        
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: codeTextPanelColour,
          borderRadius: BorderRadius.all(Radius.circular(4))
        ),
        padding: EdgeInsets.all(8),
        child: ListView(
          children: [Text(
            "# Output text will go here",
            style: GoogleFonts.firaCode(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: codeTextColour
            ),
          )],
        ),
      ),
    );
  }
}