import 'package:edublocks_flutter/Widgets/canvas.dart';
import 'package:edublocks_flutter/Widgets/codeBar.dart';
import 'package:edublocks_flutter/Widgets/sideBar.dart';
import 'package:flutter/material.dart';

class CodeScreen extends StatefulWidget {
  const CodeScreen({super.key});

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        sideBarWidget(),
        canvasWidget(),
        codeBarWidget(),
      ],
    );
  }
}