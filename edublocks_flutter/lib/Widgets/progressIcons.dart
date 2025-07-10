import 'package:edublocks_flutter/Classes/Participant.dart';
import 'package:flutter/material.dart';

Widget progrssIcons(BuildContext context, Participant participant) {

  final completeIcon = Icon(Icons.circle, color: Colors.green);
  final incompleteIcon = Icon(Icons.circle, color: Colors.red);
  final completingIcon = Icon(Icons.circle, color: Colors.amber);

  List<Widget> icons = [];

  if (participant.task1) {
    icons.add(completeIcon);
  }
  else if (participant.currentTask == 1) {
    icons.add(completingIcon);
  }
  else {
    icons.add(incompleteIcon);
  }

  if (participant.task2) {
    icons.add(completeIcon);
  }
  else if (participant.currentTask == 2) {
    icons.add(completingIcon);
  }
  else {
    icons.add(incompleteIcon);
  }

  if (participant.task3) {
    icons.add(completeIcon);
  }
  else if (participant.currentTask == 3) {
    icons.add(completingIcon);
  }
  else {
    icons.add(incompleteIcon);
  }

  if (participant.task4) {
    icons.add(completeIcon);
  }
  else if (participant.currentTask == 4) {
    icons.add(completingIcon);
  }
  else {
    icons.add(incompleteIcon);
  }

  if (participant.task5) {
    icons.add(completeIcon);
  }
  else if (participant.currentTask == 5) {
    icons.add(completingIcon);
  }
  else {
    icons.add(incompleteIcon);
  }

  if (participant.task6) {
    icons.add(completeIcon);
  }
  else if (participant.currentTask == 6) {
    icons.add(completingIcon);
  }
  else {
    icons.add(incompleteIcon);
  }

  if (participant.task7) {
    icons.add(completeIcon);
  }
  else if (participant.currentTask == 7) {
    icons.add(completingIcon);
  }
  else {
    icons.add(incompleteIcon);
  }

  return Container(
    width: 200,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: icons,
    ),
  );
}