import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/Widgets/buttonWithIcon.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class topBarWidget extends StatefulWidget {
  const topBarWidget({super.key});

  @override
  State<topBarWidget> createState() => _topBarWidgetState();
}

class _topBarWidgetState extends State<topBarWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return Container(
      height: 65,
      width: MediaQuery.sizeOf(context).width,
      color: topBarColour,

      padding: EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 0,
        children: [
          buttonWithIcon(
            svgIconLocation: 'category_icons/play.svg', 
            backgroundColor: runButtonColour,
            text: "Run",
            onTap: () {
              Provider.of<CodeTracker>(context, listen: false).run(context);
            },
          ),
        ],
      ),
    );
  }
}