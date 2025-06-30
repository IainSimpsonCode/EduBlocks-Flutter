import 'package:auto_size_text/auto_size_text.dart';
import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/Views/codeScreen.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PIDScreen extends StatefulWidget {
  const PIDScreen({super.key});

  @override
  State<PIDScreen> createState() => _PIDScreenState();
}

class _PIDScreenState extends State<PIDScreen> {

  FocusNode _focusNode = FocusNode();

  void _onKeyEvent(KeyEvent keyEvent) {
    // If the space bar is pressed
    if (keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.space) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Material( child: CodeScreen()),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKeyEvent, 
        child: Container(
          color: Colors.white,
          child: Center(
            child: AutoSizeText(
              "${Provider.of<ParticipantInformation>(context, listen: false).currentParticipant!.classID}${Provider.of<ParticipantInformation>(context, listen: false).currentParticipant!.ID}",
              style: codeTextStyle.copyWith(
                color: Colors.black,
              ),
              minFontSize: 100,
            ),
          ),
        )
      ),
    );
  }
}