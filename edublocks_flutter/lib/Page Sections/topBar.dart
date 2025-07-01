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

  void _handleParticipantInfoChange() {
    setState(() {
      
    });
  }

  late ParticipantInformation participantInformation;

  @override
  void initState() {
    super.initState();

    participantInformation = Provider.of<ParticipantInformation>(context, listen: false);
    participantInformation.addListener(_handleParticipantInfoChange);
  }

  @override
  void dispose() {
    super.dispose();

    participantInformation.removeListener(_handleParticipantInfoChange);
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
        spacing: 14,
        children: [
          Expanded(
            child: Text(
              "Participant ID: ${Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.classID ?? ""}${Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.ID ?? "Not logged in"}\nYou are working on Task ${Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getTask() ?? 0} with Feature ${Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getFeature() ?? "0"}",
              style: codeTextStyle,
            ),
          ),
          buttonWithIcon(
            svgIconLocation: 'category_icons/trash.svg', 
            backgroundColor: Colors.red[400]!,
            text: "Delete All",
            onTap: () {
              Provider.of<DeleteAll>(context, listen: false).deleteAll(context, true);
            },
          ),
          buttonWithIcon(
            svgIconLocation: 'category_icons/play.svg', 
            backgroundColor: runButtonColour,
            text: "Run",
            onTap: () {
              Provider.of<CodeTracker>(context, listen: false).run(context);
            },
          ),
          buttonWithIcon(
            svgIconLocation: 'category_icons/flag.svg', 
            backgroundColor: Colors.green[400]!,
            text: "Next Task",
            onTap: () {
              Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.nextTaskPressed(context);
            },
          ),
        ],
      ),
    );
  }
}