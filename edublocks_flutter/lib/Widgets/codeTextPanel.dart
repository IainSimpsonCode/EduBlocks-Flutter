import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class codeTextPanel extends StatefulWidget {
  const codeTextPanel({super.key});

  @override
  State<codeTextPanel> createState() => _codeTextPanelState();
}

class _codeTextPanelState extends State<codeTextPanel> {

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
          children: Provider.of<CodeTracker>(context, listen: false).JSONToFormattedTextWidgets(),
        ),
      ),
    );
  }
}