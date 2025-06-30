import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/Widgets/codeOutputToggleButtons.dart';
import 'package:edublocks_flutter/Widgets/codeTextPanel.dart';
import 'package:edublocks_flutter/Widgets/outputTextPanel.dart';
import 'package:edublocks_flutter/features.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class codeBarWidget extends StatefulWidget {
  const codeBarWidget({super.key});

  @override
  State<codeBarWidget> createState() => _codeBarWidgetState();
}

class _codeBarWidgetState extends State<codeBarWidget> {

  late CodeOutputTextPanelNotifier _codeOutputTextPanelNotifier;

  void _handleCodeOutputTextPanelUpdates() {
    setState(() {
      
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _codeOutputTextPanelNotifier = Provider.of<CodeOutputTextPanelNotifier>(context, listen: false);
    _codeOutputTextPanelNotifier.addListener(_handleCodeOutputTextPanelUpdates);
  }

  @override
  void dispose() {
    // Safely remove provider listener
    _codeOutputTextPanelNotifier.removeListener(_handleCodeOutputTextPanelUpdates);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width / codeBarWidth,
      color: codeBarColour,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: showCodeAndOutputSimultaniously(context) ? 
        [
          Text("Code: ", style: bodyMedium),
          codeTextPanel(),
          Text("Output: ", style: bodyMedium),
          outputTextPanel(),
        ] : [
          codeOutputToggleButtons(),
          _codeOutputTextPanelNotifier.textPanel(),
        ]
      ),
    );
  }
}