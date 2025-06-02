import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/Widgets/codeOutputToggleButtons.dart';
import 'package:edublocks_flutter/Widgets/codeTextPanel.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class codeBarWidget extends StatefulWidget {
  const codeBarWidget({super.key});

  @override
  State<codeBarWidget> createState() => _codeBarWidgetState();
}

class _codeBarWidgetState extends State<codeBarWidget> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Provider.of<CodeOutputTextPanelNotifier>(context, listen: false).addListener(() {
      setState(() {
        
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width / codeBarWidth,
      color: codeBarColour,
      padding: EdgeInsets.all(16),
      child: Column(
        spacing: 16,
        children: [
          codeOutputToggleButtons(),
          Provider.of<CodeOutputTextPanelNotifier>(context, listen: false).textPanel(),
        ]
      ),
    );
  }
}