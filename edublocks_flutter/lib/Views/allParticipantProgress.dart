import 'package:edublocks_flutter/Classes/Participant.dart';
import 'package:edublocks_flutter/Widgets/progressIcons.dart';
import 'package:flutter/material.dart';

class allParticipantInfoScreen extends StatefulWidget {
  const allParticipantInfoScreen({super.key, required this.participants});

  final List<Participant> participants;

  @override
  State<allParticipantInfoScreen> createState() => _allParticipantInfoScreenState();
}

class _allParticipantInfoScreenState extends State<allParticipantInfoScreen> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> participantCards = [];

    for (Participant participant in widget.participants) {
      participantCards.add(ListTile(
        title: Text(participant.getPID()),
        trailing: progrssIcons(context, participant),
      ));
    }


    return ListView(
      children: participantCards,
    );
  }
}