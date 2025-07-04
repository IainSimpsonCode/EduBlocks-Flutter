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

  late CodeTracker _codeTracker;

  void _handleCodeTrackerUpdates() {
    setState(() {
      
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _codeTracker = Provider.of<CodeTracker>(context, listen: false);
    _codeTracker.addListener(_handleCodeTrackerUpdates);
  }

  @override
  void dispose() {
    // Safely remove provider listener
    _codeTracker.removeListener(_handleCodeTrackerUpdates);
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
          children: Provider.of<CodeTracker>(context, listen: false).JSONToFormattedTextWidgets(context),
        ),
      ),
    );
  }
}