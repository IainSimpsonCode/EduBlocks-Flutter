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

  void _handleCodeTrackerUpdates() {
    setState(() {
      
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Provider.of<CodeTracker>(context, listen: false).addListener(_handleCodeTrackerUpdates);
  }

  @override
  void dispose() {
    // Safely remove provider listener
    Provider.of<CodeTracker>(context, listen: false).removeListener(_handleCodeTrackerUpdates);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          color: codeTextPanelColour,
          borderRadius: BorderRadius.all(Radius.circular(4))
        ),
        padding: EdgeInsets.all(8),
        child: ListView(
          children: Provider.of<CodeTracker>(context, listen: false).outputString,
        ),
      ),
    );
  }
}