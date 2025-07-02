import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/features.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class codeTextPanel extends StatefulWidget {
  const codeTextPanel({super.key});

  @override
  State<codeTextPanel> createState() => _codeTextPanelState();
}

class _codeTextPanelState extends State<codeTextPanel> {
  late CodeTracker _codeTracker;
  Color _borderColor = Colors.transparent;

  void _handleCodeTrackerUpdates() {
    if (highlightCodePanelGreen(context)) {
      setState(() {
        _borderColor = Colors.green[400]!; // Flash green
      });
      // Revert back
      Timer(Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _borderColor = Colors.transparent;
          });
        }
      });
    }
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
      flex: 2,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: codeTextPanelColour,
          borderRadius: BorderRadius.all(Radius.circular(4)),
          border: Border.all(color: _borderColor, width: 5),
        ),
        padding: EdgeInsets.all(8),
        child: ListView(
          children: Provider.of<CodeTracker>(
            context,
            listen: false,
          ).JSONToFormattedTextWidgets(context),
        ),
      ),
    );
  }
}
