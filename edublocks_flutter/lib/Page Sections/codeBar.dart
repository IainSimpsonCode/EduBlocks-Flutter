import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';

class codeBarWidget extends StatefulWidget {
  const codeBarWidget({super.key});

  @override
  State<codeBarWidget> createState() => _codeBarWidgetState();
}

class _codeBarWidgetState extends State<codeBarWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width / codeBarWidth,
      color: codeBarColour,
    );
  }
}