import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class codeOutputToggleButtons extends StatefulWidget {
  const codeOutputToggleButtons({super.key});

  @override
  State<codeOutputToggleButtons> createState() => _codeOutputToggleButtonsState();
}

class _codeOutputToggleButtonsState extends State<codeOutputToggleButtons> {
  bool codeSelected = true;
  bool isHovered = false;

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
    return Row(
      spacing: 8,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() {
            if (!codeSelected) {
              isHovered = true;
            }
          }),
          onExit: (_) => setState(() {
            if (!codeSelected) {
              isHovered = false;
            }
          }),
          child: GestureDetector(
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isHovered
                  ? buttonGreyColour
                  : (codeSelected ? buttonGreyColour : codeBarColour),
                borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: Text(
                "Code",
                style: bodyMedium,
              ),
            ),
            onTap: () {
              setState(() {
                codeSelected = true;
                isHovered = false;
              });
            }
          ),
        ),
        MouseRegion(
          onEnter: (_) => setState(() {
            if (codeSelected) {
              isHovered = true;
            }
          }),
          onExit: (_) => setState(() {
            if (codeSelected) {
              isHovered = false;
            }
          }),
          child: GestureDetector(
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isHovered
                  ? buttonGreyColour
                  : (codeSelected ? codeBarColour : buttonGreyColour),
                borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: Text(
                "Output",
                style: bodyMedium,
              ),
            ),
            onTap: () {
              setState(() {
                codeSelected = false;
                isHovered = false;
              });
            }
          ),
        ),
      ],
    );
  }
}