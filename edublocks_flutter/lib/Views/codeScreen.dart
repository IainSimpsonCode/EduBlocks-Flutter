import 'package:edublocks_flutter/Page%20Sections/canvas.dart';
import 'package:edublocks_flutter/Page%20Sections/codeBar.dart';
import 'package:edublocks_flutter/Page%20Sections/sideBar.dart';
import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CodeScreen extends StatefulWidget {
  const CodeScreen({super.key});

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: canvasColour,
      child: Row(
        children: [
          sideBarWidget(),
          canvasWidget(),
          codeBarWidget(),
        ],
      ),
    );
  }
}